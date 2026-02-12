param(
    [string]$RepoRoot = $PSScriptRoot,
    [switch]$NoWrite
)

$ErrorActionPreference = "Stop"

function Write-Utf8NoBom {
    param(
        [Parameter(Mandatory = $true)][string]$Path,
        [Parameter(Mandatory = $true)][string]$Content
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Content, $utf8NoBom)
}

function Get-PrStatus {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][int]$Number,
        [hashtable]$Headers
    )

    $url = "https://api.github.com/repos/$Repo/pulls/$Number"
    $response = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get

    if ($null -ne $response.merged_at -and $response.merged_at -ne "") {
        return "Merged"
    }
    if ($response.state -eq "closed") {
        return "Closed"
    }
    return "Open"
}

$readmePath = Join-Path $RepoRoot "README.md"
$indexPath = Join-Path $RepoRoot "index.html"

if (-not (Test-Path -LiteralPath $readmePath)) {
    throw "README not found: $readmePath"
}
if (-not (Test-Path -LiteralPath $indexPath)) {
    throw "Index file not found: $indexPath"
}

$readmeText = Get-Content -LiteralPath $readmePath -Raw
$indexText = Get-Content -LiteralPath $indexPath -Raw
$combined = "$readmeText`n$indexText"

$prLinkPattern = "https://github\.com/(?<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)/pull/(?<num>\d+)"
$prMatches = [regex]::Matches($combined, $prLinkPattern)
if ($prMatches.Count -eq 0) {
    throw "No pull request links found in README/index."
}

$prRefs = @{}
foreach ($m in $prMatches) {
    $repo = $m.Groups["repo"].Value
    $num = [int]$m.Groups["num"].Value
    $key = "$repo#$num"
    if (-not $prRefs.ContainsKey($key)) {
        $prRefs[$key] = @{
            Repo = $repo
            Number = $num
        }
    }
}

$headers = @{
    "User-Agent" = "jmahotiedu-pr-status-sync"
    "Accept" = "application/vnd.github+json"
}
$token = $env:GITHUB_TOKEN
if ([string]::IsNullOrWhiteSpace($token)) {
    $token = $env:GH_TOKEN
}
if (-not [string]::IsNullOrWhiteSpace($token)) {
    $headers["Authorization"] = "Bearer $token"
}

$statusByKey = @{}
foreach ($entry in ($prRefs.GetEnumerator() | Sort-Object Name)) {
    $repo = $entry.Value.Repo
    $num = $entry.Value.Number
    $key = "$repo#$num"
    $statusByKey[$key] = Get-PrStatus -Repo $repo -Number $num -Headers $headers
}

$readmeChanged = $false
$readmePattern = '(?m)^(?<prefix>- \*\*.+?\*\* - \[PR #(?<labelNum>\d+)\]\(https://github\.com/(?<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)/pull/(?<urlNum>\d+)\))(?<statusPart>(?: _\(Status: (?:Open|Closed|Merged)\)_)?)(?<suffix>: .*)$'
$readmeUpdated = [regex]::Replace($readmeText, $readmePattern, {
    param($m)

    if ($m.Groups["labelNum"].Value -ne $m.Groups["urlNum"].Value) {
        throw "PR number mismatch in README bullet: '$($m.Value)'"
    }

    $key = "$($m.Groups["repo"].Value)#$($m.Groups["urlNum"].Value)"
    if (-not $statusByKey.ContainsKey($key)) {
        throw "No fetched status found for README PR reference: $key"
    }

    $status = $statusByKey[$key]
    $replacement = "$($m.Groups["prefix"].Value) _(Status: $status)_$($m.Groups["suffix"].Value)"
    if ($replacement -ne $m.Value) {
        $script:readmeChanged = $true
    }
    return $replacement
})

$indexLines = Get-Content -LiteralPath $indexPath
$indexChanged = $false
$anchorPattern = '<a href="https://github\.com/(?<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)/pull/(?<num>\d+)"'

for ($i = 0; $i -lt $indexLines.Count; $i++) {
    if ($indexLines[$i] -notmatch $anchorPattern) {
        continue
    }

    $key = "$($Matches["repo"])#$($Matches["num"])"
    if (-not $statusByKey.ContainsKey($key)) {
        throw "No fetched status found for index PR reference: $key"
    }

    $status = $statusByKey[$key]
    $foundStack = $false

    for ($j = $i + 1; $j -lt [Math]::Min($indexLines.Count, $i + 16); $j++) {
        if ($indexLines[$j] -match "</a>") {
            break
        }
        if ($indexLines[$j] -match '<p class="stack">' -and $indexLines[$j] -match '\| State:') {
            $updated = [regex]::Replace($indexLines[$j], '(\| State:\s*)(Open|Closed|Merged)(</p>)', "`$1$status`$3")
            if ($updated -ne $indexLines[$j]) {
                $indexLines[$j] = $updated
                $indexChanged = $true
            }
            $foundStack = $true
            break
        }
    }

    if (-not $foundStack) {
        throw "Could not find stack/state line after PR card anchor in index.html near line $($i + 1)."
    }
}

if (-not $NoWrite) {
    if ($readmeChanged) {
        Write-Utf8NoBom -Path $readmePath -Content $readmeUpdated
    }
    if ($indexChanged) {
        Write-Utf8NoBom -Path $indexPath -Content (($indexLines -join [Environment]::NewLine) + [Environment]::NewLine)
    }
}

$summary = foreach ($entry in ($prRefs.GetEnumerator() | Sort-Object Name)) {
    [PSCustomObject]@{
        Repo = $entry.Value.Repo
        PR = $entry.Value.Number
        Status = $statusByKey[$entry.Name]
    }
}

$summary | Format-Table -AutoSize | Out-String | Write-Output
if ($readmeChanged -or $indexChanged) {
    Write-Output "Updated files: $(if ($readmeChanged) { 'README.md ' } else { '' })$(if ($indexChanged) { 'index.html' } else { '' })"
} else {
    Write-Output "No status changes needed."
}

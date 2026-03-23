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

# Fetches status, additions, and deletions for a PR in one API call.
function Get-PrInfo {
    param(
        [Parameter(Mandatory = $true)][string]$Repo,
        [Parameter(Mandatory = $true)][int]$Number,
        [hashtable]$Headers
    )

    $url = "https://api.github.com/repos/$Repo/pulls/$Number"
    $r = Invoke-RestMethod -Uri $url -Headers $Headers -Method Get

    $status = if ($null -ne $r.merged_at -and $r.merged_at -ne "") {
        "Merged"
    } elseif ($r.state -eq "closed") {
        "Closed"
    } else {
        "Open"
    }

    return @{
        Status    = $status
        Additions = [int]$r.additions
        Deletions = [int]$r.deletions
    }
}

function Format-Stat([int]$n) {
    return $n.ToString("N0")
}

$readmePath = Join-Path $RepoRoot "README.md"
$indexPath  = Join-Path $RepoRoot "index.html"

if (-not (Test-Path -LiteralPath $readmePath)) { throw "README not found: $readmePath" }
if (-not (Test-Path -LiteralPath $indexPath))  { throw "index.html not found: $indexPath" }

$readmeText = Get-Content -LiteralPath $readmePath -Raw
$indexText  = Get-Content -LiteralPath $indexPath  -Raw
$combined   = "$readmeText`n$indexText"

# Discover every unique PR referenced across both files
$prLinkPattern = "https://github\.com/(?<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)/pull/(?<num>\d+)"
$prMatches     = [regex]::Matches($combined, $prLinkPattern)
if ($prMatches.Count -eq 0) { throw "No pull request links found in README/index." }

$prRefs = @{}
foreach ($m in $prMatches) {
    $key = "$($m.Groups["repo"].Value)#$([int]$m.Groups["num"].Value)"
    if (-not $prRefs.ContainsKey($key)) {
        $prRefs[$key] = @{ Repo = $m.Groups["repo"].Value; Number = [int]$m.Groups["num"].Value }
    }
}

# Build auth headers
$headers = @{
    "User-Agent" = "jmahotiedu-pr-sync"
    "Accept"     = "application/vnd.github+json"
}
$token = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } else { $env:GH_TOKEN }
if (-not [string]::IsNullOrWhiteSpace($token)) { $headers["Authorization"] = "Bearer $token" }

# Fetch all PR info up front (one API call per unique PR)
$infoByKey = @{}
foreach ($entry in ($prRefs.GetEnumerator() | Sort-Object Name)) {
    $key = $entry.Name
    $infoByKey[$key] = Get-PrInfo -Repo $entry.Value.Repo -Number $entry.Value.Number -Headers $headers
    Write-Output "  Fetched $key -> $($infoByKey[$key].Status)  +$($infoByKey[$key].Additions)/-$($infoByKey[$key].Deletions)"
}

# ── README.md: update _(Status: X)_ labels ──────────────────────────────────
$readmeChanged = $false
$readmePattern = '(?m)^(?<prefix>- \*\*.+?\*\* - \[PR #(?<labelNum>\d+)\]\(https://github\.com/(?<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)/pull/(?<urlNum>\d+)\))(?<statusPart>(?: _\(Status: (?:Open|Closed|Merged)\)_)?)(?<suffix>: .*)$'
$readmeUpdated = [regex]::Replace($readmeText, $readmePattern, {
    param($m)

    if ($m.Groups["labelNum"].Value -ne $m.Groups["urlNum"].Value) {
        throw "PR number mismatch in README bullet: '$($m.Value)'"
    }

    $key = "$($m.Groups["repo"].Value)#$($m.Groups["urlNum"].Value)"
    if (-not $infoByKey.ContainsKey($key)) { throw "No fetched info for README PR: $key" }

    $status      = $infoByKey[$key].Status
    $replacement = "$($m.Groups["prefix"].Value) _(Status: $status)_$($m.Groups["suffix"].Value)"
    if ($replacement -ne $m.Value) { $script:readmeChanged = $true }
    return $replacement
})

# ── index.html: update State: X and +N/-N diff stats ────────────────────────
$indexLines   = Get-Content -LiteralPath $indexPath
$indexChanged = $false
$anchorPat    = '<a href="https://github\.com/(?<repo>[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+)/pull/(?<num>\d+)"'
$diffPat      = '\+[\d,]+/-[\d,]+'

for ($i = 0; $i -lt $indexLines.Count; $i++) {
    if ($indexLines[$i] -notmatch $anchorPat) { continue }

    $key = "$($Matches["repo"])#$($Matches["num"])"
    if (-not $infoByKey.ContainsKey($key)) { throw "No fetched info for index.html PR: $key" }

    $info      = $infoByKey[$key]
    $foundStack = $false

    for ($j = $i + 1; $j -lt [Math]::Min($indexLines.Count, $i + 16); $j++) {
        if ($indexLines[$j] -match "</a>") { break }
        if ($indexLines[$j] -notmatch '<p class="stack">') { continue }
        if ($indexLines[$j] -notmatch '\| State:') { continue }

        $line = $indexLines[$j]

        # Update State
        $line = [regex]::Replace($line, '(\| State:\s*)(Open|Closed|Merged)(</p>)', "`$1$($info.Status)`$3")

        # Update +N/-N diff stat if one is already present in this card
        if ($line -match $diffPat) {
            $addFmt  = Format-Stat $info.Additions
            $delFmt  = Format-Stat $info.Deletions
            $line    = [regex]::Replace($line, $diffPat, "+$addFmt/-$delFmt")
        }

        if ($line -ne $indexLines[$j]) {
            $indexLines[$j] = $line
            $indexChanged   = $true
        }
        $foundStack = $true
        break
    }

    if (-not $foundStack) {
        throw "Could not find stack/state line for PR card near index.html line $($i + 1)."
    }
}

# ── README.md: sync PR table rows between ### Merged / ### Open sections ─────
# Pattern: | **owner/repo** | [#N](url) | summary |
$tableRowPat = '^\| \*\*(?<repo>[A-Za-z0-9_.\-]+/[A-Za-z0-9_.\-]+)\*\* \| \[#(?<num>\d+)\]\(https://github\.com/[A-Za-z0-9_.\-]+/[A-Za-z0-9_.\-]+/pull/\d+\) \| (?<summary>.+?) \|$'

$readmeLines = $readmeUpdated -split '\r?\n'

# Locate section boundaries
$mergedHeaderIdx = -1
$openHeaderIdx   = -1
for ($i = 0; $i -lt $readmeLines.Count; $i++) {
    if ($readmeLines[$i] -eq '### Merged') { $mergedHeaderIdx = $i }
    if ($readmeLines[$i] -eq '### Open')   { $openHeaderIdx   = $i }
}

if ($mergedHeaderIdx -ge 0 -and $openHeaderIdx -gt $mergedHeaderIdx) {
    # Collect table rows from each section (skip header and separator lines)
    $mergedRows = [System.Collections.Generic.List[string]]::new()
    $openRows   = [System.Collections.Generic.List[string]]::new()

    # --- rows currently under ### Merged ---
    for ($i = $mergedHeaderIdx + 1; $i -lt $openHeaderIdx; $i++) {
        $line = $readmeLines[$i]
        if ($line -match $tableRowPat) { $mergedRows.Add($line) }
    }

    # --- rows currently under ### Open ---
    # The Open section ends at the next blank line after the table body
    $openEnd = $readmeLines.Count
    for ($i = $openHeaderIdx + 1; $i -lt $readmeLines.Count; $i++) {
        $line = $readmeLines[$i]
        # A blank line after at least one data row signals the end of the table
        if ($line.Trim() -eq '' -and $openRows.Count -gt 0) { $openEnd = $i; break }
        if ($line -match $tableRowPat) { $openRows.Add($line) }
    }

    # Combine and re-sort by live status
    $allRows = [System.Collections.Generic.List[string]]::new()
    $allRows.AddRange($mergedRows)
    $allRows.AddRange($openRows)

    $newMerged = [System.Collections.Generic.List[string]]::new()
    $newOpen   = [System.Collections.Generic.List[string]]::new()

    foreach ($row in $allRows) {
        if ($row -notmatch $tableRowPat) { continue }
        $repo = $Matches['repo']
        $num  = [int]$Matches['num']
        $key  = "${repo}#${num}"
        if (-not $infoByKey.ContainsKey($key)) {
            # Key not in fetched data — preserve in its current section
            if ($mergedRows.Contains($row)) { $newMerged.Add($row) } else { $newOpen.Add($row) }
            continue
        }
        switch ($infoByKey[$key].Status) {
            'Merged'  { $newMerged.Add($row) }
            'Open'    { $newOpen.Add($row) }
            'Closed'  { $script:readmeChanged = $true }   # drop closed-not-merged rows
        }
    }

    # Detect movement between sections
    $mergedSame = ($mergedRows.Count -eq $newMerged.Count) -and
                  (-not (Compare-Object $mergedRows.ToArray() $newMerged.ToArray()))
    $openSame   = ($openRows.Count -eq $newOpen.Count) -and
                  (-not (Compare-Object $openRows.ToArray() $newOpen.ToArray()))
    if (-not $mergedSame -or -not $openSame) { $readmeChanged = $true }

    # Rebuild file lines with corrected tables
    $tableHeader    = '| Repo | PR | Summary |'
    $tableSeparator = '|------|----|---------|'

    $newLines = [System.Collections.Generic.List[string]]::new()
    for ($i = 0; $i -lt $readmeLines.Count; $i++) {
        if ($i -eq $mergedHeaderIdx) {
            $newLines.Add($readmeLines[$i])          # ### Merged
            $newLines.Add('')
            $newLines.Add($tableHeader)
            $newLines.Add($tableSeparator)
            foreach ($r in $newMerged) { $newLines.Add($r) }
            # Skip original merged section (up to but not including ### Open line)
            $i = $openHeaderIdx - 1
            continue
        }
        if ($i -eq $openHeaderIdx) {
            $newLines.Add($readmeLines[$i])           # ### Open
            $newLines.Add('')
            $newLines.Add($tableHeader)
            $newLines.Add($tableSeparator)
            foreach ($r in $newOpen) { $newLines.Add($r) }
            # Skip original open section rows
            $i = $openEnd - 1
            continue
        }
        $newLines.Add($readmeLines[$i])
    }

    $readmeUpdated = $newLines -join "`n"
}

# ── Write ────────────────────────────────────────────────────────────────────
if (-not $NoWrite) {
    if ($readmeChanged) { Write-Utf8NoBom -Path $readmePath -Content $readmeUpdated }
    if ($indexChanged)  { Write-Utf8NoBom -Path $indexPath  -Content (($indexLines -join [Environment]::NewLine) + [Environment]::NewLine) }
}

# ── Summary ──────────────────────────────────────────────────────────────────
$summary = foreach ($entry in ($prRefs.GetEnumerator() | Sort-Object Name)) {
    $info = $infoByKey[$entry.Name]
    [PSCustomObject]@{
        Repo      = $entry.Value.Repo
        PR        = $entry.Value.Number
        Status    = $info.Status
        Additions = $info.Additions
        Deletions = $info.Deletions
    }
}

$summary | Format-Table -AutoSize | Out-String | Write-Output

$updated = @(if ($readmeChanged) { "README.md" } if ($indexChanged) { "index.html" })
if ($updated) {
    Write-Output "Updated: $($updated -join ', ')"
} else {
    Write-Output "No changes needed."
}

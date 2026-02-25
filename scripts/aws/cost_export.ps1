[CmdletBinding()]
param(
    [Parameter()]
    [string]$StartDate = (Get-Date).AddMonths(-1).ToString("yyyy-MM-01"),

    [Parameter()]
    [string]$EndDate = (Get-Date).ToString("yyyy-MM-dd"),

    [Parameter()]
    [string]$Region = "us-east-1",

    [Parameter()]
    [string]$OutDir = "",

    [Parameter()]
    [switch]$IncludeProjectTagBreakdown
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $scriptDir = Split-Path -Parent $PSCommandPath
    $OutDir = Join-Path $scriptDir "..\..\reports\aws-cost"
}

function Assert-Command {
    param([Parameter(Mandatory = $true)][string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command not found: $Name"
    }
}

function Invoke-AwsJson {
    param([Parameter(Mandatory = $true)][string[]]$Args)

    $raw = & aws @Args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "aws $($Args -join ' ') failed: $raw"
    }
    if ([string]::IsNullOrWhiteSpace(($raw | Out-String))) {
        return $null
    }
    return ($raw | ConvertFrom-Json)
}

function Convert-Amount {
    param([Parameter(Mandatory = $true)][string]$Value)
    return [decimal]::Parse($Value, [System.Globalization.CultureInfo]::InvariantCulture)
}

Assert-Command -Name "aws"

$start = (Get-Date $StartDate).ToString("yyyy-MM-dd")
$endInclusive = (Get-Date $EndDate).ToString("yyyy-MM-dd")
$endExclusive = (Get-Date $endInclusive).AddDays(1).ToString("yyyy-MM-dd")

if ((Get-Date $start) -ge (Get-Date $endExclusive)) {
    throw "Invalid date range. StartDate must be before EndDate."
}

New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("aws-cost-export-" + [Guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
$costFilterPath = Join-Path $tempDir "ce-filter.json"
'{"Not":{"Dimensions":{"Key":"RECORD_TYPE","Values":["Credit","Refund"]}}}' | Set-Content -Path $costFilterPath -Encoding ascii

Write-Host "Exporting AWS cost data (excluding Credit/Refund record types) (Start=$start, End=$endInclusive, EndExclusive=$endExclusive)..."

try {
    $serviceResp = Invoke-AwsJson -Args @(
        "ce", "get-cost-and-usage",
        "--region", $Region,
        "--time-period", "Start=$start,End=$endExclusive",
        "--granularity", "MONTHLY",
        "--metrics", "UnblendedCost",
        "--filter", "file://$costFilterPath",
        "--group-by", "Type=DIMENSION,Key=SERVICE",
        "--output", "json"
    )

$serviceRows = @()
foreach ($period in $serviceResp.ResultsByTime) {
    foreach ($group in $period.Groups) {
        $metric = $group.Metrics.UnblendedCost
        $serviceRows += [pscustomobject]@{
            start_date = $period.TimePeriod.Start
            end_date   = $period.TimePeriod.End
            service    = $group.Keys[0]
            amount_usd = Convert-Amount -Value $metric.Amount
            unit       = $metric.Unit
        }
    }
}

$serviceSummary = $serviceRows |
    Group-Object service |
    ForEach-Object {
        [pscustomobject]@{
            service           = $_.Name
            total_amount_usd  = [Math]::Round((($_.Group | Measure-Object -Property amount_usd -Sum).Sum), 2)
        }
    } |
    Sort-Object total_amount_usd -Descending

$serviceCsvPath = Join-Path $OutDir "cost-by-service-$timestamp.csv"
$serviceJsonPath = Join-Path $OutDir "cost-by-service-$timestamp.json"
$serviceLatestCsvPath = Join-Path $OutDir "latest-cost-by-service.csv"
$serviceLatestJsonPath = Join-Path $OutDir "latest-cost-by-service.json"

$serviceSummary | Export-Csv -Path $serviceCsvPath -NoTypeInformation
$serviceSummary | ConvertTo-Json -Depth 8 | Set-Content -Path $serviceJsonPath -Encoding utf8
$serviceSummary | Export-Csv -Path $serviceLatestCsvPath -NoTypeInformation
$serviceSummary | ConvertTo-Json -Depth 8 | Set-Content -Path $serviceLatestJsonPath -Encoding utf8

Write-Host ""
Write-Host "Top services by total cost:"
$serviceSummary | Select-Object -First 10 | Format-Table -AutoSize

    if ($IncludeProjectTagBreakdown) {
        Write-Host ""
        Write-Host "Exporting Project tag cost breakdown..."
        $tagResp = Invoke-AwsJson -Args @(
            "ce", "get-cost-and-usage",
            "--region", $Region,
            "--time-period", "Start=$start,End=$endExclusive",
            "--granularity", "MONTHLY",
            "--metrics", "UnblendedCost",
            "--filter", "file://$costFilterPath",
            "--group-by", "Type=TAG,Key=Project",
            "--output", "json"
        )

    $tagRows = @()
    foreach ($period in $tagResp.ResultsByTime) {
        foreach ($group in $period.Groups) {
            $metric = $group.Metrics.UnblendedCost
            $rawKey = if ($group.Keys.Count -gt 0) { $group.Keys[0] } else { "Project\$unknown" }
            $tagValue = if ($rawKey -like 'Project$*') { $rawKey.Substring(8) } else { $rawKey }
            if ([string]::IsNullOrWhiteSpace($tagValue)) {
                $tagValue = "untagged"
            }

            $tagRows += [pscustomobject]@{
                start_date = $period.TimePeriod.Start
                end_date   = $period.TimePeriod.End
                project    = $tagValue
                amount_usd = Convert-Amount -Value $metric.Amount
                unit       = $metric.Unit
            }
        }
    }

    $tagSummary = $tagRows |
        Group-Object project |
        ForEach-Object {
            [pscustomobject]@{
                project          = $_.Name
                total_amount_usd = [Math]::Round((($_.Group | Measure-Object -Property amount_usd -Sum).Sum), 2)
            }
        } |
        Sort-Object total_amount_usd -Descending

    $tagCsvPath = Join-Path $OutDir "cost-by-project-tag-$timestamp.csv"
    $tagJsonPath = Join-Path $OutDir "cost-by-project-tag-$timestamp.json"
    $tagLatestCsvPath = Join-Path $OutDir "latest-cost-by-project-tag.csv"
    $tagLatestJsonPath = Join-Path $OutDir "latest-cost-by-project-tag.json"

    $tagSummary | Export-Csv -Path $tagCsvPath -NoTypeInformation
    $tagSummary | ConvertTo-Json -Depth 8 | Set-Content -Path $tagJsonPath -Encoding utf8
    $tagSummary | Export-Csv -Path $tagLatestCsvPath -NoTypeInformation
    $tagSummary | ConvertTo-Json -Depth 8 | Set-Content -Path $tagLatestJsonPath -Encoding utf8

        Write-Host ""
        Write-Host "Top project-tag costs:"
        $tagSummary | Select-Object -First 10 | Format-Table -AutoSize
    }

    Write-Host ""
    Write-Host "Wrote cost report artifacts to: $OutDir"
}
finally {
    Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}

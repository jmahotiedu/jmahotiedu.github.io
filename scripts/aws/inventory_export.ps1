[CmdletBinding()]
param(
    [Parameter()]
    [string]$Region = "us-east-1",

    [Parameter()]
    [string]$OutDir = "",

    [Parameter()]
    [switch]$FailOnUnowned,

    [Parameter()]
    [switch]$FailOnActiveNonRetail
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $scriptDir = Split-Path -Parent $PSCommandPath
    $OutDir = Join-Path $scriptDir "..\..\reports\aws-cost"
}

$KeepProjects = @("retail-forecast-dashboard")
$ProjectPatterns = @(
    @{ regex = "retail-forecast"; project = "retail-forecast-dashboard" },
    @{ regex = "feature-flag"; project = "feature-flag-platform" },
    @{ regex = "workflow|wf-orch|workflow-orc"; project = "workflow-orchestrator" },
    @{ regex = "streaming-etl"; project = "streaming-etl-pipeline" }
)

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

function Try-InvokeAwsJson {
    param(
        [Parameter(Mandatory = $true)][string[]]$Args,
        [Parameter(Mandatory = $true)][string]$Context
    )
    try {
        return Invoke-AwsJson -Args $Args
    }
    catch {
        Write-Warning "$Context failed: $($_.Exception.Message)"
        return $null
    }
}

function Convert-Amount {
    param([Parameter(Mandatory = $true)][string]$Value)
    return [decimal]::Parse($Value, [System.Globalization.CultureInfo]::InvariantCulture)
}

function Convert-TagsToMap {
    param([Parameter()][object]$Tags)
    $map = @{}
    if ($null -eq $Tags) { return $map }
    foreach ($tag in $Tags) {
        if ($null -ne $tag.Key -and $null -ne $tag.Value) {
            $map[$tag.Key] = $tag.Value
        }
    }
    return $map
}

function Get-PropertyOrDefault {
    param(
        [Parameter(Mandatory = $true)][object]$Object,
        [Parameter(Mandatory = $true)][string]$Name,
        [Parameter()]$Default = $null
    )
    if ($null -eq $Object) { return $Default }
    $prop = $Object.PSObject.Properties[$Name]
    if ($null -eq $prop) { return $Default }
    return $prop.Value
}

function Resolve-Owner {
    param([Parameter(Mandatory = $true)][hashtable]$Tags)
    foreach ($key in @("Owner", "owner", "OWNER")) {
        if ($Tags.ContainsKey($key) -and -not [string]::IsNullOrWhiteSpace($Tags[$key])) {
            return $Tags[$key]
        }
    }
    return "unknown"
}

function Resolve-Project {
    param(
        [Parameter()][string]$Name,
        [Parameter(Mandatory = $true)][hashtable]$Tags
    )

    foreach ($key in @("Project", "project", "PROJECT")) {
        if ($Tags.ContainsKey($key) -and -not [string]::IsNullOrWhiteSpace($Tags[$key])) {
            $projectRaw = $Tags[$key].ToLowerInvariant()
            foreach ($p in $ProjectPatterns) {
                if ($projectRaw -match $p.regex) {
                    return $p.project
                }
            }
            return $Tags[$key]
        }
    }

    $nameNorm = if ($null -eq $Name) { "" } else { $Name.ToLowerInvariant() }
    foreach ($p in $ProjectPatterns) {
        if ($nameNorm -match $p.regex) {
            return $p.project
        }
    }
    return "unknown"
}

function Resolve-ResourceDisposition {
    param(
        [Parameter(Mandatory = $true)][string]$Project,
        [Parameter(Mandatory = $true)][string]$State
    )
    if ($KeepProjects -contains $Project) {
        return "keep"
    }
    if ($Project -eq "unknown") {
        return "investigate"
    }
    if ($State -match "running|ACTIVE|available|in-use|present|stopped|pending") {
        return "delete"
    }
    return "delete"
}

function Get-BillingServiceByResourceType {
    param([Parameter(Mandatory = $true)][string]$ResourceType)
    switch ($ResourceType) {
        "ecs"         { return "Amazon Elastic Container Service" }
        "alb"         { return "Amazon Elastic Load Balancing" }
        "ec2"         { return "Amazon Elastic Compute Cloud - Compute" }
        "nat"         { return "Amazon Virtual Private Cloud" }
        "rds"         { return "Amazon Relational Database Service" }
        "elasticache" { return "Amazon ElastiCache" }
        "ecr"         { return "Amazon Elastic Container Registry (ECR)" }
        "logs"        { return "AmazonCloudWatch" }
        default       { return "Unknown" }
    }
}

function Get-ServiceMonthlyEstimateMap {
    param([Parameter(Mandatory = $true)][string]$Region)
    $start = (Get-Date -Format "yyyy-MM-01")
    $endExclusive = (Get-Date).AddDays(1).ToString("yyyy-MM-dd")
    $tempFilterPath = Join-Path ([System.IO.Path]::GetTempPath()) ("ce-filter-" + [Guid]::NewGuid().ToString("N") + ".json")
    '{"Not":{"Dimensions":{"Key":"RECORD_TYPE","Values":["Credit","Refund"]}}}' | Set-Content -Path $tempFilterPath -Encoding ascii
    try {
        $resp = Try-InvokeAwsJson -Args @(
            "ce", "get-cost-and-usage",
            "--region", $Region,
            "--time-period", "Start=$start,End=$endExclusive",
            "--granularity", "MONTHLY",
            "--metrics", "UnblendedCost",
            "--filter", "file://$tempFilterPath",
            "--group-by", "Type=DIMENSION,Key=SERVICE",
            "--output", "json"
        ) -Context "Cost Explorer service estimate query"
    }
    finally {
        Remove-Item -Path $tempFilterPath -Force -ErrorAction SilentlyContinue
    }

    $map = @{}
    if ($null -eq $resp) { return $map }

    foreach ($period in $resp.ResultsByTime) {
        foreach ($group in $period.Groups) {
            $serviceName = $group.Keys[0]
            $amount = Convert-Amount -Value $group.Metrics.UnblendedCost.Amount
            $map[$serviceName] = [Math]::Round($amount, 2)
        }
    }
    return $map
}

Assert-Command -Name "aws"
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

$serviceEstimateMap = Get-ServiceMonthlyEstimateMap -Region $Region
$rows = New-Object System.Collections.Generic.List[object]

function Add-Row {
    param(
        [Parameter(Mandatory = $true)][string]$ResourceId,
        [Parameter(Mandatory = $true)][string]$ResourceType,
        [Parameter(Mandatory = $true)][string]$State,
        [Parameter()][string]$Name = "",
        [Parameter()][hashtable]$Tags = @{},
        [Parameter()][string]$Arn = "",
        [Parameter()][string]$Notes = ""
    )

    $project = Resolve-Project -Name $Name -Tags $Tags
    $owner = Resolve-Owner -Tags $Tags
    if ($owner -eq "unknown" -and $project -ne "unknown") {
        $owner = "portfolio-default"
    }
    $disposition = Resolve-ResourceDisposition -Project $project -State $State
    $billingService = Get-BillingServiceByResourceType -ResourceType $ResourceType
    $estimate = if ($serviceEstimateMap.ContainsKey($billingService)) { $serviceEstimateMap[$billingService] } else { [decimal]0 }

    $rows.Add([pscustomobject]@{
        resource_id            = $ResourceId
        resource_type          = $ResourceType
        service                = $billingService
        project                = $project
        owner                  = $owner
        disposition            = $disposition
        state                  = $State
        region                 = $Region
        arn                    = $Arn
        monthly_cost_estimate  = $estimate
        notes                  = $Notes
    }) | Out-Null
}

Write-Host "Collecting ECS services..."
$clustersResp = Try-InvokeAwsJson -Args @("ecs", "list-clusters", "--region", $Region, "--output", "json") -Context "ECS cluster listing"
if ($null -ne $clustersResp -and $clustersResp.clusterArns.Count -gt 0) {
    foreach ($clusterArn in $clustersResp.clusterArns) {
        $serviceResp = Try-InvokeAwsJson -Args @("ecs", "list-services", "--cluster", $clusterArn, "--region", $Region, "--output", "json") -Context "ECS service listing for $clusterArn"
        if ($null -eq $serviceResp -or $serviceResp.serviceArns.Count -eq 0) { continue }

        $serviceArns = @($serviceResp.serviceArns)
        for ($i = 0; $i -lt $serviceArns.Count; $i += 10) {
            $end = [Math]::Min($i + 9, $serviceArns.Count - 1)
            $chunk = @($serviceArns[$i..$end])
            $descArgs = @("ecs", "describe-services", "--cluster", $clusterArn, "--services") + $chunk + @("--include", "TAGS", "--region", $Region, "--output", "json")
            $descResp = Try-InvokeAwsJson -Args $descArgs -Context "ECS describe-services"
            if ($null -eq $descResp) { continue }
            foreach ($svc in $descResp.services) {
                $tags = Convert-TagsToMap -Tags (Get-PropertyOrDefault -Object $svc -Name "tags" -Default @())
                $status = Get-PropertyOrDefault -Object $svc -Name "status" -Default "UNKNOWN"
                $runningCount = Get-PropertyOrDefault -Object $svc -Name "runningCount" -Default 0
                $desiredCount = Get-PropertyOrDefault -Object $svc -Name "desiredCount" -Default 0
                $state = "$status running=$runningCount desired=$desiredCount"
                Add-Row -ResourceId $svc.serviceArn -ResourceType "ecs" -State $state -Name $svc.serviceName -Tags $tags -Arn $svc.serviceArn -Notes "cluster=$clusterArn"
            }
        }
    }
}

Write-Host "Collecting ALBs..."
$lbResp = Try-InvokeAwsJson -Args @("elbv2", "describe-load-balancers", "--region", $Region, "--output", "json") -Context "ELBv2 listing"
if ($null -ne $lbResp) {
    foreach ($lb in $lbResp.LoadBalancers) {
        $tagResp = Try-InvokeAwsJson -Args @("elbv2", "describe-tags", "--resource-arns", $lb.LoadBalancerArn, "--region", $Region, "--output", "json") -Context "ELB tags for $($lb.LoadBalancerArn)"
        $tags = if ($null -ne $tagResp -and $tagResp.TagDescriptions.Count -gt 0) { Convert-TagsToMap -Tags $tagResp.TagDescriptions[0].Tags } else { @{} }
        Add-Row -ResourceId $lb.LoadBalancerArn -ResourceType "alb" -State $lb.State.Code -Name $lb.LoadBalancerName -Tags $tags -Arn $lb.LoadBalancerArn -Notes "scheme=$($lb.Scheme)"
    }
}

Write-Host "Collecting EC2 instances..."
$ec2Resp = Try-InvokeAwsJson -Args @(
    "ec2", "describe-instances",
    "--region", $Region,
    "--filters", "Name=instance-state-name,Values=pending,running,stopping,stopped",
    "--output", "json"
) -Context "EC2 instance listing"
if ($null -ne $ec2Resp) {
    foreach ($reservation in $ec2Resp.Reservations) {
        foreach ($instance in $reservation.Instances) {
            $tags = Convert-TagsToMap -Tags (Get-PropertyOrDefault -Object $instance -Name "Tags" -Default @())
            $instanceName = if ($tags.ContainsKey("Name")) { $tags["Name"] } else { $instance.InstanceId }
            Add-Row -ResourceId $instance.InstanceId -ResourceType "ec2" -State $instance.State.Name -Name $instanceName -Tags $tags -Arn $instance.InstanceId -Notes "type=$($instance.InstanceType)"
        }
    }
}

Write-Host "Collecting NAT gateways..."
$natResp = Try-InvokeAwsJson -Args @(
    "ec2", "describe-nat-gateways",
    "--region", $Region,
    "--filter", "Name=state,Values=available,pending,deleting",
    "--output", "json"
) -Context "NAT gateway listing"
if ($null -ne $natResp) {
    foreach ($nat in $natResp.NatGateways) {
        $tags = Convert-TagsToMap -Tags (Get-PropertyOrDefault -Object $nat -Name "Tags" -Default @())
        Add-Row -ResourceId $nat.NatGatewayId -ResourceType "nat" -State $nat.State -Name $nat.NatGatewayId -Tags $tags -Arn $nat.NatGatewayId -Notes "vpc=$($nat.VpcId)"
    }
}

Write-Host "Collecting RDS instances..."
$rdsResp = Try-InvokeAwsJson -Args @("rds", "describe-db-instances", "--region", $Region, "--output", "json") -Context "RDS listing"
if ($null -ne $rdsResp) {
    foreach ($db in $rdsResp.DBInstances) {
        $tagResp = Try-InvokeAwsJson -Args @("rds", "list-tags-for-resource", "--resource-name", $db.DBInstanceArn, "--region", $Region, "--output", "json") -Context "RDS tags for $($db.DBInstanceIdentifier)"
        $tags = if ($null -ne $tagResp) { Convert-TagsToMap -Tags $tagResp.TagList } else { @{} }
        Add-Row -ResourceId $db.DBInstanceIdentifier -ResourceType "rds" -State $db.DBInstanceStatus -Name $db.DBInstanceIdentifier -Tags $tags -Arn $db.DBInstanceArn -Notes "engine=$($db.Engine)"
    }
}

Write-Host "Collecting ElastiCache replication groups..."
$cacheResp = Try-InvokeAwsJson -Args @("elasticache", "describe-replication-groups", "--region", $Region, "--output", "json") -Context "ElastiCache listing"
if ($null -ne $cacheResp) {
    foreach ($group in $cacheResp.ReplicationGroups) {
        $arn = Get-PropertyOrDefault -Object $group -Name "ARN" -Default ""
        $tagResp = if (-not [string]::IsNullOrWhiteSpace($arn)) {
            Try-InvokeAwsJson -Args @("elasticache", "list-tags-for-resource", "--resource-name", $arn, "--region", $Region, "--output", "json") -Context "ElastiCache tags for $($group.ReplicationGroupId)"
        } else {
            $null
        }
        $tags = if ($null -ne $tagResp) { Convert-TagsToMap -Tags $tagResp.TagList } else { @{} }
        Add-Row -ResourceId $group.ReplicationGroupId -ResourceType "elasticache" -State $group.Status -Name $group.ReplicationGroupId -Tags $tags -Arn $arn -Notes "engine=redis"
    }
}

Write-Host "Collecting ECR repositories..."
$ecrResp = Try-InvokeAwsJson -Args @("ecr", "describe-repositories", "--region", $Region, "--output", "json") -Context "ECR listing"
if ($null -ne $ecrResp) {
    foreach ($repo in $ecrResp.repositories) {
        $tagResp = Try-InvokeAwsJson -Args @("ecr", "list-tags-for-resource", "--resource-arn", $repo.repositoryArn, "--region", $Region, "--output", "json") -Context "ECR tags for $($repo.repositoryName)"
        $tags = if ($null -ne $tagResp) { Convert-TagsToMap -Tags $tagResp.tags } else { @{} }
        Add-Row -ResourceId $repo.repositoryName -ResourceType "ecr" -State "present" -Name $repo.repositoryName -Tags $tags -Arn $repo.repositoryArn -Notes "uri=$($repo.repositoryUri)"
    }
}

Write-Host "Collecting CloudWatch log groups..."
$logsResp = Try-InvokeAwsJson -Args @("logs", "describe-log-groups", "--region", $Region, "--output", "json") -Context "CloudWatch logs listing"
if ($null -ne $logsResp) {
    foreach ($logGroup in $logsResp.logGroups) {
        $logName = $logGroup.logGroupName
        if ($logName -notmatch "retail|feature-flag|workflow|wf-orch|streaming-etl") {
            continue
        }
        $retention = Get-PropertyOrDefault -Object $logGroup -Name "retentionInDays" -Default "never-expire"
        Add-Row -ResourceId $logName -ResourceType "logs" -State "present" -Name $logName -Arn $logName -Notes "retention_days=$retention"
    }
}

$inventory = $rows.ToArray() | Sort-Object project, service, resource_type, resource_id

$jsonPath = Join-Path $OutDir "inventory-$timestamp.json"
$csvPath = Join-Path $OutDir "inventory-$timestamp.csv"
$latestJsonPath = Join-Path $OutDir "latest-inventory.json"
$latestCsvPath = Join-Path $OutDir "latest-inventory.csv"

$inventory | ConvertTo-Json -Depth 8 | Set-Content -Path $jsonPath -Encoding utf8
$inventory | Export-Csv -Path $csvPath -NoTypeInformation
$inventory | ConvertTo-Json -Depth 8 | Set-Content -Path $latestJsonPath -Encoding utf8
$inventory | Export-Csv -Path $latestCsvPath -NoTypeInformation

Write-Host ""
Write-Host "Resource inventory summary by disposition:"
$inventory | Group-Object disposition | Select-Object Name, Count | Sort-Object Name | Format-Table -AutoSize

Write-Host ""
Write-Host "Resource inventory summary by project:"
$inventory | Group-Object project | Select-Object Name, Count | Sort-Object Name | Format-Table -AutoSize

$unowned = @($inventory | Where-Object { $_.project -eq "unknown" -or $_.owner -eq "unknown" })
$activeNonRetail = @($inventory | Where-Object {
    $_.project -ne "retail-forecast-dashboard" -and $_.state -match "running|ACTIVE|available|in-use|present|stopped|pending"
})

if ($unowned.Count -gt 0) {
    Write-Warning "Found $($unowned.Count) unowned/unknown resources."
}
if ($activeNonRetail.Count -gt 0) {
    Write-Warning "Found $($activeNonRetail.Count) active non-retail resources."
}

Write-Host ""
Write-Host "Wrote inventory artifacts to: $OutDir"

if ($FailOnUnowned -and $unowned.Count -gt 0) {
    Write-Error "Failing due to unowned/unknown resources."
    exit 2
}

if ($FailOnActiveNonRetail -and $activeNonRetail.Count -gt 0) {
    Write-Error "Failing due to active non-retail resources."
    exit 3
}

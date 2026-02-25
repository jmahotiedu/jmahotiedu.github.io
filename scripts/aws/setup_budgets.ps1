[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$AlertEmails,

    [Parameter()]
    [decimal]$MonthlyLimitUsd = 50,

    [Parameter()]
    [decimal]$DailyLimitUsd = 5,

    [Parameter()]
    [decimal]$AnomalyThresholdUsd = 5,

    [Parameter()]
    [string]$MonthlyBudgetName = "portfolio-monthly-cost",

    [Parameter()]
    [string]$DailyBudgetName = "portfolio-daily-cost",

    [Parameter()]
    [string]$AnomalyMonitorName = "portfolio-total-cost-monitor",

    [Parameter()]
    [string]$AnomalySubscriptionName = "portfolio-daily-anomaly-subscription",

    [Parameter()]
    [string]$Region = "us-east-1"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

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

function Invoke-AwsNoOutput {
    param([Parameter(Mandatory = $true)][string[]]$Args)
    $raw = & aws @Args 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "aws $($Args -join ' ') failed: $raw"
    }
}

function New-NotificationObject {
    param(
        [Parameter(Mandatory = $true)][decimal]$Threshold,
        [Parameter(Mandatory = $true)][string]$Type
    )
    return @{
        NotificationType   = $Type
        ComparisonOperator = "GREATER_THAN"
        Threshold          = [double]$Threshold
        ThresholdType      = "PERCENTAGE"
    }
}

function Ensure-Budget {
    param(
        [Parameter(Mandatory = $true)][string]$AccountId,
        [Parameter(Mandatory = $true)][string]$BudgetName,
        [Parameter(Mandatory = $true)][decimal]$LimitUsd,
        [Parameter(Mandatory = $true)][string]$TimeUnit,
        [Parameter(Mandatory = $true)][string[]]$Emails
    )

    $budgetObject = @{
        BudgetName  = $BudgetName
        BudgetType  = "COST"
        TimeUnit    = $TimeUnit
        BudgetLimit = @{
            Amount = "{0:N2}" -f [double]$LimitUsd
            Unit   = "USD"
        }
        CostTypes   = @{
            IncludeTax               = $true
            IncludeSubscription      = $true
            UseBlended               = $false
            IncludeRefund            = $false
            IncludeCredit            = $false
            IncludeUpfront           = $true
            IncludeRecurring         = $true
            IncludeOtherSubscription = $true
            IncludeSupport           = $true
            IncludeDiscount          = $true
            UseAmortized             = $false
        }
    }

    $existing = Try-InvokeAwsJson -Args @(
        "budgets", "describe-budget",
        "--account-id", $AccountId,
        "--budget-name", $BudgetName,
        "--output", "json"
    ) -Context "Describe budget $BudgetName"

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("aws-budget-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    try {
        $budgetFile = Join-Path $tempDir "budget.json"
        $budgetObject | ConvertTo-Json -Depth 10 | Set-Content -Path $budgetFile -Encoding ascii

        if ($null -eq $existing) {
            Write-Host "Creating budget: $BudgetName"
            Invoke-AwsNoOutput -Args @(
                "budgets", "create-budget",
                "--account-id", $AccountId,
                "--budget", "file://$budgetFile"
            )
        }
        else {
            Write-Host "Updating budget: $BudgetName"
            Invoke-AwsNoOutput -Args @(
                "budgets", "update-budget",
                "--account-id", $AccountId,
                "--new-budget", "file://$budgetFile"
            )
        }

        $existingNotificationsResp = Try-InvokeAwsJson -Args @(
            "budgets", "describe-notifications-for-budget",
            "--account-id", $AccountId,
            "--budget-name", $BudgetName,
            "--output", "json"
        ) -Context "Describe notifications for $BudgetName"

        $existingNotificationKeys = @{}
        if ($null -ne $existingNotificationsResp) {
            foreach ($n in $existingNotificationsResp.Notifications) {
                $thresholdType = if ($n.PSObject.Properties["ThresholdType"]) { $n.ThresholdType } else { "PERCENTAGE" }
                $thresholdValue = [double]$n.Threshold
                $key = "$($n.NotificationType)|$($n.ComparisonOperator)|$thresholdValue|$thresholdType"
                $existingNotificationKeys[$key] = $true
            }
        }

        $notificationTypes = if ($TimeUnit -eq "DAILY") { @("ACTUAL") } else { @("ACTUAL", "FORECASTED") }
        foreach ($threshold in @(50, 75, 90, 100)) {
            foreach ($notificationType in $notificationTypes) {
                $notification = New-NotificationObject -Threshold $threshold -Type $notificationType
                $thresholdValue = [double]$notification.Threshold
                $existingKey = "$($notification.NotificationType)|$($notification.ComparisonOperator)|$thresholdValue|$($notification.ThresholdType)"
                if ($existingNotificationKeys.ContainsKey($existingKey)) {
                    continue
                }

                $notificationSpec = @(
                    "NotificationType=$($notification.NotificationType)",
                    "ComparisonOperator=$($notification.ComparisonOperator)",
                    "Threshold=$($notification.Threshold)",
                    "ThresholdType=$($notification.ThresholdType)"
                ) -join ","

                try {
                    Invoke-AwsNoOutput -Args @(
                        "budgets", "create-notification",
                        "--account-id", $AccountId,
                        "--budget-name", $BudgetName,
                        "--notification", $notificationSpec,
                        "--subscribers", ("SubscriptionType=EMAIL,Address={0}" -f $Emails[0])
                    )
                }
                catch {
                    $message = $_.Exception.Message
                    if ($message -notmatch "DuplicateRecordException|already exists") {
                        Write-Warning "create-notification warning for $BudgetName threshold $threshold ($notificationType): $message"
                    }
                }

                for ($idx = 1; $idx -lt $Emails.Count; $idx++) {
                    $email = $Emails[$idx]
                    try {
                        Invoke-AwsNoOutput -Args @(
                            "budgets", "create-subscriber",
                            "--account-id", $AccountId,
                            "--budget-name", $BudgetName,
                            "--notification", $notificationSpec,
                            "--subscriber", ("SubscriptionType=EMAIL,Address={0}" -f $email)
                        )
                    }
                    catch {
                        $message = $_.Exception.Message
                        if ($message -notmatch "DuplicateRecordException|already exists") {
                            Write-Warning "create-subscriber warning for $BudgetName threshold $threshold ($notificationType) ${email}: $message"
                        }
                    }
                }
            }
        }
    }
    finally {
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Ensure-AnomalyMonitorAndSubscription {
    param(
        [Parameter(Mandatory = $true)][string]$MonitorName,
        [Parameter(Mandatory = $true)][string]$SubscriptionName,
        [Parameter(Mandatory = $true)][decimal]$ThresholdUsd,
        [Parameter(Mandatory = $true)][string[]]$Emails,
        [Parameter(Mandatory = $true)][string]$Region
    )

    $monitorArn = $null
    $monitorResp = Try-InvokeAwsJson -Args @("ce", "get-anomaly-monitors", "--region", $Region, "--output", "json") -Context "Get anomaly monitors"
    if ($null -ne $monitorResp) {
        foreach ($m in $monitorResp.AnomalyMonitors) {
            if ($m.MonitorName -eq $MonitorName) {
                $monitorArn = $m.MonitorArn
                break
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($monitorArn) -and $null -ne $monitorResp) {
        $defaultServiceMonitor = $monitorResp.AnomalyMonitors | Where-Object {
            $_.MonitorType -eq "DIMENSIONAL" -and $_.MonitorDimension -eq "SERVICE"
        } | Select-Object -First 1
        if ($null -ne $defaultServiceMonitor) {
            $monitorArn = $defaultServiceMonitor.MonitorArn
            Write-Host "Using existing service monitor: $($defaultServiceMonitor.MonitorName)"
        }
    }

    if ([string]::IsNullOrWhiteSpace($monitorArn)) {
        try {
            Write-Host "Creating anomaly monitor: $MonitorName"
            $monitorPayload = @{
                MonitorName      = $MonitorName
                MonitorType      = "DIMENSIONAL"
                MonitorDimension = "SERVICE"
            } | ConvertTo-Json -Compress

            $createMonitorResp = Invoke-AwsJson -Args @(
                "ce", "create-anomaly-monitor",
                "--region", $Region,
                "--anomaly-monitor", $monitorPayload,
                "--output", "json"
            )
            $monitorArn = $createMonitorResp.MonitorArn
        }
        catch {
            Write-Warning "Could not create anomaly monitor '$MonitorName': $($_.Exception.Message)"
            $fallbackResp = Try-InvokeAwsJson -Args @("ce", "get-anomaly-monitors", "--region", $Region, "--output", "json") -Context "Fallback get anomaly monitors"
            if ($null -ne $fallbackResp -and $fallbackResp.AnomalyMonitors.Count -gt 0) {
                $monitorArn = $fallbackResp.AnomalyMonitors[0].MonitorArn
                Write-Host "Falling back to existing monitor ARN: $monitorArn"
            }
        }
    }

    if ([string]::IsNullOrWhiteSpace($monitorArn)) {
        Write-Warning "Skipping anomaly subscription configuration because no monitor ARN is available."
        return
    }

    $subscribers = @()
    foreach ($email in $Emails) {
        $subscribers += "Address=$email,Type=EMAIL"
    }
    $subscribersArg = "[" + ($subscribers -join ",") + "]"

    $subResp = Try-InvokeAwsJson -Args @(
        "ce", "get-anomaly-subscriptions",
        "--region", $Region,
        "--output", "json"
    ) -Context "Get anomaly subscriptions"

    $existingSub = $null
    if ($null -ne $subResp) {
        foreach ($s in $subResp.AnomalySubscriptions) {
            if ($s.SubscriptionName -eq $SubscriptionName) {
                $existingSub = $s
                break
            }
        }
    }

    if ($null -eq $existingSub -and $null -ne $subResp -and $subResp.AnomalySubscriptions.Count -gt 0) {
        $existingSub = ($subResp.AnomalySubscriptions | Where-Object { $_.MonitorArnList -contains $monitorArn } | Select-Object -First 1)
    }
    if ($null -eq $existingSub -and $null -ne $subResp -and $subResp.AnomalySubscriptions.Count -gt 0) {
        $existingSub = ($subResp.AnomalySubscriptions | Select-Object -First 1)
    }
    if ($null -ne $existingSub) {
        Write-Host "Using existing anomaly subscription for update: $($existingSub.SubscriptionName)"
    }

    if ($null -ne $existingSub) {
        Write-Host "Anomaly subscription already exists: $($existingSub.SubscriptionName)"
        return
    }

    if ($null -eq $existingSub) {
        try {
            Write-Host "Creating anomaly subscription: $SubscriptionName"
            Invoke-AwsNoOutput -Args @(
                "ce", "create-anomaly-subscription",
                "--region", $Region,
                "--anomaly-subscription",
                "SubscriptionName=$SubscriptionName,Frequency=DAILY,MonitorArnList=[$monitorArn],Subscribers=$subscribersArg,Threshold=$([double]$ThresholdUsd)"
            )
        }
        catch {
            Write-Warning "Could not create anomaly subscription '$SubscriptionName': $($_.Exception.Message)"
        }
    }
}

Assert-Command -Name "aws"

if ($AlertEmails.Count -eq 0) {
    throw "At least one email is required in -AlertEmails."
}

$identity = Invoke-AwsJson -Args @("sts", "get-caller-identity", "--output", "json")
$accountId = $identity.Account

Write-Host "Configuring AWS budgets and anomaly alerts for account: $accountId"

Ensure-Budget -AccountId $accountId -BudgetName $MonthlyBudgetName -LimitUsd $MonthlyLimitUsd -TimeUnit "MONTHLY" -Emails $AlertEmails
Ensure-Budget -AccountId $accountId -BudgetName $DailyBudgetName -LimitUsd $DailyLimitUsd -TimeUnit "DAILY" -Emails $AlertEmails

Ensure-AnomalyMonitorAndSubscription `
    -MonitorName $AnomalyMonitorName `
    -SubscriptionName $AnomalySubscriptionName `
    -ThresholdUsd $AnomalyThresholdUsd `
    -Emails $AlertEmails `
    -Region $Region

Write-Host "Budgets and anomaly alerts are configured."

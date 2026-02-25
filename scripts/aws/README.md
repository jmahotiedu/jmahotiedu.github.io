# AWS Cost Tooling

This directory contains cost-governance scripts used by the portfolio repo.

## Scripts

- `cost_export.ps1`
  - Pulls Cost Explorer data by service (and optional `Project` tag grouping).
  - Writes timestamped CSV/JSON reports under `reports/aws-cost/`.

- `inventory_export.ps1`
  - Builds a cross-service inventory for active resources and classifies each as `keep`, `delete`, or `investigate`.
  - Includes `resource_id`, `service`, `project`, `owner`, `state`, and a service-level `monthly_cost_estimate`.
  - Supports CI guardrail flags:
    - `-FailOnUnowned`
    - `-FailOnActiveNonRetail`

- `setup_budgets.ps1`
  - Creates/updates monthly and daily AWS Budgets with email subscribers.
  - Creates/updates a Cost Anomaly Detection monitor + subscription.

## Usage

```powershell
# Service-level cost export (Jan 1 -> Feb 25, 2026)
powershell -ExecutionPolicy Bypass -File .\scripts\aws\cost_export.ps1 `
  -StartDate 2026-01-01 `
  -EndDate 2026-02-25 `
  -IncludeProjectTagBreakdown

# Resource inventory + keep/delete recommendations
powershell -ExecutionPolicy Bypass -File .\scripts\aws\inventory_export.ps1 `
  -Region us-east-1

# Configure budgets + anomaly alerts
powershell -ExecutionPolicy Bypass -File .\scripts\aws\setup_budgets.ps1 `
  -AlertEmails "you@example.com","team@example.com" `
  -MonthlyLimitUsd 50 `
  -DailyLimitUsd 5 `
  -AnomalyThresholdUsd 5
```

## Output

Reports are written to `reports/aws-cost/` as both timestamped and `latest-*` files:

- `latest-cost-by-service.csv`
- `latest-cost-by-service.json`
- `latest-cost-by-project-tag.csv` (when requested)
- `latest-inventory.csv`
- `latest-inventory.json`

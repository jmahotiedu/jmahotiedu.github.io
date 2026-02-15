# Jared Mahotiere

**Software Engineer** - .NET & full-stack web, embedded systems, data engineering - Purdue EET '26

[LinkedIn](https://linkedin.com/in/jared-mahotiere) - [GitHub](https://github.com/jmahotiedu) - [Interactive portfolio](https://jmahotiedu.github.io/jmahotiedu/)

---

## About

Entry-level SWE: .NET and full-stack web (real-time dashboards, SQL optimization 70-90%, CI/testing), data science & engineering (Kafka, Spark, Airflow, ML forecasting), plus embedded systems (ESP32, FreeRTOS, binary protocols). Shipped production Next.js disaster-relief site; portfolio includes a live ML forecasting dashboard on AWS, a real-time streaming ETL pipeline, SLO-driven feature flag platform, Redis-like cache (C), real-time Kanban (Next.js/PostgreSQL), and ESP32 telemetry logger.

## Experience

**Nucor Corporation** - *Software / Automation Engineering Intern* | Darlington, SC | May-Aug 2024; May-Aug 2025

- Shipped Blazor/.NET real-time operator dashboards; improved process visibility with resilient UI state and consolidated KPI views.
- Built C#/.NET services integrating SQL Server and QMOS; cut critical report runtimes by 70-90% via indexing and query refactors.
- Delivered automated reporting/alerting with Quartz.NET (idempotency, retry/backoff) and migrated legacy Visual Basic apps to .NET/Blazor.
- Added ~240 unit/integration tests (xUnit) and CI quality gates; health checks and structured logging for deployment confidence.

## Projects

| Project | Stack | Link |
|--------|--------|------|
| **Retail Sales Forecasting Dashboard** | Python, scikit-learn, XGBoost, Prophet, Streamlit, FastAPI, AWS ECS, Terraform | [GitHub](https://github.com/jmahotiedu/retail-forecast-dashboard) / [Live](http://retail-forecast-alb-104304097.us-east-1.elb.amazonaws.com) |
| **IoT Streaming ETL Pipeline** | PySpark, Kafka, Airflow, Redshift, Great Expectations, Prometheus, Grafana, Terraform | [GitHub](https://github.com/jmahotiedu/streaming-etl-pipeline) |
| **cachekit** | C (C11), POSIX, RESP | [GitHub](https://github.com/jmahotiedu/cachekit) |
| **workflow-orchestrator** | TypeScript, Node.js, Postgres, Redis Streams, React | [GitHub](https://github.com/jmahotiedu/wf-orch) |
| **Telemetry Node** | ESP32, FreeRTOS, C, Python | [GitHub](https://github.com/jmahotiedu/telemetry-node) |
| **syncboard** | Next.js 15, Socket.io, PostgreSQL, Prisma, NextAuth | [GitHub](https://github.com/jmahotiedu/syncboard) |
| **Help Westmoreland** | Next.js 16, React 19, TypeScript, Tailwind v4 | [Live](https://jmahotiedu-help-westmoreland.vercel.app) |
| **Feature Flag Platform** | TypeScript, Node.js, Redis, React | [GitHub](https://github.com/jmahotiedu/feature-flag-platform) |

### Retail Sales Forecasting highlights

- XGBoost model achieving 11% MAPE and R² = 0.91 on 6-week holdout across 1,115 stores
- K-means segmentation producing 4 actionable store clusters (silhouette > 0.4)
- Interactive 4-page Streamlit dashboard + FastAPI /predict endpoint, deployed on AWS ECS Fargate
- 20+ engineered features: lag, rolling stats, holiday flags, competition proximity, promo duration

### IoT Streaming ETL Pipeline highlights

- 100+ events/sec Kafka ingestion with PySpark Structured Streaming (10-min watermark, dead-letter queue)
- Medallion data lake (Bronze/Silver/Gold) with z-score anomaly detection and data lineage tracking
- Airflow orchestration with SLA monitoring, data freshness sensors, and Slack alerts
- Great Expectations validation at every layer; Grafana dashboard with 11 panels and 7 alert rules

### workflow-orchestrator highlights

- Distributed execution + retries/dead-letter
- Scheduling + idempotent triggers
- Observability + incident drill/postmortem

### Feature Flag Platform highlights

- Multi-tenant control-plane with deterministic rule + percentage rollout evaluation
- JavaScript SDK with local cache and refresh loop; admin UI for flag CRUD/publish
- Idempotency middleware, RBAC, tenant quota controls, and audit logging


## Pull Request Contributions

- **sipeed/picoclaw** - [PR #213](https://github.com/sipeed/picoclaw/pull/213) _(Status: Open)_: refactored provider architecture by protocol family (discussion #122); restructured Anthropic and OpenAI-compat providers into dedicated packages with isolated tests. +1,484/-676 across 11 files.
- **sipeed/picoclaw** - [PR #211](https://github.com/sipeed/picoclaw/pull/211) _(Status: Open)_: security hardening (#179) and default model/CI fixes (#199); added config validation, Slack channel sanitization, cron service hardening, and expanded test coverage. +326/-39 across 11 files.
- **sipeed/picoclaw** - [PR #56](https://github.com/sipeed/picoclaw/pull/56) _(Status: Merged)_: fixed OpenAI device-code auth parsing for string/numeric poll intervals with targeted tests and clearer headless guidance.
- **databricks/cli** - [PR #4504](https://github.com/databricks/cli/pull/4504) _(Status: Open)_: fixed non-bundle auth resolution so workspace commands no longer implicitly use bundle default targets over environment credentials; preserved explicit target behavior and added regression tests.
- **databricks/cli** - [PR #4495](https://github.com/databricks/cli/pull/4495) _(Status: Closed)_: fixed AppKit TypeScript tRPC template usage by replacing unsupported request-context calls with `WorkspaceClient`.
- **databricks/databricks-sdk-py** - [PR #1258](https://github.com/databricks/databricks-sdk-py/pull/1258) _(Status: Open)_: fixed `Config` subclass attribute discovery/caching for inherited `ConfigAttribute` fields with regression coverage.
- **bloomberg/comdb2** - [PR #5731](https://github.com/bloomberg/comdb2/pull/5731) _(Status: Open)_: preserved JDBC metadata cursors by isolating version lookup from active `getTables()` result-set flow.
- **google/langextract** - [PR #359](https://github.com/google/langextract/pull/359) _(Status: Open)_: fixed Gemini batch cache hashing for Enum/dataclass settings with deterministic regression tests.

### PR status sync

- Local: `powershell -ExecutionPolicy Bypass -File .\sync-pr-status.ps1 -RepoRoot .`
- Automated: `.github/workflows/sync-pr-status.yml` runs every 6 hours and on manual dispatch, then commits status changes when needed.

## Skills

**Languages:** C#, TypeScript, Java, Python, C, C++
**Frontend:** Next.js, React, Tailwind, accessibility, SEO
**Data:** pandas, scikit-learn, XGBoost, Prophet, PySpark, Kafka, Airflow, Redshift, Great Expectations, Streamlit
**Embedded:** ESP32, FreeRTOS, Arduino, I2C, ADC, drivers, PID, PWM, binary protocols
**Backend/DB:** .NET (ASP.NET Core, Blazor), REST/gRPC, SQL Server, PostgreSQL, Prisma, Redis, NextAuth, Socket.io
**Cloud/DevOps:** AWS (S3, ECR, ECS, Redshift, MSK, EMR, MWAA, CloudFront, Route 53), Terraform, Docker, GitHub Actions
**Testing:** xUnit, pytest, Great Expectations

## Leadership

- **Delta Tau Delta** | DEI Chair | Aug 2024 - Present - Launched mentorship and campus programs; repeatable onboarding and engagement playbooks.
- **NSBE** | Member | Sep 2022 - Present - Team-based engineering projects in C#, Java, Python; recruiting and community initiatives.

## Contact

Bear, DE | [jmahotie@purdue.edu](mailto:jmahotie@purdue.edu) | (302) 803-7673

Open to roles in software engineering, data engineering, full-stack, and embedded systems.

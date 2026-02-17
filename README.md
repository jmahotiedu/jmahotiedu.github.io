# Jared Mahotiere

**Software Engineer** - .NET & full-stack web, embedded systems, data engineering - Purdue EET '26

[LinkedIn](https://www.linkedin.com/in/jared-mahotiere) - [GitHub](https://github.com/jmahotiedu) - [Interactive portfolio](https://jmahotiedu.github.io/jmahotiedu/) - [Resume (Backend PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Backend_Resume.pdf)

---

## About

Software engineer graduating May 2026 from Purdue (BS EET, Computer Engineering Tech). Two summers at Nucor building production .NET services, real-time dashboards, and automated reporting systems in steel manufacturing.

**Available for full-time roles starting May 2026.**

- **.NET & Full-Stack**: Blazor dashboards, SQL Server optimization, Quartz.NET automated reporting, VB-to-.NET migrations
- **Data Engineering**: Kafka/Spark/Airflow pipelines, ML forecasting (XGBoost, Prophet), AWS ECS deployments
- **Embedded Systems**: ESP32/FreeRTOS firmware, binary protocols, DSP, industrial controls
- **Systems Programming**: Redis-like cache in C, distributed workflow orchestrator, POSIX networking

## Experience

**Nucor Corporation** - *Software / Automation Engineering Intern* | Darlington, SC | May-Aug 2024; May-Aug 2025

- Developed and maintained Blazor/.NET real-time operator dashboards and robust back-end services, enhancing process transparency and improving steel production workflows.
- Led system integration projects: scoped, specified, and coordinated implementation of new automation systems, ensuring seamless startup, cross-team adoption, and operational reliability.
- Managed and analyzed production data in SQL Server/QMOS databases; developed optimized queries and recommended new tables/columns to support process improvement.
- Built automated reporting and alert systems using Quartz.NET with real-time email notifications for maintenance and quality events, reducing manual monitoring and accelerating issue response.
- Migrated legacy Visual Basic applications to .NET/Blazor, reducing technical debt and supporting future scalability/maintainability; utilized Git for code management across concurrent streams, peer code reviews, and codebase integrity.
- Collaborated with production teams and led project meetings; conducted comprehensive testing and validation with multi-disciplinary stakeholders while prioritizing deliverables and shipping on time with high safety and quality standards.

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

- Distributed execution engine: 25/25 runs in 15.94s (1.57 runs/s) with 0 failures
- DAG validation, Redis Streams consumer groups, and Postgres durable run/task state
- Lease/heartbeat recovery with retry/backoff, dead-letter routing, and idempotency-key dedupe
- Scheduling with cron triggers + observability (incident drill and postmortem runbook)

### Feature Flag Platform highlights

- Multi-tenant control-plane with deterministic rule + percentage rollout evaluation
- JavaScript SDK with local cache and refresh loop; admin UI for flag CRUD/publish
- Idempotency middleware, RBAC, tenant quota controls, and audit logging
- Load-test harness, operations docs, and live end-to-end smoke test suite


## Pull Request Contributions

- **sipeed/picoclaw** - [PR #213](https://github.com/sipeed/picoclaw/pull/213) _(Status: Open)_: refactored providers by protocol family (discussion #122) and completed review-requested hardening (shared protocol types, Anthropic `api_base` propagation, compatibility adapters, and expanded auth/routing/proxy test coverage). +1,791/-770 across 13 files.
- **sipeed/picoclaw** - [PR #211](https://github.com/sipeed/picoclaw/pull/211) _(Status: Open)_: security hardening (#179) and default model/CI fixes (#199); added config validation, Slack channel sanitization, cron service hardening, and expanded test coverage. +326/-39 across 11 files.
- **sipeed/picoclaw** - [PR #56](https://github.com/sipeed/picoclaw/pull/56) _(Status: Merged)_: fixed OpenAI device-code auth parsing for string/numeric poll intervals with targeted tests and clearer headless guidance.
- **databricks/cli** - [PR #4504](https://github.com/databricks/cli/pull/4504) _(Status: Open)_: fixed non-bundle auth resolution so workspace commands no longer implicitly use bundle default targets over environment credentials; preserved explicit target behavior and added regression tests.
- **databricks/cli** - [PR #4495](https://github.com/databricks/cli/pull/4495) _(Status: Closed)_: fixed AppKit TypeScript tRPC template usage by replacing unsupported request-context calls with `WorkspaceClient`.
- **databricks/databricks-sdk-py** - [PR #1258](https://github.com/databricks/databricks-sdk-py/pull/1258) _(Status: Open)_: fixed `Config` subclass attribute discovery/caching for inherited `ConfigAttribute` fields with regression coverage.
- **bloomberg/comdb2** - [PR #5731](https://github.com/bloomberg/comdb2/pull/5731) _(Status: Open)_: preserved JDBC metadata cursors by isolating version lookup from active `getTables()` result-set flow.
- **google/langextract** - [PR #359](https://github.com/google/langextract/pull/359) _(Status: Open)_: fixed Gemini batch cache hashing for Enum/dataclass settings with deterministic regression tests.

<details>
<summary>PR status sync</summary>

- Local: `powershell -ExecutionPolicy Bypass -File .\sync-pr-status.ps1 -RepoRoot .`
- Automated: `.github/workflows/sync-pr-status.yml` runs every 6 hours and on manual dispatch, then commits status changes when needed.

</details>

## Education

**Purdue University** - *B.S. Electrical Engineering Technology (Computer Engineering Technology)* | Minor: Computer & IT | Certificate: Entrepreneurship & Innovation | Expected May 2026

**Relevant Coursework:** Embedded Digital Systems, Advanced Embedded Systems, DSP, Advanced DSP, Industrial Controls, DAQ, Wireless Communications, Systems Development, IT Architecture, Network Engineering, Electronic Prototype Development, Concurrent Digital Systems

## Skills

**Languages:** C#, TypeScript, Java, Python, C, C++
**Frontend:** Next.js, React, Tailwind, accessibility, SEO
**Data:** pandas, scikit-learn, XGBoost, Prophet, PySpark, Kafka, Airflow, Redshift, Great Expectations, Streamlit
**Embedded:** ESP32, FreeRTOS, Arduino, I2C, ADC, drivers, PID, PWM, binary protocols
**Backend/DB:** .NET (ASP.NET Core, Blazor), REST/gRPC, SQL Server, PostgreSQL, Prisma, Redis, NextAuth, Socket.io
**Cloud/DevOps:** AWS (S3, ECR, ECS, Redshift, MSK, EMR, MWAA, CloudFront, Route 53), Terraform, Docker, GitHub Actions
**Testing:** xUnit, pytest, Great Expectations

## Leadership

- **Delta Tau Delta** | DEI Chair | Aug 2024 - Present - Led mentorship programs pairing 15+ new members with upperclassmen; organized campus inclusion events and designed repeatable onboarding playbooks.
- **NSBE** | Member | Sep 2022 - Present - Collaborated on team engineering projects in C#, Java, and Python; supported recruiting at career fairs and community outreach.

## Contact

Bear, DE | [jmahotie@purdue.edu](mailto:jmahotie@purdue.edu)

Open to roles in software engineering, data engineering, full-stack, and embedded systems.


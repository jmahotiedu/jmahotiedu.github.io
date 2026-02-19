# Jared Mahotiere

Software Engineer - .NET, full-stack systems, data engineering, embedded systems - Purdue EET '26

[LinkedIn](https://www.linkedin.com/in/jared-mahotiere) - [GitHub](https://github.com/jmahotiedu) - [Interactive Portfolio](https://jmahotiedu.github.io/) - [Resume](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Data_Engineer_Resume.pdf)

---

## About

Software engineer graduating in May 2026 from Purdue University (BS Electrical Engineering Technology, Computer Engineering Technology concentration). Two summers at Nucor building production .NET services, real-time operator dashboards, and automated reporting for steel manufacturing operations.

Open to full-time software roles starting May 2026.

- .NET and Full-Stack: Blazor, ASP.NET Core, SQL Server optimization, automation tooling
- Data and ML Engineering: Kafka/Spark/Airflow pipelines, forecasting (XGBoost/Prophet), production APIs
- Systems and Reliability: distributed orchestration, idempotency, retries, observability
- Embedded and Firmware: ESP32/FreeRTOS, binary protocols, DSP, controls

## Cloud Deployment Snapshot (Updated February 19, 2026)

| Project | Status | Public Endpoint | Infra |
|--------|--------|-----------------|-------|
| Retail Forecast Dashboard | Live | http://retail-forecast-alb-104304097.us-east-1.elb.amazonaws.com | ECS Fargate, ALB, ECR, Terraform |
| Feature Flag Platform | Live | http://feature-flag-demo-alb-1145770048.us-east-1.elb.amazonaws.com | ECS Fargate (API/UI), RDS, ElastiCache, ALB, Terraform |
| Workflow Orchestrator | Live | http://workflow-orc-demo-alb-1577468805.us-east-1.elb.amazonaws.com | ECS Fargate (API/worker/UI), RDS, ElastiCache, ALB, Terraform |
| Streaming ETL Pipeline | Core mode live (public shell live) | http://streaming-etl-dash-demo-1722592003.us-east-1.elb.amazonaws.com | Core Terraform path (MSK/S3/VPC/ECR) with public ECS/ALB shell live; full EMR/MWAA/Redshift path remains gated by account subscription enablement |

Health and functional checks run on February 19, 2026:
- Retail root: `200`
- Feature Flag `/api/health`: `200`
- Feature Flag `/api/flags` with token + tenant: `200`
- Feature Flag `/api/tenants/tenant-a/quotas` with token + tenant: `200`
- Workflow Orchestrator `/api/health`: `200`
- Workflow Orchestrator `/api/workflows` with token: `200`
- Workflow live seed flow (`npm run demo:live-seed`): create/trigger succeeded
- Streaming ETL shell root: `200`

## Experience

**Nucor Corporation** - Software / Automation Engineering Intern  
Darlington, SC | May-Aug 2024 and May-Aug 2025

- Built and maintained Blazor/.NET real-time dashboards and backend services used by operators in production.
- Led automation integration efforts from scoping/specification through startup and handoff.
- Optimized SQL Server/QMOS data workflows with improved queries and schema recommendations.
- Delivered automated Quartz.NET reporting and alerts that reduced manual monitoring.
- Migrated legacy VB tooling to .NET/Blazor, reducing technical debt and improving maintainability.
- Coordinated testing/validation with cross-functional teams while meeting safety and delivery targets.

## Selected Projects

| Project | Stack | Links |
|--------|-------|-------|
| Workflow Orchestrator | TypeScript, Node.js, Redis Streams, Postgres, React | [GitHub](https://github.com/jmahotiedu/wf-orch) / [Live](http://workflow-orc-demo-alb-1577468805.us-east-1.elb.amazonaws.com) |
| IoT Streaming ETL Pipeline | Kafka, PySpark, Airflow, Redshift, Terraform | [GitHub](https://github.com/jmahotiedu/streaming-etl-pipeline) / [Live Shell](http://streaming-etl-dash-demo-1722592003.us-east-1.elb.amazonaws.com) |
| Retail Forecast Dashboard | Python, XGBoost, FastAPI, Streamlit, AWS ECS | [GitHub](https://github.com/jmahotiedu/retail-forecast-dashboard) / [Live](http://retail-forecast-alb-104304097.us-east-1.elb.amazonaws.com) |
| Feature Flag Platform | TypeScript, Node.js, Redis, React, Terraform | [GitHub](https://github.com/jmahotiedu/feature-flag-platform) / [Live](http://feature-flag-demo-alb-1145770048.us-east-1.elb.amazonaws.com) |
| cachekit | C11, POSIX, RESP | [GitHub](https://github.com/jmahotiedu/cachekit) |
| Telemetry Node | ESP32, FreeRTOS, C, Python | [GitHub](https://github.com/jmahotiedu/telemetry-node) |

## Project Highlights

### Retail Forecast Dashboard
- Forecasting pipeline with XGBoost achieving 11% MAPE and R^2 = 0.91.
- Production deployment on AWS ECS Fargate behind ALB.
- API/model workflows with 90%+ automated test coverage.

### Workflow Orchestrator
- Distributed DAG execution with durable run/task state and Redis Streams workers.
- Benchmark: 25/25 successful runs in 15.94s (1.57 runs/s).
- Deployed on ECS Fargate with ALB, RDS Postgres, and ElastiCache Redis.
- Live UI now supports create-workflow and trigger-run flows with deterministic seed tooling.

### Feature Flag Platform
- Multi-tenant control plane, deterministic rollout logic, idempotency, and RBAC.
- Admin UI plus SDK caching/refresh semantics for client-side evaluation.
- Deployed on ECS Fargate with ALB, RDS Postgres, and ElastiCache Redis.
- Live UI now supports explicit token/tenant context, seed flow, and verified create/publish/rollback behavior.

### Streaming ETL Pipeline
- 100+ events/sec ingestion with Kafka and Spark Structured Streaming.
- Medallion (Bronze/Silver/Gold) pipeline plus quality validation and monitoring.
- Core mode is deployed today with a public shell URL live; full EMR/MWAA/Redshift remains entitlement-gated.

## Open Source Contributions

- **sipeed/picoclaw** - [PR #213](https://github.com/sipeed/picoclaw/pull/213) _(Status: Merged)_: provider protocol-family refactor and hardening follow-ups.
- **sipeed/picoclaw** - [PR #56](https://github.com/sipeed/picoclaw/pull/56) _(Status: Merged)_: OpenAI device-code auth interval parsing fix.
- **sipeed/picoclaw** - [PR #211](https://github.com/sipeed/picoclaw/pull/211) _(Status: Open)_: security/model hardening and CI reliability updates.
- **bloomberg/comdb2** - [PR #5743](https://github.com/bloomberg/comdb2/pull/5743) _(Status: Open)_: targeted SQLite security backports with verification matrix.
- **bloomberg/comdb2** - [PR #5731](https://github.com/bloomberg/comdb2/pull/5731) _(Status: Open)_: JDBC metadata cursor isolation fix.
- **databricks/cli** - [PR #4504](https://github.com/databricks/cli/pull/4504) _(Status: Open)_: auth-resolution bug fix for non-bundle workspace commands.

PR status sync:
- Local: `powershell -ExecutionPolicy Bypass -File .\sync-pr-status.ps1 -RepoRoot .`
- Automated: `.github/workflows/sync-pr-status.yml`

## Education

**Purdue University**  
B.S. Electrical Engineering Technology (Computer Engineering Technology)  
Minor: Computer & IT | Certificate: Entrepreneurship & Innovation | Expected May 2026

Relevant coursework: Embedded Digital Systems, Advanced Embedded Systems, DSP, Advanced DSP, Industrial Controls, DAQ, Wireless Communications, Systems Development, IT Architecture, Network Engineering.

## Skills

- Languages: C#, TypeScript, Python, Java, C, C++
- Backend: .NET, ASP.NET Core, Node.js, REST, gRPC, SQL Server, PostgreSQL, Redis
- Data: Kafka, PySpark, Airflow, pandas, scikit-learn, XGBoost, Prophet, Great Expectations
- Cloud/DevOps: AWS (ECS, ECR, ALB, RDS, ElastiCache, S3, MSK, EMR, MWAA, Redshift), Terraform, Docker, GitHub Actions
- Embedded: ESP32, FreeRTOS, UART/I2C/SPI, ADC/PWM, DSP, controls
- Testing: xUnit, pytest, integration/load testing, CI pipelines

## Resume Variants

- [Backend Resume (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Backend_Resume.pdf)
- [Data Engineer Resume (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Data_Engineer_Resume.pdf)
- [.NET/Industrial Resume (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_DotNet_Industrial_Resume.pdf)
- [Embedded Resume (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Embedded_Resume.pdf)

## Contact

Bear, DE | [jmahotie@purdue.edu](mailto:jmahotie@purdue.edu)

Open to software engineering, data engineering, full-stack, backend, and embedded systems roles.

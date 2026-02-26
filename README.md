# Jared Mahotiere

**Software Engineer** | .NET, Full-Stack, Data Engineering, Embedded Systems | Purdue EET '26

[LinkedIn](https://www.linkedin.com/in/jared-mahotiere) | [Portfolio](https://jmahotiedu.github.io/) | [GitHub](https://github.com/jmahotiedu) | [Resume (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Backend_Resume.pdf)

---

## About

Software engineer graduating May 2026 from Purdue University (BS EET, Computer Engineering Technology). Two summers at **Nucor Corporation** building production .NET services, real-time operator dashboards, and automated reporting for steel manufacturing. Built and deployed four portfolio systems to AWS (ECS Fargate, Terraform IaC) with full health verification before teardown.

**Available for full-time roles starting May 2026.**

**Core strengths:**
- **.NET and Full-Stack** -- Blazor dashboards, ASP.NET Core APIs, SQL Server optimization, Quartz.NET automation
- **Data Engineering** -- Kafka/Spark/Airflow pipelines, ML forecasting (XGBoost R^2=0.91, 11% MAPE), FastAPI serving
- **Cloud and Infrastructure** -- AWS (ECS, RDS, ElastiCache, MSK, ALB), Terraform, Docker, GitHub Actions CI/CD
- **Systems Programming** -- Redis-like cache in C (Robin Hood hashing, RESP protocol), distributed workflow orchestrator
- **Embedded** -- ESP32/FreeRTOS firmware, binary protocols, DSP, industrial controls

---

## Experience

**Nucor Corporation** -- Software / Automation Engineering Intern  
Darlington, SC | May--Aug 2024, May--Aug 2025

- Developed Blazor/.NET real-time operator dashboards and backend services used daily in steel production.
- Led automation integration from scoping through startup and cross-team handoff.
- Optimized SQL Server/QMOS queries and recommended schema changes to support process improvement.
- Built Quartz.NET automated reporting with real-time email alerts, reducing manual monitoring.
- Migrated legacy VB applications to .NET/Blazor, cutting technical debt across concurrent codebases.

---

## Projects

### Retail Forecast Dashboard -- [GitHub](https://github.com/jmahotiedu/retail-forecast-dashboard) | [Live](http://retail-forecast-alb-104304097.us-east-1.elb.amazonaws.com)
`Python | FastAPI | XGBoost | Streamlit | AWS ECS Fargate | Terraform`
- End-to-end ML forecasting platform: XGBoost R^2 = 0.91, ~11% MAPE.
- Deployed on ECS Fargate behind ALB with Terraform-managed infra. **Currently live.**
- 90%+ automated test coverage across API and model workflows.

### Workflow Orchestrator -- [GitHub](https://github.com/jmahotiedu/wf-orch)
`TypeScript | Node.js | Redis Streams | PostgreSQL | React | AWS ECS`
- Distributed DAG engine with durable run/task state, idempotent retries, and dead-letter handling.
- Benchmarked 25/25 successful runs in 15.94s (1.57 runs/s).
- Deployed and verified on ECS Fargate (ALB, RDS, ElastiCache); teardown scripted via Terraform.

### Feature Flag Platform -- [GitHub](https://github.com/jmahotiedu/feature-flag-platform)
`TypeScript | Node.js | React | PostgreSQL | Redis | AWS ECS | Terraform`
- Multi-tenant control plane with deterministic rollout, RBAC, idempotent writes, and publish/rollback.
- Smoke-tested create/publish/rollback flows on live ECS deployment before teardown.

### IoT Streaming ETL Pipeline -- [GitHub](https://github.com/jmahotiedu/streaming-etl-pipeline)
`Kafka | PySpark | Airflow | Great Expectations | Terraform | AWS`
- 100+ events/sec ingestion with Bronze/Silver/Gold medallion architecture and checkpointed recovery.
- Prometheus/Grafana observability; Terraform-provisioned AWS infra (MSK, S3, VPC, ECR).

### cachekit -- [GitHub](https://github.com/jmahotiedu/cachekit)
`C (C11) | POSIX | TCP | RESP`
- Redis-like in-memory cache server: Robin Hood hashing, approximate LRU eviction, O(1) average access.
- TTL expiration, RESP parsing, RDB snapshots; ASan + Valgrind CI. Benchmarked at 10k SET/GET pairs per trial.

### Help Westmoreland -- [GitHub](https://github.com/jmahotiedu/help-westmoreland) | [Live](https://jmahotiedu-help-westmoreland.vercel.app)
`Next.js 16 | React 19 | TypeScript | Tailwind v4`
- Production disaster-relief platform: 3 intake flows, Donorbox donation integration, GA4 instrumentation.
- SEO baseline with JSON-LD, sitemap automation, and Open Graph/Twitter cards.

### syncboard -- [GitHub](https://github.com/jmahotiedu/syncboard)
`Next.js 15 | Socket.io | PostgreSQL | Prisma | NextAuth`
- Real-time collaborative Kanban: optimistic UI, Socket.IO sync, reconnect/offline handling, presence tracking.

### Telemetry Node -- [GitHub](https://github.com/jmahotiedu/telemetry-node)
`ESP32 | FreeRTOS | C | Python`
- Embedded telemetry logger: 25-byte UART frames with CRC16, 9 sensor fields, Python CSV decode tooling.

---

## Open Source Contributions

### Merged

| Repo | PR | Summary |
|------|----|---------|
| **sipeed/picoclaw** | [#213](https://github.com/sipeed/picoclaw/pull/213) | Provider protocol-family refactor with compatibility adapters and expanded test coverage (+1,484/-676 across 11 files) |
| **sipeed/picoclaw** | [#56](https://github.com/sipeed/picoclaw/pull/56) | Device-code auth interval parsing fix with targeted regression tests |

### Open

| Repo | PR | Summary |
|------|----|---------|
| **bloomberg/comdb2** | [#5743](https://github.com/bloomberg/comdb2/pull/5743) | SQLite security backports with source-build validation and published verification matrix |
| **bloomberg/comdb2** | [#5731](https://github.com/bloomberg/comdb2/pull/5731) | JDBC metadata cursor isolation fix preventing iterator invalidation in getTables() |
| **databricks/cli** | [#4504](https://github.com/databricks/cli/pull/4504) | Fixed non-bundle auth resolution for workspace commands with regression tests |
| **databricks/databricks-sdk-py** | [#1258](https://github.com/databricks/databricks-sdk-py/pull/1258) | Config subclass attribute discovery fix for inherited ConfigAttribute fields |
| **google/langextract** | [#359](https://github.com/google/langextract/pull/359) | Stabilized cache-key hashing for Enum/dataclass serialization in batch processing |
| **sipeed/picoclaw** | [#251](https://github.com/sipeed/picoclaw/pull/251) | Telegram channel reliability: chunked outputs, placeholder sequencing, fallback tests (+850/-88) |
| **sipeed/picoclaw** | [#211](https://github.com/sipeed/picoclaw/pull/211) | Security hardening and CI reliability improvements (+285/-22) |

---

## Skills

| Category | Technologies |
|----------|-------------|
| **Languages** | C#, TypeScript, Python, Java, C, C++ |
| **Backend** | .NET / ASP.NET Core / Blazor, Node.js, REST, gRPC, SQL Server, PostgreSQL, Redis |
| **Data** | Kafka, PySpark, Airflow, pandas, scikit-learn, XGBoost, Prophet, Great Expectations |
| **Cloud / DevOps** | AWS (ECS, ECR, ALB, RDS, ElastiCache, S3, MSK), Terraform, Docker, GitHub Actions |
| **Embedded** | ESP32, FreeRTOS, UART/I2C/SPI, ADC/PWM, DSP, industrial controls |
| **Testing** | xUnit, pytest, integration/load testing, CI pipelines |

---

## Education

**Purdue University** -- B.S. Electrical Engineering Technology (Computer Engineering Technology)  
Minor: Computer & IT | Certificate: Entrepreneurship & Innovation | Expected May 2026

Relevant coursework: Embedded Digital Systems, Advanced Embedded Systems, DSP, Advanced DSP, Industrial Controls, DAQ, Wireless Communications, Systems Development, IT Architecture, Network Engineering.

---

## Resumes

- [Backend / Full-Stack (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Backend_Resume.pdf)
- [Data Engineer (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Data_Engineer_Resume.pdf)
- [.NET / Industrial (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_DotNet_Industrial_Resume.pdf)
- [Embedded (PDF)](https://github.com/jmahotiedu/jmahotiedu/raw/main/resumes/Jared_Mahotiere_Embedded_Resume.pdf)

---

## Contact

Bear, DE | [jmahotie@purdue.edu](mailto:jmahotie@purdue.edu) | [LinkedIn](https://www.linkedin.com/in/jared-mahotiere)

Open to software engineering, data engineering, full-stack, backend, and embedded systems roles starting May 2026.

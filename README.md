# Jared Mahotiere

**Software Engineer** - .NET & full-stack web, embedded systems - Purdue EET '26

[LinkedIn](https://linkedin.com/in/jared-mahotiere) - [GitHub](https://github.com/jmahotiedu) - [Interactive portfolio](https://jmahotiedu.github.io/jmahotiedu/)

---

## About

Entry-level SWE: .NET and full-stack web (real-time dashboards, SQL optimization 70-90%, CI/testing) plus embedded systems (ESP32, FreeRTOS, binary protocols). Shipped production Next.js disaster-relief site; portfolio includes Redis-like cache (C), language interpreter (Python), real-time Kanban (Next.js/PostgreSQL), and ESP32 telemetry logger.

## Experience

**Nucor Corporation** - *Software / Automation Engineering Intern* | Darlington, SC | May-Aug 2024; May-Aug 2025

- Shipped Blazor/.NET real-time operator dashboards; improved process visibility with resilient UI state and consolidated KPI views.
- Built C#/.NET services integrating SQL Server and QMOS; cut critical report runtimes by 70-90% via indexing and query refactors.
- Delivered automated reporting/alerting with Quartz.NET (idempotency, retry/backoff) and migrated legacy Visual Basic apps to .NET/Blazor.
- Added ~240 unit/integration tests (xUnit) and CI quality gates; health checks and structured logging for deployment confidence.

## Projects

| Project | Stack | Link |
|--------|--------|------|
| **cachekit** | C (C11), POSIX, RESP | [GitHub](https://github.com/jmahotiedu/cachekit) |
| **workflow-orchestrator** | TypeScript, Node.js, Postgres, Redis Streams, React | [GitHub](https://github.com/jmahotiedu/workflow-orchestrator) |
| **Telemetry Node** | ESP32, FreeRTOS, C, Python | [GitHub](https://github.com/jmahotiedu/telemetry-node) |
| **syncboard** | Next.js 15, Socket.io, PostgreSQL, Prisma, NextAuth | [GitHub](https://github.com/jmahotiedu/syncboard) |
| **Help Westmoreland** | Next.js 16, React 19, TypeScript, Tailwind v4 | [Live](https://jmahotiedu-help-westmoreland.vercel.app) |
| **Rift** | Python 3.12, pytest | [GitHub](https://github.com/jmahotiedu/rift) |

### workflow-orchestrator highlights

- Distributed execution + retries/dead-letter
- Scheduling + idempotent triggers
- Observability + incident drill/postmortem

## Pull Request Contributions

- **databricks/cli** - [PR #4495](https://github.com/databricks/cli/pull/4495): fixed AppKit TypeScript tRPC template usage by replacing unsupported request-context calls with `WorkspaceClient`.
- **databricks/databricks-sdk-py** - [PR #1258](https://github.com/databricks/databricks-sdk-py/pull/1258): fixed `Config` subclass attribute discovery/caching for inherited `ConfigAttribute` fields with regression coverage.
- **bloomberg/comdb2** - [PR #5731](https://github.com/bloomberg/comdb2/pull/5731): preserved JDBC metadata cursors by isolating version lookup from active `getTables()` result-set flow.
- **sipeed/picoclaw** - [PR #56](https://github.com/sipeed/picoclaw/pull/56): fixed OpenAI device-code auth parsing for string/numeric poll intervals with targeted tests and clearer headless guidance.
- **google/langextract** - [PR #359](https://github.com/google/langextract/pull/359): fixed Gemini batch cache hashing for Enum/dataclass settings with deterministic regression tests.

## Skills

**Languages:** C#, TypeScript, Java, Python, C, C++  
**Frontend:** Next.js, React, Tailwind, accessibility, SEO  
**Embedded:** ESP32, FreeRTOS, Arduino, I2C, ADC, drivers, PID, PWM, binary protocols  
**Backend/DB:** .NET (ASP.NET Core, Blazor), REST/gRPC, SQL Server, PostgreSQL, Prisma, Redis, NextAuth, Socket.io  
**Cloud/DevOps:** AWS (S3, CloudFront, Route 53), Docker, GitHub Actions  
**Testing:** xUnit, pytest

## Leadership

- **Delta Tau Delta** | DEI Chair | Aug 2024 - Present - Launched mentorship and campus programs; repeatable onboarding and engagement playbooks.
- **NSBE** | Member | Sep 2022 - Present - Team-based engineering projects in C#, Java, Python; recruiting and community initiatives.

## Contact

Bear, DE | [jmahotie@purdue.edu](mailto:jmahotie@purdue.edu) | (302) 803-7673

Open to roles in software engineering, full-stack, and embedded systems.

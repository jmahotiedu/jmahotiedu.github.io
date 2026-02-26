"""
Generate ATS-friendly, single-column, single-page resumes with reportlab.
"""

import os
import shutil
from pathlib import Path

from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer


CONTACT = (
    "Jared Mahotiere | Bear, DE | (302) 803-7673 | jmahotie@purdue.edu | "
    "linkedin.com/in/jared-mahotiere | github.com/jmahotiedu | "
    "https://jmahotiedu.github.io/"
)

EDUCATION_LINE_1 = (
    "<b>Purdue University</b> - B.S. Electrical Engineering Technology "
    "(Computer Engineering Technology)"
)
EDUCATION_LINE_2 = (
    "Minor: Computer &amp; IT | Certificate: Entrepreneurship &amp; Innovation | "
    "Expected May 2026"
)
LEADERSHIP_LINE = (
    "<b>Delta Tau Delta (Campus Chapter):</b> DEI Chair | "
    "<b>National Society of Black Engineers (NSBE):</b> Member"
)
NUCOR_BULLETS = {
    1: (
        "Developed and maintained Blazor/.NET real-time operator dashboards and robust "
        "back-end services, enhancing process transparency and improving steel production workflows."
    ),
    2: (
        "Led system integration projects: scoped, specified, and coordinated implementation "
        "of new automation systems, ensuring seamless startup, cross-team adoption, and operational reliability."
    ),
    3: (
        "Managed and analyzed production data in SQL Server/QMOS databases; developed "
        "optimized queries and recommended new tables/columns to support process improvement."
    ),
    4: (
        "Built automated reporting and alert systems using Quartz.NET with real-time email "
        "notifications for maintenance and quality events, reducing manual monitoring and accelerating response."
    ),
    5: (
        "Migrated legacy Visual Basic applications to .NET/Blazor, reducing technical debt; "
        "utilized Git for version control, peer code reviews, and codebase integrity."
    ),
    6: (
        "Collaborated with production teams and led project meetings; conducted comprehensive "
        "testing and validation with multi-disciplinary stakeholders while prioritizing deliverables and shipping on time with high safety and quality standards."
    ),
    7: (
        "Executed controls-focused startup validation, signal-path troubleshooting, and sensor/actuator "
        "commissioning with operators and maintenance teams to de-risk automation cutovers."
    ),
}

RESUME_VARIANTS = [
    {
        "filename": "Jared_Mahotiere_Embedded_Resume.pdf",
        "summary": (
            "Embedded systems and firmware engineer with ESP32/FreeRTOS, C, UART/I2C, "
            "DSP, and industrial controls from two Nucor internships, plus open-source contributor experience."
        ),
        "projects": [
            (
                "<b>Telemetry Node</b> - ESP32, FreeRTOS, C, Python",
                "Built fixed-rate firmware telemetry with binary UART framing, CRC checks, "
                "sensor sampling, and host-side decode tooling.",
                "https://github.com/jmahotiedu/telemetry-node",
            ),
            (
                "<b>cachekit</b> - C (C11), POSIX",
                "Implemented a Redis-like cache server with RESP parsing, TCP event loop, "
                "TTL expiration, and persistent snapshot support.",
                "https://github.com/jmahotiedu/cachekit",
            ),
        ],
        "bullet_order": [2, 7, 6, 3],
        "oss_contributions": [
            (
                "<b>sipeed/picoclaw (PR #213)</b> - Go, Provider Architecture",
                "Refactored provider protocol-family handling to harden multi-provider routing and reduce integration edge cases.",
                "https://github.com/sipeed/picoclaw/pull/213",
            ),
            (
                "<b>databricks/cli (PR #4504)</b> - Go, Auth/Config Resolution",
                "Fixed bundle-context auth precedence so explicit host/profile inputs are honored for non-bundle commands.",
                "https://github.com/databricks/cli/pull/4504",
            ),
        ],
        "skills": (
            "C, C++, C#, Python | ESP32, FreeRTOS, Arduino, I2C, SPI, UART, ADC, PWM, DMA | "
            "DSP, PID control, wireless communication | Docker, GitHub Actions, CI | .NET, SQL Server"
        ),
        "coursework": (
            "Embedded Digital Systems, Advanced Embedded Digital Systems (in progress), DSP, Advanced DSP, Industrial Controls, "
            "DAQ, Wireless Communications, Electronic Prototype Development, Concurrent Digital Systems"
        ),
    },
    {
        "filename": "Jared_Mahotiere_Backend_Resume.pdf",
        "summary": (
            "Backend and systems software engineer focused on distributed services, C systems programming, "
            ".NET backend development, SQL performance optimization, AWS ECS deployments, and open-source architecture hardening."
        ),
        "projects": [
            (
                "<b>workflow-orchestrator</b> - TypeScript, Node.js, Redis Streams, PostgreSQL, AWS ECS",
                "Built a distributed workflow engine with DAG validation, Redis Streams consumer groups, "
                "idempotent retries, and durable Postgres run/task state; benchmarked 25/25 runs in 15.94s and validated AWS ECS Fargate deployment with ALB/RDS/ElastiCache.",
                "https://github.com/jmahotiedu/wf-orch",
            ),
            (
                "<b>IoT Streaming ETL Pipeline</b> - Kafka, PySpark, Airflow, Great Expectations, Terraform",
                "Built streaming ETL processing 100+ events/sec with Bronze/Silver/Gold architecture, "
                "checkpointed recovery, Great Expectations validation, and Prometheus/Grafana observability; provisioned AWS core infrastructure (MSK/S3/VPC/ECR) with Terraform.",
                "https://github.com/jmahotiedu/streaming-etl-pipeline",
            ),
            (
                "<b>Retail Sales Forecasting Dashboard</b> - Python, FastAPI, XGBoost, Streamlit, AWS ECS",
                "Shipped a live forecasting product on AWS ECS Fargate; achieved XGBoost R2=0.91 and ~11% MAPE with "
                "FastAPI inference, Streamlit UI, and 90%+ automated test coverage.",
                "https://github.com/jmahotiedu/retail-forecast-dashboard",
            ),
        ],
        "bullet_order": [1, 3, 4, 5],
        "oss_contributions": [
            (
                "<b>databricks/cli (PR #4504)</b> - Go, Auth/Config Governance",
                "Fixed bundle-context auth precedence so explicit host/profile inputs win for non-bundle workspace commands.",
                "https://github.com/databricks/cli/pull/4504",
            ),
            (
                "<b>sipeed/picoclaw (PR #213)</b> - Go, Provider Architecture",
                "Implemented protocol-family refactor to stabilize provider selection behavior and reduce edge-case failures.",
                "https://github.com/sipeed/picoclaw/pull/213",
            ),
            (
                "<b>bloomberg/comdb2 (PR #5743)</b> - C/C++, SQLite Security",
                "Backported targeted SQLite security fixes and validated behavior with source-build and harness verification.",
                "https://github.com/bloomberg/comdb2/pull/5743",
            ),
        ],
        "skills": (
            "Languages: C, C#, TypeScript, Python, Java | Backend: .NET, ASP.NET Core, Node.js, Express, "
            "REST, gRPC, concurrency, POSIX networking | Data: PySpark, Kafka, XGBoost, Prophet, FastAPI | "
            "Storage/Infra: PostgreSQL, SQL Server, Redis Streams, Docker, GitHub Actions, Prometheus, Grafana, AWS (ECS, ALB, RDS, ElastiCache), Terraform"
        ),
        "coursework": None,
    },
    {
        "filename": "Jared_Mahotiere_DotNet_Industrial_Resume.pdf",
        "summary": (
            ".NET and industrial software developer with production Blazor experience, SQL Server optimization, "
            "automated reporting, real-time dashboard delivery, AWS ECS platform deployments, and open-source backend contributions."
        ),
        "projects": [
            (
                "<b>Event Stream Platform</b> - C#, .NET, WebSocket, WAL, Prometheus",
                "Built a durable event ingest/replay platform with WAL-backed persistence, materialized views, "
                "deterministic backfill tooling, and production observability.",
            ),
            (
                "<b>Feature Flag Platform</b> - TypeScript, Node.js, React, PostgreSQL, Redis, Terraform",
                "Built a multi-tenant feature flag control plane with deterministic rollout targeting, "
                "RBAC, idempotent writes, publish/rollback workflows, and reproducible load-test coverage; validated AWS ECS Fargate deployment behind ALB with RDS Postgres and ElastiCache Redis.",
                "https://github.com/jmahotiedu/feature-flag-platform",
            ),
            (
                "<b>workflow-orchestrator</b> - TypeScript, Node.js, Redis Streams, PostgreSQL",
                "Implemented queue-driven orchestration with DAG validation, durable run/task state, "
                "worker retries, dead-letter handling, and benchmarked execution reliability (25/25 runs in 15.94s).",
                "https://github.com/jmahotiedu/wf-orch",
            ),
        ],
        "bullet_order": [2, 1, 4, 5],
        "oss_contributions": [
            (
                "<b>sipeed/picoclaw (PR #213)</b> - Go, Provider Architecture",
                "Refactored provider protocol-family routing to simplify backend integration and improve execution safety.",
                "https://github.com/sipeed/picoclaw/pull/213",
            ),
            (
                "<b>databricks/cli (PR #4504)</b> - Go, Auth/Config Resolution",
                "Fixed auth-resolution precedence so explicit host/profile selections override inherited bundle context.",
                "https://github.com/databricks/cli/pull/4504",
            ),
        ],
        "skills": (
            "C#, .NET 8, ASP.NET Core, Blazor, Entity Framework | SQL Server, T-SQL, PostgreSQL, Redis | "
            "xUnit, CI/CD, GitHub Actions | TypeScript, React, Next.js | Docker, AWS"
            " (ECS Fargate, ALB, RDS, ElastiCache)"
        ),
        "coursework": "Industrial Controls, DAQ, Systems Development, IT Architecture, Network Engineering",
    },
    {
        "filename": "Jared_Mahotiere_Data_Engineer_Resume.pdf",
        "summary": (
            "Data engineer with hands-on pipeline and ML forecasting experience across Kafka, Spark, Airflow, "
            "AWS, production SQL Server/QMOS data management, and open-source systems contributions."
        ),
        "projects": [
            (
                "<b>IoT Streaming ETL Pipeline</b> - Kafka, PySpark, Airflow, Great Expectations, Terraform",
                "Built streaming ETL with 100+ events/sec ingestion, Bronze/Silver/Gold architecture, "
                "checkpointed recovery, Great Expectations validation, and Prometheus/Grafana observability; provisioned AWS core infrastructure across MSK/S3/VPC/ECR with Terraform.",
                "https://github.com/jmahotiedu/streaming-etl-pipeline",
            ),
            (
                "<b>Event Stream Platform</b> - C#, .NET, WebSocket, WAL, Materialized Views",
                "Built a durable event ingest/replay platform with WAL-backed persistence, materialized views, "
                "backfill/reconciliation workflows, and data-quality observability.",
            ),
            (
                "<b>Retail Sales Forecasting Dashboard</b> - Python, FastAPI, XGBoost, Streamlit, AWS ECS",
                "Shipped a live forecasting product on AWS ECS Fargate with XGBoost R2=0.91 and ~11% MAPE, "
                "FastAPI inference, Streamlit dashboard delivery, and 90%+ automated test coverage.",
                "https://github.com/jmahotiedu/retail-forecast-dashboard",
            ),
        ],
        "bullet_order": [3, 1, 4, 6],
        "oss_contributions": [
            (
                "<b>bloomberg/comdb2 (PR #5743)</b> - C/C++, SQLite Security",
                "Backported targeted SQLite security fixes and validated source-build behavior with harness-backed checks.",
                "https://github.com/bloomberg/comdb2/pull/5743",
            ),
            (
                "<b>databricks/cli (PR #4504)</b> - Go, Auth/Config Resolution",
                "Corrected bundle-context precedence to prevent non-bundle commands from resolving to the wrong workspace.",
                "https://github.com/databricks/cli/pull/4504",
            ),
            (
                "<b>google/langextract (PR #359)</b> - Python, Caching",
                "Fixed cache-key hashing behavior to improve deterministic extraction and avoid cache collisions.",
                "https://github.com/google/langextract/pull/359",
            ),
        ],
        "skills": (
            "Python, SQL, PySpark, C# | Kafka, Airflow, Redshift, S3, Great Expectations | "
            "PostgreSQL, SQL Server, Redis | scikit-learn, XGBoost, Prophet, pandas, Streamlit | "
            "Docker, Terraform, GitHub Actions, AWS (ECS, ALB, RDS, ElastiCache, ECR, MSK, EMR, MWAA)"
        ),
        "coursework": None,
    },
    {
        "filename": "Jared_Mahotiere_Databricks_Platform_Engineer_Resume.pdf",
        "summary": (
            "Backend/platform engineer (Purdue '26) focused on shared data-platform reliability, Terraform multi-environment IaC, "
            "Python automation, and CI/CD governance; open-source contributor to Databricks CLI/SDK with fixes for auth precedence and config inheritance failure modes."
        ),
        "projects": [
            (
                "<b>Databricks Platform Tooling (Open Source)</b> - Go, Python, Databricks CLI/SDK",
                "Implemented Databricks CLI PR #4504 to fix auth-resolution precedence in bundle context so explicit host/profile inputs win for non-bundle commands, "
                "preventing wrong-environment execution; added regression tests and iterated the precedence model with maintainers after issue #4502 and a reported 1-hour troubleshooting incident.",
                "https://github.com/pulls?q=is%3Apr+author%3Ajmahotiedu+repo%3Adatabricks%2Fcli+repo%3Adatabricks%2Fdatabricks-sdk-py",
            ),
            (
                "<b>IoT Streaming ETL Pipeline</b> - Kafka, PySpark, Airflow, Great Expectations, Terraform",
                "Built a 100+ events/sec streaming platform with checkpointed recovery, data-quality gates, and "
                "Prometheus/Grafana observability; provisioned AWS MSK/S3/VPC/ECR via reusable Terraform workflows and environment-safe deployment patterns.",
                "https://github.com/jmahotiedu/streaming-etl-pipeline",
            ),
            (
                "<b>workflow-orchestrator</b> - TypeScript, Node.js, Redis Streams, PostgreSQL, AWS ECS",
                "Implemented reliable DAG orchestration with idempotent retries, dead-letter handling, and durable task state; "
                "benchmarked 25/25 successful runs in 15.94s and operated ECS Fargate deployment with ALB/RDS/ElastiCache.",
                "https://github.com/jmahotiedu/wf-orch",
            ),
        ],
        "bullet_order": [4, 2, 3, 6],
        "oss_contributions": [
            (
                "<b>databricks/cli (PR #4504)</b> - Go, Auth Precedence",
                "Implemented precedence fixes so explicit host/profile inputs are respected for non-bundle commands.",
                "https://github.com/databricks/cli/pull/4504",
            ),
            (
                "<b>databricks/databricks-sdk-py (PR #1258)</b> - Python, Config Introspection",
                "Fixed Config subclass attribute discovery/caching regressions that impacted auth and profile resolution.",
                "https://github.com/databricks/databricks-sdk-py/pull/1258",
            ),
            (
                "<b>bloomberg/comdb2 (PR #5731)</b> - Java, JDBC Metadata",
                "Resolved metadata cursor-isolation behavior to prevent cross-query cursor bleed in JDBC client flows.",
                "https://github.com/bloomberg/comdb2/pull/5731",
            ),
        ],
        "skills": (
            "Databricks tooling (CLI/SDK), auth/config governance, Python automation, Terraform (multi-env IaC/modules) | AWS (IAM, VPC, ECS, RDS, S3, MSK), "
            "SQL Server/QMOS, PostgreSQL, Redis | CI/CD (GitHub Actions), Linux shell, runbooks, observability (CloudWatch, Prometheus, Grafana)"
        ),
        "coursework": None,
    },
]


def build_styles():
    return {
        "name": ParagraphStyle(
            "name",
            fontName="Helvetica-Bold",
            fontSize=15,
            leading=17,
            alignment=TA_CENTER,
            spaceAfter=2,
        ),
        "contact": ParagraphStyle(
            "contact",
            fontName="Helvetica",
            fontSize=9,
            leading=10.5,
            alignment=TA_CENTER,
            spaceAfter=4,
        ),
        "section": ParagraphStyle(
            "section",
            fontName="Helvetica-Bold",
            fontSize=10.5,
            leading=12,
            spaceBefore=3,
            spaceAfter=1,
        ),
        "body": ParagraphStyle(
            "body",
            fontName="Helvetica",
            fontSize=9.7,
            leading=11.2,
            spaceAfter=1,
        ),
        "body_bold": ParagraphStyle(
            "body_bold",
            fontName="Helvetica-Bold",
            fontSize=9.7,
            leading=11.2,
            spaceAfter=0.5,
        ),
        "bullet": ParagraphStyle(
            "bullet",
            fontName="Helvetica",
            fontSize=9.7,
            leading=11.2,
            leftIndent=12,
            bulletIndent=2,
            spaceAfter=0.5,
        ),
    }


def build_resume(variant, output_dir):
    output_path = os.path.join(output_dir, variant["filename"])
    styles = build_styles()

    doc = SimpleDocTemplate(
        output_path,
        pagesize=letter,
        leftMargin=0.6 * inch,
        rightMargin=0.6 * inch,
        topMargin=0.58 * inch,
        bottomMargin=0.58 * inch,
    )

    story = []
    story.append(Paragraph("JARED MAHOTIERE", styles["name"]))
    story.append(Paragraph(CONTACT, styles["contact"]))

    story.append(Paragraph("SUMMARY", styles["section"]))
    story.append(Paragraph(variant["summary"], styles["body"]))

    story.append(Paragraph("EDUCATION", styles["section"]))
    story.append(Paragraph(EDUCATION_LINE_1, styles["body"]))
    story.append(Paragraph(EDUCATION_LINE_2, styles["body"]))
    if variant.get("coursework"):
        story.append(Paragraph("<b>Relevant Coursework:</b> " + variant["coursework"], styles["body"]))

    story.append(Paragraph("LEADERSHIP &amp; ORGANIZATIONS", styles["section"]))
    story.append(Paragraph(LEADERSHIP_LINE, styles["body"]))

    story.append(Paragraph("SKILLS", styles["section"]))
    story.append(Paragraph(variant["skills"], styles["body"]))

    story.append(Paragraph("EXPERIENCE", styles["section"]))
    story.append(
        Paragraph(
            "<b>Nucor Corporation</b> - Software/Automation Engineering Intern | "
            "Darlington, SC | May-Aug 2024 and May-Aug 2025",
            styles["body_bold"],
        )
    )
    for bullet_id in variant["bullet_order"]:
        story.append(Paragraph(NUCOR_BULLETS[bullet_id], styles["bullet"], bulletText="\u2022"))

    story.append(Paragraph("PROJECTS", styles["section"]))
    for project in variant["projects"]:
        if len(project) == 3:
            title, bullet, url = project
        else:
            title, bullet = project
            url = None

        title_with_link = title
        if url:
            title_with_link = f'{title} | <link href="{url}">Project Link</link>'

        story.append(Paragraph(title_with_link, styles["body_bold"]))
        story.append(Paragraph(bullet, styles["bullet"], bulletText="\u2022"))

    story.append(Paragraph("OPEN SOURCE CONTRIBUTIONS", styles["section"]))
    for contribution in variant["oss_contributions"]:
        if len(contribution) == 3:
            title, bullet, url = contribution
        else:
            title, bullet = contribution
            url = None

        title_with_link = title
        if url:
            title_with_link = f'{title} | <link href="{url}">Project Link</link>'

        story.append(Paragraph(title_with_link, styles["body_bold"]))
        story.append(Paragraph(bullet, styles["bullet"], bulletText="\u2022"))

    story.append(Spacer(1, 0.05 * inch))
    doc.build(story)
    return output_path


def resolve_desktop_dir() -> Path:
    home = Path.home()
    candidates = [
        home / "Desktop",
        home / "OneDrive - purdue.edu" / "Desktop",
        home / "OneDrive" / "Desktop",
    ]
    for candidate in candidates:
        if candidate.exists():
            return candidate
    return home / "Desktop"


def main():
    output_dir = Path(__file__).resolve().parent
    desktop_dir = resolve_desktop_dir()
    output_dir.mkdir(parents=True, exist_ok=True)
    desktop_dir.mkdir(parents=True, exist_ok=True)

    for variant in RESUME_VARIANTS:
        generated = build_resume(variant, str(output_dir))
        print(f"Generated: {generated}")
        desktop_copy = desktop_dir / variant["filename"]
        shutil.copy2(generated, desktop_copy)
        print(f"Copied:    {desktop_copy}")

    print("Done: generated all resume PDFs.")


if __name__ == "__main__":
    main()

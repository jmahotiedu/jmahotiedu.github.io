"""
Generate four ATS-friendly, single-column, single-page resumes with reportlab.
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
            ),
            (
                "<b>cachekit</b> - C (C11), POSIX",
                "Implemented a Redis-like cache server with RESP parsing, TCP event loop, "
                "TTL expiration, and persistent snapshot support.",
            ),
        ],
        "bullet_order": [2, 7, 6, 3],
        "oss_contributions": [
            "PicoClaw (Go): 3 merged PRs on a 14.5k-star project, including provider protocol-family refactor (#213) and security/model hardening follow-ups; invited to Dev Group.",
            "PRs Under Review: Databricks CLI (#4504) auth-resolution fix; Google langextract (#359) cache-key hashing fix.",
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
                "<b>workflow-orchestrator</b> - TypeScript, Node.js, Redis Streams, Postgres",
                "Built a distributed workflow engine with DAG validation, Redis Streams consumer groups, "
                "idempotent retries, and durable Postgres run/task state; benchmarked 25/25 runs in 15.94s and deployed on AWS ECS Fargate with ALB/RDS/Redis.",
            ),
            (
                "<b>IoT Streaming ETL Pipeline</b> - Kafka, PySpark, Airflow, Redshift",
                "Implemented event-driven ingestion at 100+ events/sec with medallion data architecture, "
                "quality validation, and production monitoring/alerting.",
            ),
            (
                "<b>Retail Sales Forecasting Dashboard</b> - Python, XGBoost, FastAPI, AWS ECS",
                "Shipped a live forecasting product on AWS ECS; achieved XGBoost R2=0.91 and delivered "
                "90%+ automated test coverage for API/model workflows.",
            ),
        ],
        "bullet_order": [1, 3, 4, 5],
        "oss_contributions": [
            "PicoClaw (Go): 3 merged PRs on a 14.5k-star project, including provider protocol-family refactor (#213) and security/model hardening follow-ups; invited to Dev Group.",
            "Bloomberg comdb2 (C/Java): fixed JDBC metadata cursor isolation bug in PR #5731 to preserve active getTables() result sets during version lookup.",
            "Bloomberg comdb2 (C/C++/SQL): backported targeted SQLite security fixes for issue #3904 in PR #5743 (commit cede68b52); built from source, ran full test harness, reproduced failures by test ID, and published a security-fix verification matrix.",
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
                "<b>Feature Flag Platform</b> - TypeScript, Node.js, Redis, React",
                "Built multi-tenant control-plane patterns including deterministic rollout logic, "
                "RBAC, idempotency, operational observability, and a reproducible load-test harness; deployed on AWS ECS Fargate with ALB, RDS Postgres, and ElastiCache Redis.",
            ),
            (
                "<b>workflow-orchestrator</b> - TypeScript, Redis Streams, Postgres",
                "Implemented queue-driven orchestration with DAG validation, durable run/task state, "
                "worker retries, and dead-letter handling for reliability.",
            ),
        ],
        "bullet_order": [2, 1, 4, 5],
        "oss_contributions": [
            "PicoClaw (Go): 3 merged PRs on a 14.5k-star project, including provider protocol-family refactor (#213) and security/model hardening follow-ups; invited to Dev Group.",
            "PRs Under Review: Databricks CLI (#4504) auth-resolution fix; Google langextract (#359) cache-key hashing fix.",
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
                "<b>IoT Streaming ETL Pipeline</b> - Kafka, PySpark, Airflow, Redshift",
                "Built streaming ETL with 100+ events/sec ingestion, data quality validation, "
                "medallion architecture, production monitoring/alerting, and Terraform cloud topology across MSK/EMR/MWAA/Redshift with cost-aware core deployment mode.",
            ),
            (
                "<b>Event Stream Platform</b> - C#, .NET, WebSocket, WAL, Materialized Views",
                "Built a durable event ingest/replay platform with WAL-backed persistence, materialized views, "
                "backfill/reconciliation workflows, and data-quality observability.",
            ),
            (
                "<b>Retail Sales Forecasting Dashboard</b> - Python, XGBoost, Prophet, Streamlit, AWS ECS",
                "Shipped a live forecasting product on AWS ECS with XGBoost R2=0.91, 11% MAPE, production "
                "API/dashboard deployment, and 90%+ automated test coverage.",
            ),
        ],
        "bullet_order": [3, 1, 4, 6],
        "oss_contributions": [
            "PicoClaw (Go): 3 merged PRs on a 14.5k-star project, including provider protocol-family refactor (#213) and security/model hardening follow-ups; invited to Dev Group.",
            "Bloomberg comdb2 (C/C++/SQL): backported targeted SQLite security fixes for issue #3904 in PR #5743 (commit cede68b52), with source-build validation, harness runs, and a published security-fix verification matrix.",
            "PRs Under Review: Databricks CLI (#4504) auth-resolution fix; Google langextract (#359) cache-key hashing fix.",
        ],
        "skills": (
            "Python, SQL, PySpark, C# | Kafka, Airflow, Redshift, S3, Great Expectations | "
            "PostgreSQL, SQL Server, Redis | scikit-learn, XGBoost, Prophet, pandas, Streamlit | "
            "Docker, Terraform, GitHub Actions, AWS (ECS, ALB, RDS, ElastiCache, ECR, MSK, EMR, MWAA)"
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
    for title, bullet in variant["projects"]:
        story.append(Paragraph(title, styles["body_bold"]))
        story.append(Paragraph(bullet, styles["bullet"], bulletText="\u2022"))

    story.append(Paragraph("OPEN SOURCE CONTRIBUTIONS", styles["section"]))
    for bullet in variant["oss_contributions"]:
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

    print("Done: generated all four resume PDFs.")


if __name__ == "__main__":
    main()

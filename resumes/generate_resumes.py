"""
Generate four ATS-friendly, single-column, single-page resumes with reportlab.
"""

import os
import shutil

from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer


CONTACT = (
    "Jared Mahotiere | Bear, DE | (302) 803-7673 | jmahotie@purdue.edu | "
    "linkedin.com/in/jared-mahotiere | github.com/jmahotiedu"
)

EDUCATION_LINE_1 = (
    "<b>Purdue University</b> - B.S. Electrical Engineering Technology "
    "(Computer Engineering Technology)"
)
EDUCATION_LINE_2 = (
    "Minor: Computer &amp; IT | Certificate: Entrepreneurship &amp; Innovation | "
    "Expected May 2026"
)

NUCOR_BULLETS = {
    1: (
        "Shipped Blazor/.NET real-time operator dashboards with resilient UI state "
        "and consolidated KPI views for plant visibility."
    ),
    2: (
        "Built C#/.NET services integrating SQL Server and QMOS; reduced critical "
        "report runtimes 70-90% through indexing and query refactors."
    ),
    3: (
        "Delivered automated reporting and alerting with Quartz.NET idempotent jobs, "
        "retry/backoff logic, and legacy VB to .NET/Blazor migrations."
    ),
    4: (
        "Added about 240 unit/integration tests (xUnit), CI quality gates, health "
        "checks, and structured logging to improve deployment confidence."
    ),
    5: (
        "Supported industrial automation workflows tied to PLC/HMI production systems "
        "in a steel manufacturing environment."
    ),
}

RESUME_VARIANTS = [
    {
        "filename": "Jared_Mahotiere_Embedded_Resume.pdf",
        "summary": (
            "Embedded systems and firmware engineer with ESP32/FreeRTOS, C, UART/I2C, "
            "DSP, and industrial controls experience from two Nucor automation internships."
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
            (
                "<b>workflow-orchestrator</b> - TypeScript, Redis Streams, Postgres",
                "Built a durable distributed workflow engine with DAG validation, "
                "consumer-group workers, and failure recovery.",
            ),
        ],
        "bullet_order": [5, 1, 2, 3, 4],
        "skills": (
            "C, C++, C#, Python | ESP32, FreeRTOS, Arduino, I2C, SPI, UART, ADC, PWM, DMA | "
            "DSP, PID control, wireless communication | Docker, GitHub Actions, CI | .NET, SQL Server"
        ),
        "coursework": (
            "Embedded Digital Systems, Advanced Embedded Systems, DSP, Advanced DSP, Industrial Controls, "
            "DAQ, Wireless Communications, Electronic Prototype Development, Concurrent Digital Systems"
        ),
    },
    {
        "filename": "Jared_Mahotiere_Backend_Resume.pdf",
        "summary": (
            "Backend and systems software engineer focused on distributed services, C systems programming, "
            ".NET backend development, and SQL performance optimization."
        ),
        "projects": [
            (
                "<b>workflow-orchestrator</b> - TypeScript, Node.js, Redis Streams, Postgres",
                "Executed 25/25 benchmark runs in 15.94s (1.57 runs/s) with DAG validation, "
                "consumer groups, idempotency, and run-state durability.",
            ),
            (
                "<b>cachekit</b> - C (C11), POSIX, RESP",
                "Built networked in-memory caching with RESP protocol support, low-level socket handling, "
                "and persistence primitives.",
            ),
            (
                "<b>Telemetry Node</b> - ESP32, FreeRTOS, C",
                "Delivered embedded telemetry firmware to demonstrate low-level debugging, protocol design, "
                "and systems reliability skills.",
            ),
        ],
        "bullet_order": [2, 1, 4, 3, 5],
        "skills": (
            "C, C#, TypeScript, Python, Java | PostgreSQL, SQL Server, Redis Streams | "
            ".NET, ASP.NET Core, Node.js, Express, React | Docker, GitHub Actions, Prometheus, Grafana, AWS | "
            "REST, gRPC, concurrency, POSIX networking"
        ),
        "coursework": None,
    },
    {
        "filename": "Jared_Mahotiere_DotNet_Industrial_Resume.pdf",
        "summary": (
            ".NET and industrial software developer with production Blazor experience, SQL Server tuning, "
            "automation tooling, and real-time dashboard delivery in manufacturing environments."
        ),
        "projects": [
            (
                "<b>Feature Flag Platform</b> - TypeScript, Node.js, Redis, React",
                "Built multi-tenant control-plane patterns including deterministic rollout logic, "
                "RBAC, idempotency, and operational observability.",
            ),
            (
                "<b>workflow-orchestrator</b> - TypeScript, Redis Streams, Postgres",
                "Implemented queue-driven workflow execution with durable state, retries, and "
                "distributed worker coordination.",
            ),
            (
                "<b>syncboard</b> - Next.js, Socket.IO, PostgreSQL",
                "Built real-time full-stack collaboration features with optimistic UI updates, "
                "presence tracking, and conflict handling.",
            ),
        ],
        "bullet_order": [1, 2, 3, 4, 5],
        "skills": (
            "C#, .NET 8, ASP.NET Core, Blazor, Entity Framework | SQL Server, T-SQL, PostgreSQL, Redis | "
            "xUnit, CI/CD, GitHub Actions | TypeScript, React, Next.js | Docker, AWS"
        ),
        "coursework": "Industrial Controls, DAQ, Systems Development, IT Architecture, Network Engineering",
    },
    {
        "filename": "Jared_Mahotiere_Data_Engineer_Resume.pdf",
        "summary": (
            "Data engineer with hands-on pipeline and ML forecasting experience across Kafka, Spark, Airflow, "
            "and AWS, plus strong SQL optimization fundamentals from production systems work."
        ),
        "projects": [
            (
                "<b>IoT Streaming ETL Pipeline</b> - Kafka, PySpark, Airflow, Redshift",
                "Built streaming ETL with 100+ events/sec ingestion, data quality validation, "
                "medallion architecture, and production monitoring/alerting.",
            ),
            (
                "<b>Retail Sales Forecasting Dashboard</b> - Python, XGBoost, Prophet, Streamlit, AWS ECS",
                "Delivered forecasting and segmentation models with production API/dashboard deployment, "
                "feature engineering, and MAPE/R2 performance tracking.",
            ),
            (
                "<b>workflow-orchestrator</b> - TypeScript, Redis Streams, Postgres",
                "Demonstrated distributed queue orchestration patterns transferable to robust data processing systems.",
            ),
        ],
        "bullet_order": [2, 1, 4, 3, 5],
        "skills": (
            "Python, SQL, PySpark, C# | Kafka, Airflow, Redshift, S3, Great Expectations | "
            "PostgreSQL, SQL Server, Redis | scikit-learn, XGBoost, Prophet, pandas, Streamlit | "
            "Docker, Terraform, GitHub Actions, AWS (ECS, ECR, MSK, EMR, MWAA)"
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
            fontSize=10,
            leading=11.6,
            spaceAfter=1,
        ),
        "body_bold": ParagraphStyle(
            "body_bold",
            fontName="Helvetica-Bold",
            fontSize=10,
            leading=11.6,
            spaceAfter=0.5,
        ),
        "bullet": ParagraphStyle(
            "bullet",
            fontName="Helvetica",
            fontSize=10,
            leading=11.6,
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
        story.append(Paragraph(NUCOR_BULLETS[bullet_id], styles["bullet"], bulletText="•"))

    story.append(Paragraph("PROJECTS", styles["section"]))
    for title, bullet in variant["projects"]:
        story.append(Paragraph(title, styles["body_bold"]))
        story.append(Paragraph(bullet, styles["bullet"], bulletText="•"))

    story.append(Spacer(1, 0.05 * inch))
    doc.build(story)
    return output_path


def main():
    output_dir = r"C:\projects\jmahotiedu\resumes"
    desktop_dir = r"C:\Users\Jared Mahotiere\OneDrive - purdue.edu\Desktop"
    os.makedirs(output_dir, exist_ok=True)
    os.makedirs(desktop_dir, exist_ok=True)

    for variant in RESUME_VARIANTS:
        generated = build_resume(variant, output_dir)
        print(f"Generated: {generated}")
        desktop_copy = os.path.join(desktop_dir, variant["filename"])
        shutil.copy2(generated, desktop_copy)
        print(f"Copied:    {desktop_copy}")

    print("Done: generated all four resume PDFs.")


if __name__ == "__main__":
    main()


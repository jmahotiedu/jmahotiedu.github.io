#!/usr/bin/env python3
"""
Portfolio consistency checker.

Validates that README.md and index.html agree on:
  1. PR contribution list (same set of GitHub pull request URLs)
  2. Cloud deployment statuses (Live vs Deprovisioned for each project)

Exits with a non-zero code and prints a report if any conflicts are found.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).parent.parent
README = ROOT / "README.md"
INDEX = ROOT / "index.html"

ERRORS: list[str] = []
WARNINGS: list[str] = []


def err(msg: str) -> None:
    ERRORS.append(f"  ERROR: {msg}")


def warn(msg: str) -> None:
    WARNINGS.append(f"  WARN:  {msg}")


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def extract_pr_urls(text: str) -> set[str]:
    """Return all unique github.com/.../pull/N URLs found in text."""
    return set(re.findall(r"https://github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/pull/\d+", text))


def normalize_project(name: str) -> str:
    return re.sub(r"[^a-z0-9]", "", name.lower())


# ---------------------------------------------------------------------------
# 1. PR list consistency
# ---------------------------------------------------------------------------

def check_prs(readme: str, index: str) -> None:
    readme_prs = extract_pr_urls(readme)
    index_prs = extract_pr_urls(index)

    only_readme = readme_prs - index_prs
    only_index = index_prs - readme_prs

    for url in sorted(only_readme):
        err(f"PR in README.md but missing from index.html: {url}")

    for url in sorted(only_index):
        err(f"PR in index.html but missing from README.md: {url}")

    if not only_readme and not only_index:
        print(f"  OK: PR lists match ({len(readme_prs)} PRs in both files)")


# ---------------------------------------------------------------------------
# 2. Cloud deployment status consistency
# ---------------------------------------------------------------------------

# Known projects and their canonical normalized keys
CLOUD_PROJECTS = {
    "retailforecastdashboard": "Retail Forecast Dashboard",
    "featureflagplatform": "Feature Flag Platform",
    "workfloworchestrator": "Workflow Orchestrator",
    "streamingetlpipeline": "Streaming ETL Pipeline",
}


def parse_readme_statuses(readme: str) -> dict[str, str] | None:
    """
    Extract deployment statuses from the cloud table in README.md.
    Returns {normalized_name: 'live'|'deprovisioned'}, or None if no
    cloud status table is present (e.g. after README cleanup).
    """
    statuses: dict[str, str] = {}
    # Match table rows: | Project Name | Live ... | or | Deprovisioned ... |
    for m in re.finditer(r"\|\s*([^|]+?)\s*\|\s*(Live|Deprovisioned)[^|]*\|", readme, re.IGNORECASE):
        name = normalize_project(m.group(1))
        status = m.group(2).lower()
        if name in CLOUD_PROJECTS:
            statuses[name] = status
    return statuses if statuses else None


def parse_index_statuses(index: str) -> dict[str, str]:
    """
    Extract deployment statuses from the cloud section in index.html.
    Looks for <h3>Project Name</h3> followed by Status: Live or Status: Deprovisioned.
    Returns {normalized_name: 'live'|'deprovisioned'}.
    """
    statuses: dict[str, str] = {}
    # Find cloud section block
    cloud_match = re.search(r'id="cloud"(.*?)(?=<section|</main)', index, re.DOTALL)
    if not cloud_match:
        warn("Could not locate id=\"cloud\" section in index.html — skipping status check")
        return statuses

    cloud_block = cloud_match.group(1)

    # Find each project card: <h3>Name</h3> ... Status: Live|Deprovisioned
    for card in re.finditer(r"<h3>([^<]+)</h3>.*?Status:\s*(Live|Deprovisioned)", cloud_block, re.DOTALL):
        name = normalize_project(card.group(1))
        status = card.group(2).lower()
        if name in CLOUD_PROJECTS:
            statuses[name] = status

    return statuses


def check_deployment_statuses(readme: str, index: str) -> None:
    readme_statuses = parse_readme_statuses(readme)
    index_statuses = parse_index_statuses(index)

    if readme_statuses is None:
        print("  OK: README.md has no cloud status table (statuses managed in index.html only)")
        return

    all_projects = set(CLOUD_PROJECTS.keys())

    for key in all_projects:
        label = CLOUD_PROJECTS[key]
        r_status = readme_statuses.get(key)
        i_status = index_statuses.get(key)

        if r_status is None and i_status is None:
            warn(f"{label}: not found in either file's cloud section")
        elif r_status is None:
            warn(f"{label}: found in index.html ({i_status}) but not in README.md cloud table")
        elif i_status is None:
            warn(f"{label}: found in README.md ({r_status}) but not in index.html cloud section")
        elif r_status != i_status:
            err(f"{label}: README.md says '{r_status}' but index.html says '{i_status}'")
        else:
            print(f"  OK: {label} -> {r_status}")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> int:
    if not README.exists():
        print(f"ERROR: {README} not found", file=sys.stderr)
        return 1
    if not INDEX.exists():
        print(f"ERROR: {INDEX} not found", file=sys.stderr)
        return 1

    readme = README.read_text(encoding="utf-8")
    index = INDEX.read_text(encoding="utf-8")

    print("=== PR List ===")
    check_prs(readme, index)

    print("\n=== Cloud Deployment Statuses ===")
    check_deployment_statuses(readme, index)

    if WARNINGS:
        print("\n=== Warnings ===")
        for w in WARNINGS:
            print(w)

    if ERRORS:
        print("\n=== Failures ===")
        for e in ERRORS:
            print(e)
        print(f"\nFAILED: {len(ERRORS)} error(s). README.md and index.html are out of sync.")
        return 1

    print("\nPASSED: README.md and index.html are consistent.")
    return 0


if __name__ == "__main__":
    sys.exit(main())

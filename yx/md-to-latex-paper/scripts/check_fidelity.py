#!/usr/bin/env python3
"""Heuristic Markdown-to-CUMCM-PDF fidelity checker.

Usage:
    python check_fidelity.py <source.md> <compiled.pdf> [source-code.txt]

This checks extractable content and required front-matter markers. It does not
replace page-image inspection of the final PDF.
"""
from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

from extract_code_blocks import extract_fenced_code_blocks


PLACEHOLDERS = (
    "PAPER_TITLE",
    "PAPER_ABSTRACT",
    "PAPER_KEYWORDS",
    "PAPER_BODY",
    "PAPER_CODE_APPENDIX",
)


def count_text_units(text: str) -> int:
    """Count each CJK character plus each Latin/numeric token as one unit."""
    cjk_chars = re.findall(r"[\u3400-\u9fff]", text)
    latin_words = re.findall(r"[A-Za-z0-9]+(?:[._-][A-Za-z0-9]+)*", text)
    return len(cjk_chars) + len(latin_words)


def normalize_heading(text: str) -> str:
    text = re.sub(r"[*_`]", "", text)
    text = re.sub(
        r"^(?:[一二三四五六七八九十百]+、|\d+(?:\.\d+)*[.、]?\s*)",
        "",
        text.strip(),
    )
    return re.sub(r"\s+", "", text).lower()


def extract_md_structure(md_text: str) -> dict:
    headings = re.findall(r"^(#{1,4})\s+(.+)$", md_text, flags=re.MULTILINE)
    list_items = re.findall(r"^\s*[-*+]\s+.+$", md_text, flags=re.MULTILINE)
    numbered_items = re.findall(r"^\s*\d+[.)、]\s+.+$", md_text, flags=re.MULTILINE)
    table_rows = re.findall(r"^\|.+\|$", md_text, flags=re.MULTILINE)
    images = re.findall(r"!\[.*?\]\(.*?\)", md_text)
    links = re.findall(r"(?<!!)\[.*?\]\(.*?\)", md_text)
    code_blocks = extract_fenced_code_blocks(md_text)
    # Code is part of the final PDF appendix, so count its content while removing
    # only Markdown fence marker lines from the source-unit comparison.
    visible = re.sub(r"(?m)^ {0,3}(?:`{3,}|~{3,}).*$", "", md_text)
    visible = re.sub(r"!\[.*?\]\(.*?\)", "", visible)
    return {
        "headings": [(len(marks), title.strip()) for marks, title in headings],
        "list_items": len(list_items),
        "numbered_items": len(numbered_items),
        "table_rows": len(table_rows),
        "images": len(images),
        "links": len(links),
        "code_blocks": len(code_blocks),
        "text_units": count_text_units(visible),
    }


def pdf_to_text(pdf_path: str) -> str:
    result = subprocess.run(
        ["pdftotext", "-layout", pdf_path, "-"],
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


def missing_headings(headings: list[tuple[int, str]], pdf_text: str) -> list[tuple[int, str]]:
    normalized_pdf = re.sub(r"\s+", "", pdf_text).lower()
    missing = []
    for level, title in headings:
        normalized = normalize_heading(title)
        if normalized and normalized not in normalized_pdf:
            missing.append((level, title))
    return missing


def main() -> int:
    if len(sys.argv) not in (3, 4):
        print("Usage: python check_fidelity.py <source.md> <compiled.pdf> [source-code.txt]")
        return 2

    md_path = Path(sys.argv[1])
    pdf_path = Path(sys.argv[2])
    md_text = md_path.read_text(encoding="utf-8")
    structure = extract_md_structure(md_text)
    code_blocks = extract_fenced_code_blocks(md_text)

    try:
        pdf_text = pdf_to_text(str(pdf_path))
    except (subprocess.CalledProcessError, FileNotFoundError) as exc:
        print(f"ERROR: could not extract text from PDF: {exc}")
        return 1

    pdf_units = count_text_units(pdf_text)
    source_units = structure["text_units"]
    ratio = pdf_units / source_units if source_units else 1.0
    missing = missing_headings(structure["headings"], pdf_text)
    issues: list[str] = []

    if missing:
        issues.append(f"Source headings not found in the PDF: {[title for _, title in missing]}")
    if ratio < 0.80:
        issues.append(
            f"PDF text-unit count is too low ({pdf_units}/{source_units}, ratio {ratio:.2f}); "
            "content may have been dropped."
        )
    # Each generated code appendix adds labels, language metadata, and line
    # numbers that are not literal Markdown content. Allow a small, bounded
    # overhead per block without weakening the ordinary duplication check.
    code_overhead = 24 * len(code_blocks)
    if pdf_units > source_units * 1.45 + code_overhead:
        issues.append(
            f"PDF text-unit count is too high ({pdf_units}/{source_units}, ratio {ratio:.2f}); "
            "check for duplicated text or template leakage."
        )

    first_page = pdf_text.split("\f", 1)[0]
    compact_first = re.sub(r"\s+", "", first_page)
    if "摘要" not in compact_first:
        issues.append("The first PDF page does not appear to contain the abstract heading.")
    if "关键词" not in compact_first:
        issues.append("The first PDF page does not appear to contain keywords.")
    if re.search(r"(?m)^\s*目\s*录\s*$", pdf_text):
        issues.append("A table of contents marker was found; CUMCM 2025 says not to include one.")
    leaked = [token for token in PLACEHOLDERS if token in pdf_text]
    if leaked:
        issues.append(f"Unreplaced template placeholders found: {leaked}")

    if code_blocks:
        compact_pdf = re.sub(r"\s+", "", pdf_text)
        if "附录：源代码" not in compact_pdf:
            issues.append("Source contains fenced code, but the PDF has no source-code appendix.")
        missing_labels = [
            block.index
            for block in code_blocks
            if f"代码{block.index}" not in compact_pdf
        ]
        if missing_labels:
            issues.append(f"Code block labels not found in the PDF appendix: {missing_labels}")

        if len(sys.argv) != 4:
            issues.append("Source contains fenced code, but source-code.txt was not supplied.")
        else:
            txt_path = Path(sys.argv[3])
            if not txt_path.is_file():
                issues.append(f"Source-code TXT does not exist: {txt_path}")
            else:
                txt_content = txt_path.read_text(encoding="utf-8")
                missing_txt = [
                    block.index for block in code_blocks if block.content not in txt_content
                ]
                if missing_txt:
                    issues.append(
                        f"Code blocks not preserved verbatim in source-code.txt: {missing_txt}"
                    )

    print("=== CUMCM Fidelity Check ===")
    print(f"Source headings: {len(structure['headings'])}")
    print(
        f"Source lists: {structure['list_items']} bullet, "
        f"{structure['numbered_items']} numbered"
    )
    print(
        f"Source images: {structure['images']}, links: {structure['links']}, "
        f"table rows: {structure['table_rows']}, code blocks: {structure['code_blocks']}"
    )
    print(f"Source text units: {source_units}")
    print(f"PDF text units: {pdf_units} (ratio {ratio:.2f})")

    if issues:
        print("\nPOTENTIAL ISSUES:")
        for issue in issues:
            print(f"  - {issue}")
        return 1

    print("\nNo major extractable-content discrepancies found.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

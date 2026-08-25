---
name: md-to-latex-paper
description: Convert Chinese mathematical-modeling Markdown, including fenced code blocks, into an anonymous CUMCM-style LaTeX paper, PDF, and source-code TXT. Use for 全国大学生数学建模竞赛/CUMCM paper typesetting or when a user asks to turn a modeling-paper Markdown file into LaTeX/PDF with code preserved in a final appendix.
---

# CUMCM Markdown to LaTeX Paper

Create a faithful, readable Chinese mathematical-modeling paper from Markdown. The official 2025 rules are the compliance authority; the bundled visual system is a conservative implementation inspired by the supplied award-paper sample.

## Required references

Before authoring, read [references/cumcm-2025-body-format.md](references/cumcm-2025-body-format.md). Use [assets/template.tex](assets/template.tex) as the LaTeX base.

## Scope

This skill handles:

- the electronic paper beginning with its one-page abstract;
- body sections, formulas, figures, tables, explanatory notes, citations, and references;
- fenced code blocks preserved in a UTF-8 TXT and typeset after the references as a source-code appendix;
- XeLaTeX compilation and PDF fidelity/visual verification.

Do not add the promise page, judging-number page, author, school, region, team number, advisor, or other identity information to the electronic paper. When fenced code exists, the source-code appendix and TXT are required parts of this skill's output.

## Workflow

### 1. Inspect all inputs

Read the complete Markdown and inventory:

- paper title, abstract, keywords, and body headings;
- equations and whether any are referenced later;
- figures and their local/remote paths, captions, and sources;
- tables, units, notes, and cross-references;
- citations and reference entries;
- fenced code blocks, their language tags, optional filenames, and source order;
- any content that could reveal participant identity.

Do not invent authors, schools, experimental results, citations, or missing variables. If abstract or keywords are absent, preserve explicit placeholders and report them; draft them only if the user explicitly asks.

### 2. Apply the Markdown contract

Preferred source structure:

```markdown
# 论文标题

## 摘要
摘要正文……

**关键词：** 关键词1；关键词2；关键词3

## 一、问题重述
### 1.1 问题背景
#### 1.1.1 研究内容
```

Interpret the first H1 as the title. Treat an H2 named `摘要` as the abstract and extract a `关键词` line from it. Subsequent H2/H3/H4 headings become `\section`, `\subsection`, and `\subsubsection`; remove manually typed heading numbers before applying LaTeX numbering so numbers are not duplicated.

Map content as follows:

- ordinary paragraphs: justified Chinese body text with a two-character first-line indent;
- unordered lists: compact `itemize`; use them only for true lists, not to fake headings;
- ordered lists: compact `enumerate`;
- display math: `equation` when referenced or numbered, `equation*` when deliberately unnumbered;
- multi-line derivations: `aligned`, `gathered`, `cases`, or `split` inside one numbered equation as appropriate;
- figures: centered `figure`, caption below, stable `\label{fig:...}` after `\caption`;
- tables: `table` with caption above, `booktabs` three-line rules, no vertical rules, stable `\label{tab:...}` after `\caption`;
- a table-specific note: `\begin{tablenotes}` and begin with `注：`;
- citations: numeric order of first appearance, rendered as `[1]` in the reference list;
- fenced code blocks: remove them from their original body position and preserve them in source order for the final code appendix; explain the algorithm in prose or pseudocode in the body when needed, but do not duplicate full implementation code there.

Never silently drop HTML, diagrams, images, equations, tables, or citations. Resolve local paths relative to the Markdown file. Copy required local assets into the output project while preserving sensible subdirectories. Convert unsupported image formats to PDF or PNG. If an image cannot be resolved, insert a visible placeholder and report it.

### 3. Preserve fenced code blocks

When the Markdown contains fenced code blocks, run:

```bash
python scripts/extract_code_blocks.py source.md output/project
```

The extractor creates:

- `source-code.txt`, a UTF-8 concatenation of every code block in source order with language, title, source line, and generated-file metadata;
- `code-appendix.tex`, which typesets the same blocks after the paper body and references;
- `code/001.ext`, `code/002.ext`, and so on, containing the exact code bytes represented by the normalized UTF-8 Markdown text.

Use an info string such as ```` ```python title="model.py" ```` when the source provides a meaningful filename. `filename=` and `file=` are also accepted. If no title is supplied, generate a neutral name from the block number and language. Never rewrite, reindent, translate, truncate, or silently repair extracted code. Generated display filenames must not overwrite user-authored files.

All fenced blocks are included, including pseudocode, shell commands, text output, and Mermaid source. A rendered diagram or summarized result may also appear in the body, but its fenced source remains in the appendix. Inline code spans are ordinary prose and are not extracted.

For table sizing, preserve the document's typographic hierarchy:

- do not use unconditional `\resizebox{\textwidth}{!}{...}` or `\scalebox` on tables, because either command can enlarge a naturally narrower table and make it visually dominate the page;
- keep a table at its natural width when it already fits; use `tabularx` to distribute genuinely flexible columns;
- for a table that may be wider than the text block, use `adjustbox` with `max width=\linewidth` so it can shrink but never grow;
- keep table body text at `\small` or the body baseline unless a dense table genuinely needs `\footnotesize`; never enlarge it above body text merely to fill the line;
- place shared units in column headings and shorten repeated wording before resorting to scaling or landscape layout.

### 4. Typeset formulas and explanations

Treat a displayed formula as part of its sentence:

- introduce it with prose, usually ending in a Chinese colon;
- keep mathematical commas/periods semantically correct;
- put prose such as conditions inside `\text{}`;
- define symbols immediately afterward with `其中，…` or `式中，…`;
- print equation numbers as `(1)`, `(2)`, … continuously through the paper;
- refer to them in Chinese prose as `式（\ref{eq:...}）`, using full-width Chinese parentheses in prose;
- italicize scalar variables; use bold italic for vectors and matrices; keep operators, units, and descriptive subscripts upright;
- use `\SI{300}{\meter\per\second}` or equivalent upright units, with a space between value and unit.

Do not use `$...$` for long or multi-line formulas. Avoid manual equation numbers and do not place equation numbers inside images.

### 5. Fill the template

Copy `assets/template.tex` into a dedicated output directory and replace only the marked fields:

- `PAPER_TITLE`
- `PAPER_ABSTRACT`
- `PAPER_KEYWORDS`
- `PAPER_BODY`
- `PAPER_CODE_APPENDIX`

Set `PAPER_CODE_APPENDIX` to `\input{code-appendix.tex}` when fenced code blocks exist and leave it empty otherwise. Place it after the body and reference list so the source code is at the end of the paper. Code appendix pages continue the document's Arabic page numbering. Use the generated appendix rather than copying code manually into LaTeX.

Keep the electronic paper anonymous. Do not call `\maketitle`; the template provides the required abstract-first opening. Do not generate a table of contents.

The default body style is intentionally compact and conservative: A4, 2.5 cm margins, 10.5 pt Song-style Chinese body text, 1.25 line spacing, centered Chinese-numbered first-level headings, black links, centered footer page numbers, figures below and tables above. Change these only when the user or a regional rule explicitly requires it.

### 6. Compile with XeLaTeX

Compile from the output directory:

```bash
latexmk -xelatex -interaction=nonstopmode -halt-on-error paper.tex
```

If `latexmk` is unavailable, run XeLaTeX at least twice:

```bash
xelatex -interaction=nonstopmode -halt-on-error paper.tex
xelatex -interaction=nonstopmode -halt-on-error paper.tex
```

Use XeLaTeX, not pdfLaTeX, because the template uses Unicode Chinese fonts. Read the log and fix errors, undefined references, missing glyphs, overfull boxes that visibly affect layout, and missing assets. Do not treat a produced PDF as success when compilation returned a failure.

### 7. Run the mandatory two-pass acceptance gate

The first successfully compiled PDF is a review build, not a deliverable. Do not hand it off immediately.

#### Pass A: content fidelity and full-page review

Run the fidelity checker. Pass the generated TXT whenever the source contains code:

```bash
python scripts/check_fidelity.py source.md paper.pdf source-code.txt
```

Render every page of the review build to PNG at a legible resolution and inspect every page in order. Keep the page number traceable in each filename.

```bash
mkdir -p tmp/pdfs/paper-review
pdftoppm -png -r 150 paper.pdf tmp/pdfs/paper-review/page
```

The rendered PNGs are QA evidence, not final deliverables. Inspect the complete page first, then zoom or crop every figure/image region and every table region. Compare those regions with the Markdown, source assets, and surrounding body typography. Confirm:

- A4 page size and margins of at least 2.5 cm;
- the electronic PDF begins with the abstract page, which is page 1 and fits on one page;
- body begins on the next page and no table of contents appears;
- headings do not duplicate numbers and no heading is stranded at a page bottom;
- equation numbers are right-aligned, unique, continuous, and referenced correctly;
- figures/images are complete, sharp, undistorted, correctly cropped, and have captions below;
- tables have captions above, fit inside the text block, preserve all rows and columns, and use a restrained font and row height consistent with the body;
- no table has been enlarged merely to occupy `\textwidth`; a short table should remain naturally compact, while a wide table may shrink only as much as necessary;
- table notes, units, brackets, punctuation, and reference labels are consistent;
- no clipping, overlap, missing glyphs, black boxes, blue links, placeholder tokens, or identity information appears;
- page breaks do not create avoidable near-empty trailing pages or isolated captions/headings;
- when code exists, `source-code.txt` contains every fenced block verbatim and the PDF ends with `附录：源代码` containing every numbered code block in source order;
- code lines wrap without running beyond the page, line numbers remain readable, Chinese comments and symbols render correctly, and page breaks do not hide or overlap code;
- the main text is preferably within 20 pages; if it exceeds 20, report it rather than shrinking text below the template baseline.

Record each discrepancy with page number, region (`full page`, `figure`, `table`, `equation`, or `text`), observed problem, and intended correction. Treat missing content, clipping, overlap, unreadable text, distorted images, oversized tables, wrong caption placement, and identity leakage as delivery-blocking issues.

#### Pass B: correction and final reinspection

Correct every delivery-blocking issue, recompile the PDF, rerun the fidelity checker, and render it again to a fresh review directory. Reinspect all changed pages, all figure/table regions, and every code-appendix page; then scan every page once more because float movement and page reflow can introduce defects elsewhere.

Do not deliver until the latest render is clean and the final response can state that both passes were completed. If a discrepancy cannot be resolved without changing source meaning or inventing data, preserve the source, report the unresolved item, and do not describe the PDF as fully verified.

## Deliverables

Deliver the `.tex`, compiled `.pdf`, and any asset subfolders required to recompile only after the two-pass acceptance gate. When fenced code exists, also deliver `source-code.txt`, `code-appendix.tex`, and the generated `code/` files. Briefly report assumptions, unresolved assets/citations, whether the abstract fits one page, the main-text and appendix page counts, the number of preserved code blocks, any justified deviation from the 2025 format contract, and the result of the final visual inspection of screenshots, figures, tables, and code pages.

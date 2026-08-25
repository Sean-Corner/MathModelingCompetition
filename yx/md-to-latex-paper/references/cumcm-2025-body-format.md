# CUMCM 2025 abstract and body format contract

This reference is based on the supplied `format2025.doc` and the body pages of the supplied award-paper sample. Treat official requirements as mandatory and sample-derived choices as the default visual system, not as extra national rules.

## 1. Mandatory 2025 requirements

- Paper: white A4.
- Margins: at least 2.5 cm on all four sides.
- The electronic paper must not contain the promise page or judging-number page. Its first page must be the abstract page.
- The abstract page includes the title, abstract, and keywords; no English translation is required; the complete abstract page must not exceed one page.
- Page numbering begins on the abstract page at Arabic numeral 1, centered in the footer, and continues through the body and appendix.
- The body follows the abstract page. Do not include a table of contents. Keep the body within 20 pages where practical.
- The appendix follows the body and references. Appendix length is unrestricted; when fenced code exists, preserve it in the source-code appendix defined below.
- The abstract, body, and appendix must not identify participants, school, region, or other identity information.
- Cite all borrowed or public material in the body and list it as a scientific reference.
- The paper and supporting-material rules must also satisfy the 2025 trial rules on AI-tool use. Do not invent an AI-use declaration; preserve or request the team's actual disclosure.
- Electronic paper size must not exceed 20 MB.

The official document explicitly states that it does not impose one national font, size, line spacing, or color scheme. The tokens below are therefore a reproducible default derived from the supplied sample and common Chinese scientific-paper practice.

## 2. Default visual tokens

| Role | Default |
|---|---|
| Page | A4 portrait |
| Margins | 2.5 cm each side |
| Chinese body | Song-style, 五号 (10.5 pt) |
| Latin/math | Times New Roman |
| Body rhythm | justified, two-character first-line indent, 1.25 line spacing, no extra paragraph gap |
| Paper title | Heiti, 三号 (16 pt), centered |
| “摘要” | Heiti, 四号 (14 pt), centered with modest character spacing |
| First-level heading | Heiti, 四号, centered, Chinese numbering such as `一、问题重述` |
| Second-level heading | Heiti, 五号, left aligned, `1.1 问题背景` |
| Third-level heading | Heiti, 五号, left aligned, `1.1.1 模型建立` |
| Footer | centered Arabic page number, no header rule |
| Color | black text and black links; color only when a figure requires it |

Do not reduce body text below 五号 merely to meet the preferred page count. Report excessive length and improve content density first.

## 3. Abstract page

Order:

1. paper title;
2. centered `摘 要` label;
3. abstract body, normally several coherent paragraphs;
4. `关键词：` followed by 3–6 terms separated with Chinese semicolons `；`.

The abstract should state the problem, method/model, key result, and conclusion. It must fit on page 1. No author, date, team number, school, English title, or English abstract is added.

## 4. Heading and paragraph details

- Do not create a table of contents.
- Do not type section numbers into both Markdown and LaTeX. Strip source numbers before using automatic numbering.
- Keep a heading with at least two following lines; avoid a heading alone at a page bottom.
- Body paragraphs use Chinese full-width punctuation and a two-character first-line indent.
- Do not indent the first paragraph immediately after a displayed formula, figure, table, or list when it starts with `其中，`, `式中，`, `注：`, or a short transition that visually belongs to the preceding object.
- Use bold sparingly for result values, step labels, or short term definitions. Do not simulate hierarchy with arbitrary bold paragraphs.

## 5. Formula grammar and annotation

### Display and numbering

- Center displayed equations.
- Place one automatically generated number at the right edge: `(1)`, `(2)`, …, continuous through the paper.
- Give a label only when the equation will be referenced: `\label{eq:motion}`.
- In Chinese prose, write `由式（\ref{eq:motion}）可得` rather than manually typing a number. The printed equation uses half-width `(1)`; the prose reference uses full-width Chinese `（1）`.
- One conceptual derivation with aligned lines should normally have one equation number. Use `aligned`, `split`, or `cases` inside `equation`; do not number every cosmetic line.

### Sentence and punctuation

- Introduce a formula with a complete sentence, usually ending in `：`.
- A formula remains part of the sentence. Put necessary comma/period semantics in the formula or in the following prose.
- Follow promptly with `其中，…` or `式中，…` and define every new symbol, index, set, and parameter.
- Use `\text{}` for Chinese words or logical conditions inside math. Do not fake them with italic Latin text.

### Symbols and units

- Scalars: italic Latin/Greek, e.g. `$t$`, `$v$`, `$\alpha$`.
- Vectors and matrices: bold italic, e.g. `\vect{x}` and `\mat{A}`.
- Standard operators and functions: upright, e.g. `\sin`, `\max`, `\mathrm{d}t`.
- Descriptive subscripts and abbreviations: upright, e.g. `$T_{\mathrm{eff}}$`.
- Units: upright with a space after the value, preferably through `siunitx`, e.g. `\SI{300}{\meter\per\second}`. Do not italicize `m/s`, `s`, or `kg`.
- Use ordinary parentheses `( )` in math; use scalable `\left(\right)` only when the enclosed material needs it. Use brackets and braces according to grouping semantics, not decoration.

## 6. Figures

- Center the figure and keep it inside the text width.
- Use high-resolution PDF/PNG/JPG; charts must have legible axis labels, units, legends, and tick labels.
- Caption goes below: `图 1 坐标系示意图`. Do not end a short caption with a period.
- Put `\label` immediately after `\caption`.
- Refer to every figure in the body before or near its appearance (`见图 1`). Do not use “上图/下图”.
- A source or explanatory note belongs below the caption, starting with `注：` or `资料来源：`, in a smaller font.

## 7. Tables

- Caption goes above: `表 1 主要参数与符号说明`.
- Default to a three-line table (`\toprule`, `\midrule`, `\bottomrule`) with no vertical rules.
- Put units in column headings, not repeatedly in every cell, when a whole column shares the same unit.
- Align numbers by decimal meaning where feasible; center short categorical values; left-align narrative text.
- Use `tabularx`, `longtable`, or a landscape page when necessary. Do not shrink a wide table until it is unreadable.
- A table note goes directly below and begins `注：`. Use `threeparttable`/`tablenotes` for scoped notes.
- Refer to every table by number (`见表 2`), not “上表/下表”.

## 8. Lists, steps, and notes

- Use numbered lists when order matters and bullets when it does not.
- For algorithms, short bold labels such as `Step 1：` are acceptable, followed by an indented explanation. Keep the style consistent across all steps.
- Use `注：` for a local explanatory note and `其中，`/`式中，` for symbol definitions. Do not overload footnotes with model assumptions that belong in the body.
- If a true footnote is necessary, use an automatically numbered superscript and keep the note concise. References belong in the reference list, not only in footnotes.

### Source-code appendix

- When the Markdown contains fenced code, place the full implementation after the references under `附录：源代码`; do not interrupt the modeling narrative with long source listings.
- Preserve the original block order and content. Show a language and filename/title when known, and use neutral generated names otherwise.
- Continue Arabic page numbering through the appendix. Code must wrap inside the text block, retain readable line numbers, and render Chinese comments and symbols correctly.
- Deliver the same code separately as UTF-8 `source-code.txt` plus extracted code files so PDF line wrapping cannot be mistaken for the executable source.
- A rendered Mermaid diagram or summarized program result may appear in the body, but its fenced source still belongs in the appendix.

## 9. Citations and references

- Cite in order of first appearance with numeric labels.
- Reference list heading uses the normal first-level heading style, e.g. `七、参考文献`.
- Each entry begins `[1]`, `[2]`, … and uses a hanging visual alignment.
- Preserve complete bibliographic facts supplied by the source. Do not fabricate authors, dates, volumes, pages, URLs, or access dates.
- Use a consistent Chinese scientific-reference style across journals `[J]`, books `[M]`, proceedings `[C]`, dissertations `[D]`, reports `[R]`, standards `[S]`, patents `[P]`, and online resources `[EB/OL]`.

## 10. Preflight checklist

- Abstract page is exactly one page and is numbered 1.
- Body starts on page 2; no contents page exists.
- A4 and all margins are at least 2.5 cm.
- No identity information appears.
- Heading numbers are automatic and non-duplicated.
- Equations are continuous, referenced, and explained; brackets and units are consistent.
- Figure captions are below; table captions are above; every item is referenced.
- Three-line tables are legible and do not overflow.
- References are cited and complete.
- PDF is below 20 MB and all fonts/glyphs render correctly.

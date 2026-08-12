#!/usr/bin/env bash
set -u

usage() {
  cat <<'EOF'
Usage:
  writing_check.sh --paper FILE [options]

Options:
  --paper FILE           Markdown paper file to check. Auto-detected from paper/*.md when omitted.
  --root-dir DIR         Project root. Defaults to the parent of paper's directory.
  --figures-dir DIR      Figure directory. Defaults to <root-dir>/figures when it exists.
  --results-file FILE    Result summary file. Defaults to <root-dir>/reports/RESULTS_REPORT.md when it exists.
  --problem-analysis FILE
                          Problem analysis file, used only for soft consistency checks.
  --all-results FILE     Aggregated JSON result file. Defaults to <figures-dir>/all_results.json.
  --internal-term TEXT   Extra internal workflow term to reject in paper body. Repeatable.
  --no-internal-check    Skip internal workflow filename leak check.
  -h, --help             Show this help.

The script intentionally accepts paths from the caller. Defaults are convenience
fallbacks only; the verification skill should infer the project layout and pass
the actual paper file it wants checked.
EOF
}

PAPER_FILE="${PAPER_FILE:-}"
ROOT_DIR="${ROOT_DIR:-}"
FIGURES_DIR="${FIGURES_DIR:-}"
RESULTS_FILE="${RESULTS_FILE:-}"
PROBLEM_ANALYSIS_FILE="${PROBLEM_ANALYSIS_FILE:-}"
ALL_RESULTS_FILE="${ALL_RESULTS_FILE:-}"
NO_INTERNAL_CHECK="${NO_INTERNAL_CHECK:-0}"
EXTRA_INTERNAL_TERMS=()
POSITIONAL=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --paper)
      PAPER_FILE="${2:-}"
      shift 2
      ;;
    --root-dir)
      ROOT_DIR="${2:-}"
      shift 2
      ;;
    --figures-dir)
      FIGURES_DIR="${2:-}"
      shift 2
      ;;
    --results-file)
      RESULTS_FILE="${2:-}"
      shift 2
      ;;
    --problem-analysis)
      PROBLEM_ANALYSIS_FILE="${2:-}"
      shift 2
      ;;
    --all-results)
      ALL_RESULTS_FILE="${2:-}"
      shift 2
      ;;
    --internal-term)
      EXTRA_INTERNAL_TERMS+=("${2:-}")
      shift 2
      ;;
    --no-internal-check)
      NO_INTERNAL_CHECK=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      while [ "$#" -gt 0 ]; do
        POSITIONAL+=("$1")
        shift
      done
      ;;
    -*)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
    *)
      POSITIONAL+=("$1")
      shift
      ;;
  esac
done

if [ -z "$PAPER_FILE" ] && [ "${#POSITIONAL[@]}" -gt 0 ]; then
  PAPER_FILE="${POSITIONAL[0]}"
fi

export PAPER_FILE ROOT_DIR FIGURES_DIR RESULTS_FILE PROBLEM_ANALYSIS_FILE ALL_RESULTS_FILE NO_INTERNAL_CHECK
if [ "${#EXTRA_INTERNAL_TERMS[@]}" -gt 0 ]; then
  EXTRA_INTERNAL_TERMS_STR="$(printf '%s\n' "${EXTRA_INTERNAL_TERMS[@]}")"
else
  EXTRA_INTERNAL_TERMS_STR=""
fi
export EXTRA_INTERNAL_TERMS_STR

python3 - <<'PY'
import json
import os
import re
import sys
from pathlib import Path

exit_code = 0

def fail(msg):
    global exit_code
    print(f"FAIL: {msg}")
    exit_code = 1

def warn(msg):
    print(f"WARN: {msg}")

def info(msg):
    print(f"INFO: {msg}")

def opt_path(name):
    value = os.environ.get(name, "").strip()
    return Path(value) if value else None

def read(path):
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        return path.read_text(encoding="utf-8", errors="ignore")

# Resolve paper file
paper_env = os.environ.get("PAPER_FILE", "").strip()
paper = Path(paper_env) if paper_env else None
if paper is None:
    candidates = []
    for pattern in ["paper/*.md", "paper/**/*.md", "*.md"]:
        candidates += list(Path(".").glob(pattern))
    preferred = [p for p in candidates if any(k in p.name for k in ("草稿", "竞赛论文", "论文"))]
    if preferred:
        paper = preferred[0]
        info(f"auto-detected paper: {paper}")
    elif candidates:
        paper = candidates[0]
        info(f"auto-detected paper: {paper}")
    else:
        paper = Path("paper/竞赛论文(草稿).md")

root_env = os.environ.get("ROOT_DIR", "").strip()
root = Path(root_env) if root_env else (paper.parent.parent if paper.parent.name == "paper" else paper.parent)
figures_dir = opt_path("FIGURES_DIR")
results_file = opt_path("RESULTS_FILE")
problem_analysis = opt_path("PROBLEM_ANALYSIS_FILE")
all_results = opt_path("ALL_RESULTS_FILE")
no_internal_check = os.environ.get("NO_INTERNAL_CHECK") == "1"
extra_internal_terms = [
    item for item in os.environ.get("EXTRA_INTERNAL_TERMS_STR", "").splitlines() if item.strip()
]

if not figures_dir and (root / "figures").exists():
    figures_dir = root / "figures"
if not results_file:
    for cand in [root / "reports" / "RESULTS_REPORT.md", root / "RESULTS_REPORT.md"]:
        if cand.exists():
            results_file = cand
            break
if not problem_analysis and (root / "PROBLEM_ANALYSIS.md").exists():
    problem_analysis = root / "PROBLEM_ANALYSIS.md"
if not all_results and figures_dir and (figures_dir / "all_results.json").exists():
    all_results = figures_dir / "all_results.json"

info(f"paper file: {paper}")
info(f"root dir: {root}")
if figures_dir:
    info(f"figures dir: {figures_dir}")
if results_file:
    info(f"results file: {results_file}")

if not paper.exists():
    fail(f"paper file not found: {paper}")
    sys.exit(exit_code)

paper_text = read(paper)

# 1. placeholder check
placeholder_re = re.compile(r"PLACEHOLDER|TODO|TBD|XXX|待补充|待续写|这里补|示例数据|待完善")
if placeholder_re.search(paper_text):
    fail("placeholder text remains in paper")

# 2. internal workflow term leak check
default_internal_terms = [
    "RESULTS_REPORT", "ANALYSIS_MODELING_REPORT.md", "PROBLEM_ANALYSIS.md",
    "CLAUDE.md", "figures/*.json", "_tmp/",
]
internal_terms = default_internal_terms + extra_internal_terms
if results_file:
    internal_terms.append(results_file.name)
if problem_analysis:
    internal_terms.append(problem_analysis.name)
if all_results:
    internal_terms.append(all_results.name)
internal_terms = sorted(set(t for t in internal_terms if t))
internal_re = re.compile("|".join(re.escape(t) for t in internal_terms)) if internal_terms else None
if not no_internal_check and internal_re and internal_re.search(paper_text):
    fail("internal workflow term leaked into paper text")

# 3. markdown level-1 headings
heading_re = re.compile(r"(?m)^#\s+(.+)")
headings = heading_re.findall(paper_text)
info(f"level-1 heading count: {len(headings)}")
if not headings:
    fail("paper has no level-1 markdown heading (`# `)")
if len(headings) != len(set(headings)):
    fail("duplicate level-1 headings detected")

# 4. image reference existence
base = paper.parent
for ref in re.findall(r"!\[[^\]]*\]\(([^)\s]+)", paper_text):
    if ref.startswith(("http://", "https://", "data:")):
        continue
    target = (base / ref).resolve()
    if not target.exists():
        fail(f"referenced image does not exist from {paper.name}: {ref}")

# 5. figure alt-text / caption presence
for alt, _ in re.findall(r"!\[([^\]]*)\]\(([^)\s]+)", paper_text):
    if not alt.strip():
        fail("figure without caption (empty alt text)")

# 6. unused figure warning
if figures_dir and figures_dir.exists():
    for fig in sorted(figures_dir.glob("*.png")):
        if fig.name not in paper_text:
            warn(f"figure PNG not referenced in paper: {fig.name}")

# 7. metric consistency
if results_file and results_file.exists():
    results_text = read(results_file)
    metric_names = re.findall(
        r"(?i)\b(?:rmse|mae|mape|r2|score|objective|accuracy|precision|recall|f1|"
        r"权重|目标值|误差|得分)\b",
        results_text,
    )
    if metric_names and not any(name.lower() in paper_text.lower() for name in metric_names[:20]):
        warn("metrics appear in result file but are hard to find in paper text")
else:
    info("results file not supplied/found; skip metric consistency scan")

# 8. all-results JSON numeric scan
if all_results and all_results.exists():
    try:
        data = json.loads(read(all_results))
        nums = []

        def walk(value):
            if isinstance(value, dict):
                for item in value.values():
                    walk(item)
            elif isinstance(value, list):
                for item in value:
                    walk(item)
            elif isinstance(value, (int, float)):
                nums.append(value)

        walk(data)
        key_nums = []
        for num in nums[:100]:
            if abs(num) >= 1:
                key_nums.append(str(round(num, 4)).rstrip("0").rstrip("."))
        if key_nums and not any(num and num in paper_text for num in key_nums[:30]):
            warn("numeric values from all-results JSON are hard to find in paper")
    except Exception as exc:
        warn(f"cannot parse all-results JSON: {exc}")
else:
    info("all-results JSON not supplied/found; skip JSON numeric scan")

# 9. references light check
if not re.search(r"参考文献|References|references", paper_text):
    warn("no references section markers detected in paper")

if exit_code == 0:
    print("PASS: writing text gate passed")
else:
    print("FAIL: writing text gate failed")

sys.exit(exit_code)
PY

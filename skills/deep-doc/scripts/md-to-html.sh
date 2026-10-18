#!/usr/bin/env bash
# md-to-html.sh: make quick HTML pages from Markdown docs, with no writing by
# Claude. The Markdown is embedded in the shared page shell and rendered in the
# browser (contents sidebar, light/dark, Mermaid diagrams, ```chart blocks,
# > [!NOTE] callouts, tables). Pages go to docs/visual/.
# Compatible with bash 3.2+.
#
# Usage: md-to-html.sh [--project DIR] [--force] FILE.md...
#        md-to-html.sh [--project DIR] [--force] --all
#
#   --all      every doc in docs/ and every report in research/
#   --force    also replace rich pages (written by Claude) with quick ones
#   --project  project folder (default: $CLAUDE_PROJECT_DIR, else the current folder)

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
WRAP="$SCRIPT_DIR/wrap-page.sh"

die() { printf 'md-to-html: %s\n' "$*" >&2; exit 1; }

ROOT=${CLAUDE_PROJECT_DIR:-$PWD}; FORCE=no; ALL=no; FILES=
nl='
'
while [ "$#" -gt 0 ]; do
  case "$1" in
    --project) [ "$#" -ge 2 ] || die "--project needs a value"; ROOT=$2; shift ;;
    --force)   FORCE=yes ;;
    --all)     ALL=yes ;;
    -h|--help) sed -n '2,15p' "$0"; exit 0 ;;
    -*)        die "unknown option: $1" ;;
    *)         FILES="$FILES$1$nl" ;;
  esac
  shift
done
[ -d "$ROOT/docs" ] || die "no docs/ folder in $ROOT (use --project, or run from the project root)"
ROOT=$(cd "$ROOT" && pwd)
[ "$ALL" = yes ] || [ -n "$FILES" ] || die "give Markdown files, or --all (see --help)"

page_name() {  # project-relative .md path -> page file name in docs/visual
  case "$1" in
    docs/README.md)     echo index.html; return 0 ;;
    research/README.md) echo research-README.html; return 0 ;;
    docs/visual/*|*/README.md) return 1 ;;
    docs/*.md)          p=${1#docs/} ;;
    research/*.md)      p=research/${1#research/} ;;
    *)                  return 1 ;;
  esac
  p=${p%.md}
  printf '%s.html\n' "$(printf '%s' "$p" | tr '/' '-')"
}

if [ "$ALL" = yes ]; then
  FILES=$( { echo "$ROOT/docs/README.md";
             find "$ROOT/docs" -name '*.md' ! -name README.md ! -path '*/visual/*';
             [ -d "$ROOT/research" ] && find "$ROOT/research" -name '*.md'; } | LC_ALL=C sort)
fi

DATE=$(date +%Y-%m-%d)
OUT_DIR="$ROOT/docs/visual"
mkdir -p "$OUT_DIR" || die "could not create $OUT_DIR"
MADE=0; KEPT=0; FAILED=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  case "$f" in /*) ;; *) [ -f "$ROOT/$f" ] && f="$ROOT/$f" ;; esac  # relative paths: project first
  [ -f "$f" ] || { echo "  skipped   $f (not found)"; FAILED=$((FAILED + 1)); continue; }
  abs="$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
  case "$abs" in
    "$ROOT"/*) rel=${abs#"$ROOT"/} ;;
    *) echo "  skipped   $f (not inside $ROOT)"; FAILED=$((FAILED + 1)); continue ;;
  esac
  name=$(page_name "$rel") || { echo "  skipped   $rel (only docs/ and research/ Markdown becomes pages)"; continue; }
  out="$OUT_DIR/$name"
  if [ "$FORCE" = no ] && [ -f "$out" ] && grep -q 'data-kind="rich"' "$out"; then
    echo "  kept      docs/visual/$name (rich page; regenerate it by asking for a rich page, or use --force)"
    KEPT=$((KEPT + 1)); continue
  fi

  # The first "# " heading becomes the page title; the rest is the body.
  title=$(sed -n 's/^# \{1,\}//p' "$abs" | head -n 1)
  [ -n "$title" ] || title=$(basename "$rel" .md)
  body="$OUT_DIR/.$name.body.html"
  {
    printf '<script type="text/markdown" id="md-source" data-encoding="base64">'
    awk 'done == 0 && /^# / { done = 1; next } { print }' "$abs" | base64 | tr -d '\r\n'
    printf '</script>\n'
  } > "$body" || die "could not write $body"
  if bash "$WRAP" --title "$title" --meta "Generated from $rel on $DATE. Do not edit this page: change the Markdown and regenerate." \
       --source "$rel" --project "$ROOT" --kind quick --body "$body" --out "$out" --remove-body >/dev/null; then
    echo "  made      docs/visual/$name  <-  $rel"
    MADE=$((MADE + 1))
  else
    rm -f "$body"; FAILED=$((FAILED + 1))
  fi
done <<EOF
$FILES
EOF

echo "md-to-html: $MADE page(s) made, $KEPT rich page(s) kept, $FAILED failed."
[ "$FAILED" -eq 0 ]

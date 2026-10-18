#!/usr/bin/env bash
# check-project.sh: check a project against the kit's conventions, mechanically.
# Reports problems; changes nothing. Exit code 0 = all good, 1 = problems found.
# Compatible with bash 3.2+.
#
# Usage: check-project.sh [PROJECT_DIR]
#        (default: $CLAUDE_PROJECT_DIR, else the current folder)

ROOT=${1:-${CLAUDE_PROJECT_DIR:-$PWD}}
[ -d "$ROOT" ] || { echo "check-project: not a folder: $ROOT" >&2; exit 2; }
ROOT=$(cd "$ROOT" && pwd)
PROBLEMS=0
problem() { PROBLEMS=$((PROBLEMS + 1)); printf '  problem  %s\n' "$*"; }
list_files() {  # $1 = folder, then find tests; prints paths, one per line, sorted
  dir=$1; shift
  [ -d "$dir" ] || return 0
  find "$dir" "$@" | LC_ALL=C sort
}

echo "Checking $ROOT"

# 1. The standard files exist.
for p in CLAUDE.md README.md inputs/README.md research/README.md code/README.md \
         docs/README.md docs/charter.md docs/decisions.md docs/learnings.md docs/testing.md \
         docs/tracker.md docs/glossary.md session/README.md session/plans/README.md; do
  [ -e "$ROOT/$p" ] || problem "missing $p (run /new-project again to add missing files)"
done

# 2. Every doc has a row in docs/README.md.
if [ -f "$ROOT/docs/README.md" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    rel=${f#"$ROOT/docs/"}
    grep -qF "]($rel)" "$ROOT/docs/README.md" || problem "docs/README.md has no row for docs/$rel"
  done <<EOF
$(list_files "$ROOT/docs" -name '*.md' ! -name README.md ! -path '*/visual/*')
EOF
fi

# 3. Every research report has a row in research/README.md.
if [ -f "$ROOT/research/README.md" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    rel=${f#"$ROOT/research/"}
    grep -qF "]($rel)" "$ROOT/research/README.md" || problem "research/README.md has no row for research/$rel"
  done <<EOF
$(list_files "$ROOT/research" -type f ! -name README.md ! -name '.*')
EOF
fi

# 4. Every input is listed in inputs/README.md.
if [ -f "$ROOT/inputs/README.md" ]; then
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    name=${f##*/}
    grep -qF "$name" "$ROOT/inputs/README.md" || problem "inputs/README.md doesn't list inputs/${f#"$ROOT/inputs/"}"
  done <<EOF
$(list_files "$ROOT/inputs" -type f ! -name README.md ! -name '.*')
EOF
fi

# 5. Decision and lesson IDs run D-001, D-002, … with no gaps or repeats;
#    task IDs are unique and never above "Last ID used".
check_sequence() {  # $1 = file, $2 = letter
  [ -f "$1" ] || return 0
  expected=1
  while IFS= read -r id; do
    [ -n "$id" ] || continue
    n=${id##*-}; n=$((10#$n))
    if [ "$n" -ne "$expected" ]; then
      problem "${1#"$ROOT/"}: $(printf '%s-%03d' "$2" "$n") found where $(printf '%s-%03d' "$2" "$expected") was expected"
      expected=$n
    fi
    expected=$((expected + 1))
  done <<EOF
$(grep -oE "^## $2-[0-9]+" "$1")
EOF
}
check_sequence "$ROOT/docs/decisions.md" D
check_sequence "$ROOT/docs/learnings.md" L

tracker="$ROOT/docs/tracker.md"
if [ -f "$tracker" ]; then
  dupes=$(grep -oE '^- T-[0-9]+' "$tracker" | LC_ALL=C sort | uniq -d | sed 's/^- //')
  for id in $dupes; do problem "docs/tracker.md: $id is used by more than one task"; done
  last=$(sed -n 's/^\*\*Last ID used:\*\* T-\([0-9]*\).*/\1/p' "$tracker" | head -n 1)
  if [ -z "$last" ]; then
    problem "docs/tracker.md has no '**Last ID used:** T-nnn' line"
  else
    last=$((10#$last))
    max=0
    while IFS= read -r id; do
      [ -n "$id" ] || continue
      n=$((10#$id)); [ "$n" -gt "$max" ] && max=$n
    done <<EOT
$(grep -oE '^- T-[0-9]+' "$tracker" | sed 's/.*-//')
EOT
    [ "$max" -le "$last" ] || problem "docs/tracker.md: tasks go up to T-$(printf '%03d' "$max") but 'Last ID used' says T-$(printf '%03d' "$last")"
  fi
fi

# 6. The handoff stays under 8,000 characters.
if [ -f "$ROOT/session/HANDOFF.md" ]; then
  size=$(wc -c < "$ROOT/session/HANDOFF.md"); size=$((size + 0))
  [ "$size" -lt 8000 ] || problem "session/HANDOFF.md is $size characters (limit 8,000)"
fi

# 7. Plans: finished ones are moved to done/, and every plan in done/ has an Outcome.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  grep -qiE '^\*\*Status:\*\* *done' "$f" && problem "${f#"$ROOT/"} is done but not moved to session/plans/done/"
done <<EOF
$(list_files "$ROOT/session/plans" -maxdepth 1 -name '*.md' ! -name README.md)
EOF
while IFS= read -r f; do
  [ -n "$f" ] || continue
  has_outcome=$(awk '
    /^## Outcome/ { inside = 1; next }
    inside && /^## / { inside = 0 }
    inside && NF && !/^<!--/ && !/^Written when the plan is finished/ { found = 1 }
    END { print found ? "yes" : "no" }' "$f")
  [ "$has_outcome" = yes ] || problem "${f#"$ROOT/"} has no Outcome written"
done <<EOF
$(list_files "$ROOT/session/plans/done" -name '*.md' ! -name README.md)
EOF

# 8. Generated pages match their Markdown source.
while IFS= read -r page; do
  [ -n "$page" ] || continue
  info=$(sed -n 's/.*<meta name="kit-source" content="\([^"]*\)" data-sum="\([^"]*\)".*/\1|\2/p' "$page" | head -n 1)
  name=${page#"$ROOT/"}
  src=${info%%|*}; sum=${info#*|}
  if [ -z "$info" ] || [ -z "$src" ]; then
    problem "$name doesn't record its Markdown source (regenerate it with the kit)"
  elif [ ! -f "$ROOT/$src" ]; then
    problem "$name was generated from $src, which no longer exists"
  elif [ "$(cksum < "$ROOT/$src" | cut -d' ' -f1)" != "$sum" ]; then
    problem "$name is out of date: $src changed since it was generated"
  fi
done <<EOF
$(list_files "$ROOT/docs/visual" -name '*.html')
EOF

# 9. Relative links in Markdown point at files that exist (code blocks are skipped).
extract_links() {
  awk '
    /^[ \t]*(```|~~~)/ { fence = !fence; next }
    fence { next }
    {
      line = $0
      while (match(line, /\]\([^)]*\)/)) {
        print substr(line, RSTART + 2, RLENGTH - 3)
        line = substr(line, RSTART + RLENGTH)
      }
    }' "$1"
}
while IFS= read -r md; do
  [ -n "$md" ] || continue
  dir=$(dirname "$md")
  while IFS= read -r target; do
    target=${target#<}; target=${target%>}
    target=${target%% *}
    case "$target" in
      ''|'#'*|*:*) continue ;;
    esac
    path=${target%%#*}; path=${path%%\?*}
    path=$(printf '%s' "$path" | sed 's/%20/ /g')
    [ -n "$path" ] || continue
    case "$path" in
      /*) full="$ROOT$path" ;;
      *)  full="$dir/$path" ;;
    esac
    [ -e "$full" ] || problem "broken link in ${md#"$ROOT/"}: $target"
  done <<EOF
$(extract_links "$md")
EOF
done <<EOF
$( { [ -f "$ROOT/CLAUDE.md" ] && echo "$ROOT/CLAUDE.md"; [ -f "$ROOT/README.md" ] && echo "$ROOT/README.md";
     list_files "$ROOT/docs" -name '*.md'; list_files "$ROOT/research" -name '*.md';
     list_files "$ROOT/session" -name '*.md'; [ -f "$ROOT/inputs/README.md" ] && echo "$ROOT/inputs/README.md"; } )
EOF

# 10. No unfilled template placeholders.
while IFS= read -r f; do
  [ -n "$f" ] || continue
  grep -qE '\{\{[A-Za-z_]+\}\}' "$f" && problem "unfilled {{placeholder}} in ${f#"$ROOT/"}"
done <<EOF
$( { [ -f "$ROOT/CLAUDE.md" ] && echo "$ROOT/CLAUDE.md"; list_files "$ROOT/docs" -name '*.md'; list_files "$ROOT/session" -name '*.md'; } )
EOF

if [ "$PROBLEMS" -eq 0 ]; then
  echo "check-project: all checks passed"
  exit 0
fi
echo "check-project: $PROBLEMS problem(s)"
exit 1

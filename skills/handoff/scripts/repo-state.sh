#!/usr/bin/env bash
# repo-state.sh: print the git state of every repository in a project
# (the root, code/backend and code/frontend, whichever are repositories).
# Used by the handoff and pickup skills. Compatible with bash 3.2 and later.
#
# Usage: repo-state.sh [PROJECT_DIR]
#        (default: $CLAUDE_PROJECT_DIR, else the current folder)

ROOT=${1:-${CLAUDE_PROJECT_DIR:-$PWD}}
[ -d "$ROOT" ] || { echo "repo-state: not a folder: $ROOT" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "repo-state: git not found" >&2; exit 1; }

FOUND=0
show() {  # $1 = label, $2 = folder
  label=$1; path=$2
  [ -e "$path/.git" ] || return 0
  FOUND=$((FOUND + 1))

  branch=$(git -C "$path" symbolic-ref --short -q HEAD 2>/dev/null) ||
    branch="(detached at $(git -C "$path" rev-parse --short HEAD 2>/dev/null))"
  last=$(git -C "$path" log -1 --format='%h %ad %s' --date=short 2>/dev/null)
  [ -n "$last" ] || last="(no commits yet)"
  changes=$(git -C "$path" status --porcelain 2>/dev/null | wc -l)
  changes=$((changes + 0))

  echo "== $label: $path"
  echo "branch:      $branch"
  echo "last commit: $last"
  echo "uncommitted: $changes file(s)"
  upstream=$(git -C "$path" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null)
  if [ -n "$upstream" ]; then
    counts=$(git -C "$path" rev-list --left-right --count "$upstream...HEAD" 2>/dev/null)
    read -r behind ahead <<EOF
$counts
EOF
    echo "upstream:    $upstream (ahead ${ahead:-?}, behind ${behind:-?})"
  else
    echo "upstream:    none"
  fi
  if [ "$changes" -gt 0 ]; then
    echo "changes:"
    git -C "$path" status --short 2>/dev/null | head -n 20 | sed 's/^/  /'
    [ "$changes" -le 20 ] || echo "  … and $((changes - 20)) more"
  fi
  if [ "$last" != "(no commits yet)" ]; then
    echo "recent commits:"
    git -C "$path" log -5 --format='  %h %ad %s' --date=short 2>/dev/null
  fi
  echo
}

show root "$ROOT"
show backend "$ROOT/code/backend"
show frontend "$ROOT/code/frontend"
[ "$FOUND" -gt 0 ] || echo "No git repositories in $ROOT (checked the root, code/backend and code/frontend)."
exit 0

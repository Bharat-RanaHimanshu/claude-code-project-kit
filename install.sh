#!/usr/bin/env bash
# install.sh: install or update the kit's skills in your personal skill folder.
# Skills that changed are replaced; the old copy is kept in a backup folder.
# Compatible with bash 3.2+ (Git Bash on Windows, macOS, Linux).
#
# Usage: bash install.sh [--target DIR] [--dry-run]
#        (default target: ~/.claude/skills)

KIT_DIR=$(cd "$(dirname "$0")" && pwd)
SRC="$KIT_DIR/skills"
TARGET="$HOME/.claude/skills"
DRY=no

die() { printf 'install: %s\n' "$*" >&2; exit 1; }
while [ "$#" -gt 0 ]; do
  case "$1" in
    --target)  [ "$#" -ge 2 ] || die "--target needs a value"; TARGET=$2; shift ;;
    --dry-run) DRY=yes ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *)         die "unknown option: $1" ;;
  esac
  shift
done
[ -d "$SRC" ] || die "skills/ not found next to install.sh"
TARGET=${TARGET%/}
VERSION=$(tr -d ' \r\n' < "$SRC/new-project/VERSION" 2>/dev/null)
BACKUP="$(dirname "$TARGET")/kit-backups/$(date +%Y%m%d-%H%M%S)"

echo "claude-code-project-kit v${VERSION:-?} -> $TARGET"
[ "$DRY" = no ] || echo "DRY RUN: nothing will be changed."
[ "$DRY" = yes ] || mkdir -p "$TARGET" || die "could not create $TARGET"

backup() {  # move an installed skill folder into the backup folder
  [ "$DRY" = yes ] && return 0
  mkdir -p "$BACKUP" || die "could not create $BACKUP"
  # Backups land inside the repository when the target is a project's .claude/skills:
  # the folder ignores itself, so they are never committed.
  [ -f "${BACKUP%/*}/.gitignore" ] || printf '*\n' > "${BACKUP%/*}/.gitignore" || die "could not write ${BACKUP%/*}/.gitignore"
  mv "$1" "$BACKUP/" || die "could not back up $1"
}

INSTALLED=0; UPDATED=0; SAME=0
for skill in "$SRC"/*/; do
  skill=${skill%/}
  name=${skill##*/}
  [ -f "$skill/SKILL.md" ] || continue
  dest="$TARGET/$name"
  if [ ! -e "$dest" ]; then
    printf '  %-10s %s\n' installed "$name"; INSTALLED=$((INSTALLED + 1))
    [ "$DRY" = yes ] || cp -R "$skill" "$dest" || die "could not copy $name"
  elif diff -rq "$skill" "$dest" >/dev/null 2>&1; then
    printf '  %-10s %s\n' unchanged "$name"; SAME=$((SAME + 1))
  else
    printf '  %-10s %s (previous copy backed up)\n' updated "$name"; UPDATED=$((UPDATED + 1))
    backup "$dest"
    [ "$DRY" = yes ] || cp -R "$skill" "$dest" || die "could not copy $name"
  fi
done

# Skills renamed since v1 (they clashed with built-in commands): retire the old copies.
for old in plan:feature-plan brief:status-brief; do
  from=${old%%:*}; to=${old#*:}
  if [ -f "$TARGET/$from/SKILL.md" ] && grep -q 'claude-code-project-kit\|docs/briefs\|session/plans' "$TARGET/$from/SKILL.md"; then
    printf '  %-10s %s (renamed to %s; old copy backed up)\n' retired "$from" "$to"
    backup "$TARGET/$from"
  fi
done

echo "Done: $INSTALLED installed, $UPDATED updated, $SAME unchanged."
[ "$DRY" = yes ] || [ ! -d "$BACKUP" ] || echo "Backups: $BACKUP"
echo "Restart Claude Code to load the skills."

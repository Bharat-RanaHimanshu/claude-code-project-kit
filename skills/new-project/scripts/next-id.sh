#!/usr/bin/env bash
# next-id.sh: print the next free ID for a decision (D), task (T) or lesson (L),
# so IDs are never counted by hand and never reused.
# Compatible with bash 3.2+.
#
# Usage: next-id.sh D|T|L [PROJECT_DIR]
#        (default: $CLAUDE_PROJECT_DIR, else the current folder)

kind=${1:-}
root=${2:-${CLAUDE_PROJECT_DIR:-$PWD}}
case "$kind" in
  D) sources="$root/docs/decisions.md"; pattern='^## D-[0-9]+' ;;
  L) sources="$root/docs/learnings.md"; pattern='^## L-[0-9]+' ;;
  T) sources="$root/docs/tracker.md"; pattern='T-[0-9]+' ;;
  *) echo "Usage: next-id.sh D|T|L [PROJECT_DIR]" >&2; exit 2 ;;
esac
[ -f "$sources" ] || { echo "next-id: not found: $sources" >&2; exit 1; }

# Tasks: every T-number in the tracker (including "Last ID used") and in plans,
# so an ID that was deleted from the tracker is still never reused.
numbers=$(grep -hoE "$pattern" "$sources" 2>/dev/null)
if [ "$kind" = T ] && [ -d "$root/session/plans" ]; then
  more=$(find "$root/session/plans" -name '*.md' -exec grep -hoE 'T-[0-9]+' {} + 2>/dev/null)
  numbers="$numbers
$more"
fi

max=0
while IFS= read -r id; do
  n=${id##*-}
  [ -n "$n" ] || continue
  n=$((10#$n))
  [ "$n" -gt "$max" ] && max=$n
done <<EOF
$numbers
EOF
printf '%s-%03d\n' "$kind" $((max + 1))

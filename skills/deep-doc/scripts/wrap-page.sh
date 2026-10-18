#!/usr/bin/env bash
# wrap-page.sh: wrap an HTML body fragment in the shared page shell
# (assets/page-shell.html) to make one self-contained page.
# Used for rich pages written by Claude, and by md-to-html.sh for quick pages.
# Compatible with bash 3.2+.
#
# Usage: wrap-page.sh --title TITLE --body FRAGMENT.html --out PAGE.html
#                     [--meta TEXT] [--source DOC.md] [--project DIR]
#                     [--kind rich|quick] [--remove-body]
#
#   --source   the Markdown the page was made from, relative to the project;
#              recorded in the page so check-project.sh can spot outdated pages
#   --project  project folder (default: $CLAUDE_PROJECT_DIR, else the current folder)

# bash 5.2+ treats '&' in ${var//pattern/replacement} as "the match"; keep it literal.
shopt -u patsub_replacement 2>/dev/null || true

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SHELL_FILE="$SCRIPT_DIR/../assets/page-shell.html"

die() { printf 'wrap-page: %s\n' "$*" >&2; exit 1; }
need_value() { [ "$#" -ge 2 ] || die "$1 needs a value"; }

TITLE=; META=; BODY=; OUT=; SOURCE=; PROJECT=${CLAUDE_PROJECT_DIR:-$PWD}; KIND=rich; REMOVE=no
while [ "$#" -gt 0 ]; do
  case "$1" in
    --title)       need_value "$@"; TITLE=$2; shift ;;
    --meta)        need_value "$@"; META=$2; shift ;;
    --body)        need_value "$@"; BODY=$2; shift ;;
    --out)         need_value "$@"; OUT=$2; shift ;;
    --source)      need_value "$@"; SOURCE=$2; shift ;;
    --project)     need_value "$@"; PROJECT=$2; shift ;;
    --kind)        need_value "$@"; KIND=$2; shift ;;
    --remove-body) REMOVE=yes ;;
    -h|--help)     sed -n '2,15p' "$0"; exit 0 ;;
    *)             die "unknown option: $1" ;;
  esac
  shift
done

[ -n "$TITLE" ] || die "--title is required"
[ -n "$BODY" ]  || die "--body is required"
[ -n "$OUT" ]   || die "--out is required"
case "$KIND" in rich|quick) ;; *) die "--kind must be rich or quick" ;; esac
[ -f "$SHELL_FILE" ] || die "page shell not found: $SHELL_FILE"
[ -f "$BODY" ] || die "body fragment not found: $BODY"
if grep -qiE '<(html|head|body)[ >]' "$BODY"; then
  die "$BODY must be a body fragment, without <html>, <head> or <body>"
fi
markers=$(grep -c '<!-- CONTENT -->' "$SHELL_FILE")
[ "$markers" = 1 ] || die "the page shell must contain exactly one <!-- CONTENT --> line"

SOURCE_SUM=
if [ -n "$SOURCE" ]; then
  SOURCE=${SOURCE#./}
  [ -f "$PROJECT/$SOURCE" ] || die "source not found: $PROJECT/$SOURCE (give it relative to the project folder)"
  SOURCE_SUM=$(cksum < "$PROJECT/$SOURCE" | cut -d' ' -f1)
fi

escape() {
  s=$1
  s=${s//&/&amp;}
  s=${s//</&lt;}
  s=${s//>/&gt;}
  s=${s//\"/&quot;}
  printf '%s' "$s"
}
TITLE_HTML=$(escape "$TITLE")
META_HTML=$(escape "$META")
SOURCE_HTML=$(escape "$SOURCE")

mkdir -p "$(dirname "$OUT")" || die "could not create the folder for $OUT"
tmp="$OUT.tmp.$$"
{
  while IFS= read -r line || [ -n "$line" ]; do
    case "$line" in
      *'<!-- CONTENT -->'*)
        cat "$BODY"
        printf '\n'
        ;;
      *'{{'*)
        line=${line//'{{TITLE}}'/$TITLE_HTML}
        line=${line//'{{META}}'/$META_HTML}
        line=${line//'{{SOURCE}}'/$SOURCE_HTML}
        line=${line//'{{SOURCE_SUM}}'/$SOURCE_SUM}
        line=${line//'{{KIND}}'/$KIND}
        printf '%s\n' "$line"
        ;;
      *)
        printf '%s\n' "$line"
        ;;
    esac
  done < "$SHELL_FILE"
} > "$tmp" || { rm -f "$tmp"; die "could not write $OUT"; }
mv -f "$tmp" "$OUT" || { rm -f "$tmp"; die "could not write $OUT"; }

[ "$REMOVE" = yes ] && rm -f "$BODY"
echo "wrote $OUT"

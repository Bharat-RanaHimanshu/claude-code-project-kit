#!/usr/bin/env bash
# new-project.sh: create a project from the standard template, complete an
# existing one, or show how a project differs from the current template.
# Never overwrites an existing file.
# Runs in Git Bash on Windows, macOS and Linux; compatible with bash 3.2+.

# bash 5.2+ treats '&' in ${var//pattern/replacement} as "the match"; keep it literal.
shopt -u patsub_replacement 2>/dev/null || true

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SKILL_DIR=$(dirname "$SCRIPT_DIR")
TEMPLATE_DIR="$SKILL_DIR/template"
KIT_VERSION=$(tr -d ' \r\n' < "$SKILL_DIR/VERSION" 2>/dev/null)
[ -n "$KIT_VERSION" ] || KIT_VERSION=unknown

usage() {
  cat <<'EOF'
Usage:
  new-project.sh --dir PATH --name NAME --description TEXT \
                 --backend STACK --frontend STACK \
                 (--learning | --production) (--solo | --team) (--single | --separate) \
                 [--git] [--dry-run | --diff]
  new-project.sh --scan --dir PATH

  --dir PATH            project folder (created if missing)
  --name NAME           project name
  --description TEXT    one-line description
  --backend STACK       backend stack, e.g. "Python 3.12 + FastAPI" ("none" or "TBD" are fine)
  --frontend STACK      frontend stack, e.g. "React 19 + Vite"
  --learning            the project is for learning: Claude explains, checks understanding
  --production          the project ships: rigour first, short explanations
  --solo | --team       team mode git-ignores session/HANDOFF.md
  --single              backend and frontend live in the project's own repository
  --separate            code/backend and code/frontend are clones of their own
                        repositories: left empty until cloned, filled on a later run
  --git                 git init and first commit (only if the folder is not a repository yet)
  --dry-run             show what would be added; change nothing
  --diff                compare an existing project with the current template; change nothing
  --scan                list what is in an existing folder and suggest standard names;
                        change nothing
EOF
}

die() { printf 'new-project: %s\n' "$*" >&2; exit 1; }
warn() { WARNINGS=$((WARNINGS + 1)); printf '  warning   %s\n' "$*"; }
need_value() { [ "$#" -ge 2 ] || die "$1 needs a value (see --help)"; }

DIR=; NAME=; DESC=; BACKEND=; FRONTEND=; PURPOSE=; TEAM=; REPOS=
GIT=no; DRY=no; SCAN=no; DIFF=no
while [ "$#" -gt 0 ]; do
  case "$1" in
    --dir)         need_value "$@"; DIR=$2; shift ;;
    --name)        need_value "$@"; NAME=$2; shift ;;
    --description) need_value "$@"; DESC=$2; shift ;;
    --backend)     need_value "$@"; BACKEND=$2; shift ;;
    --frontend)    need_value "$@"; FRONTEND=$2; shift ;;
    --learning)    PURPOSE=learning ;;
    --production)  PURPOSE=production ;;
    --solo)        TEAM=solo ;;
    --team)        TEAM=team ;;
    --single)      REPOS=single ;;
    --separate)    REPOS=separate ;;
    --git)         GIT=yes ;;
    --dry-run)     DRY=yes ;;
    --diff)        DIFF=yes ;;
    --scan)        SCAN=yes ;;
    -h|--help)     usage; exit 0 ;;
    *)             die "unknown option: $1 (see --help)" ;;
  esac
  shift
done

[ -n "$DIR" ] || die "--dir is required (see --help)"
[ "$DIR" = "/" ] || DIR=${DIR%/}

# ---------------------------------------------------------------- scan mode
suggest() {  # print a suggested standard place for a top-level entry
  lower=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  case "$lower" in
    claude.md)                    echo "CLAUDE.md" ;;
    readme.md|readme|readme.txt)  echo "README.md" ;;
    inputs|input|requirements|requirement|specs|spec|specifications|reference|references|handover)
                                  echo "inputs/" ;;
    research|investigation|investigations|spikes|analysis)
                                  echo "research/" ;;
    code|source|sources)          echo "code/" ;;
    backend|back-end|server|api|service|services)
                                  echo "code/backend/" ;;
    frontend|front-end|web|webapp|web-app|ui)
                                  echo "code/frontend/" ;;
    client|app)                   echo "code/frontend/ (or inputs/ if it holds client documents)" ;;
    src)                          echo "code/backend/ or code/frontend/ (which one?)" ;;
    docs|doc|documentation|documents|wiki)
                                  echo "docs/" ;;
    handoff.md|handoff)           echo "session/HANDOFF.md" ;;
    plans|plan)                   echo "session/plans/" ;;
    session|sessions)             echo "session/" ;;
    todo.md|todo|tasks.md)        echo "docs/tracker.md (merge)" ;;
    decisions.md|adr|adrs|decisions)
                                  echo "docs/decisions.md (merge)" ;;
    notes.md|lessons.md|learnings.md)
                                  echo "docs/learnings.md (merge)" ;;
    *)                            echo "" ;;
  esac
}

if [ "$SCAN" = yes ]; then
  [ -d "$DIR" ] || { echo "Folder does not exist yet: $DIR (nothing to scan)"; exit 0; }
  echo "Scan of $DIR (nothing is changed)"
  count=0
  for entry in "$DIR"/* "$DIR"/.[!.]* "$DIR"/..?*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    name=${entry##*/}
    count=$((count + 1))
    case "$name" in
      CLAUDE.md|README.md|.gitignore|.gitattributes|.git|.claude|.vscode|inputs|research|code|docs|session)
        printf '  standard  %s\n' "$name"; continue ;;
      .env|.env.*)
        printf '  env file  %s  (stays where it is; must be git-ignored, never committed)\n' "$name"; continue ;;
    esac
    target=$(suggest "$name")
    if [ -z "$target" ]; then
      printf '  other     %s  (not part of the standard: leave it, or say where it goes)\n' "$name"
      continue
    fi
    plain=${target%% *}
    if [ -e "$DIR/${plain%/}" ]; then
      printf '  merge     %s  ->  %s  (target already exists: merge by hand)\n' "$name" "$target"
    else
      printf '  rename    %s  ->  %s\n' "$name" "$target"
    fi
  done
  [ "$count" -gt 0 ] || echo "  (empty folder)"
  exit 0
fi

# ---------------------------------------------------------- validate options
[ -d "$TEMPLATE_DIR" ] || die "template folder not found: $TEMPLATE_DIR"
missing=
[ -n "$NAME" ]     || missing="$missing --name"
[ -n "$DESC" ]     || missing="$missing --description"
[ -n "$BACKEND" ]  || missing="$missing --backend"
[ -n "$FRONTEND" ] || missing="$missing --frontend"
[ -n "$PURPOSE" ]  || missing="$missing --learning|--production"
[ -n "$TEAM" ]     || missing="$missing --solo|--team"
[ -n "$REPOS" ]    || missing="$missing --single|--separate"
[ -z "$missing" ]  || die "missing:$missing (see --help)"
[ "$DRY$DIFF" != yesyes ] || die "use --dry-run or --diff, not both"
nl='
'
case "$NAME$DESC$BACKEND$FRONTEND" in
  *"$nl"*) die "values must be on a single line" ;;
esac
[ -e "$DIR" ] && [ ! -d "$DIR" ] && die "$DIR exists and is not a folder"

DATE=$(date +%Y-%m-%d)
if [ "$DIFF" = yes ] && [ -f "$DIR/CLAUDE.md" ]; then
  # Compare against the template as it was filled on the project's creation date.
  created=$(sed -n 's/^- \*\*Created:\*\* \([0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]\).*/\1/p' "$DIR/CLAUDE.md" | head -n 1)
  [ -z "$created" ] || DATE=$created
fi
ADDED=0; KEPT=0; WARNINGS=0; SAME=0; DIFFERS=0; MISSING=0

# Render one template file to stdout: mode lines and placeholders.
#   {{learning}} {{production}} {{solo}} {{team}} {{single}} {{separate}} at the
#   start of a line keep that line only in that mode (the prefix is removed).
CR=$(printf '\r')
render() {
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%"$CR"}  # LF output even if the template picked up CRLF
    case "$line" in
      '{{learning}}'*)   [ "$PURPOSE" = learning ]   || continue; line=${line#'{{learning}}'} ;;
      '{{production}}'*) [ "$PURPOSE" = production ] || continue; line=${line#'{{production}}'} ;;
      '{{solo}}'*)       [ "$TEAM" = solo ]          || continue; line=${line#'{{solo}}'} ;;
      '{{team}}'*)       [ "$TEAM" = team ]          || continue; line=${line#'{{team}}'} ;;
      '{{single}}'*)     [ "$REPOS" = single ]       || continue; line=${line#'{{single}}'} ;;
      '{{separate}}'*)   [ "$REPOS" = separate ]     || continue; line=${line#'{{separate}}'} ;;
    esac
    case "$line" in
      *'{{'*)
        line=${line//'{{PROJECT_NAME}}'/$NAME}
        line=${line//'{{DESCRIPTION}}'/$DESC}
        line=${line//'{{DATE}}'/$DATE}
        line=${line//'{{BACKEND_STACK}}'/$BACKEND}
        line=${line//'{{FRONTEND_STACK}}'/$FRONTEND}
        line=${line//'{{KIT_VERSION}}'/$KIT_VERSION}
        ;;
    esac
    printf '%s\n' "$line"
  done < "$1"
}

code_repo_ready() {  # separate mode: is code/$1 a git clone yet?
  [ -e "$DIR/code/$1/.git" ]
}

TMP_RENDER="${TMPDIR:-/tmp}/new-project.$$"
trap 'rm -f "$TMP_RENDER"' EXIT

handle_file() {  # $1 = path inside the template
  src=$1
  rel=${src%.tmpl}  # CLAUDE.md files are stored as CLAUDE.md.tmpl so they never load as instructions
  case "$rel" in
    code/backend/*|code/frontend/*)
      if [ "$REPOS" = separate ]; then
        part=${rel#code/}; part=${part%%/*}
        code_repo_ready "$part" || return 0
      fi ;;
  esac
  dest="$DIR/$rel"

  if [ "$DIFF" = yes ]; then
    if [ ! -e "$dest" ]; then
      MISSING=$((MISSING + 1)); printf '  %-9s %s\n' missing "$rel"; return 0
    fi
    render "$TEMPLATE_DIR/$src" > "$TMP_RENDER"
    if cmp -s "$TMP_RENDER" "$dest"; then
      SAME=$((SAME + 1)); printf '  %-9s %s\n' same "$rel"
    else
      DIFFERS=$((DIFFERS + 1)); printf '  %-9s %s\n' differs "$rel"
      diff -u "$dest" "$TMP_RENDER" | sed -e '1,2d' -e 's/^/            /' | head -n 40
    fi
    return 0
  fi

  if [ -e "$dest" ] || [ -L "$dest" ]; then
    KEPT=$((KEPT + 1)); printf '  %-9s %s\n' "$VERB_KEEP" "$rel"; return 0
  fi
  ADDED=$((ADDED + 1))
  if [ "$DRY" = yes ]; then
    printf '  %-9s %s\n' "$VERB_ADD" "$rel"; return 0
  fi
  mkdir -p "$(dirname "$dest")" || die "could not create the folder for $rel"
  render "$TEMPLATE_DIR/$src" > "$dest" || die "could not write $rel"
  printf '  %-9s %s\n' "$VERB_ADD" "$rel"
}

if [ "$REPOS" = single ]; then repo_text="one repository"; else repo_text="separate code repositories"; fi
if [ "$DIFF" = yes ]; then
  [ -d "$DIR" ] || die "$DIR does not exist: nothing to compare"
  echo "DIFF against template v$KIT_VERSION: nothing will be changed."
  echo "Lines starting with - are in the project, + in the template."
elif [ "$DRY" = yes ]; then
  VERB_ADD="add"; VERB_KEEP="keep"
  echo "DRY RUN: nothing will be changed."
else
  VERB_ADD="added"; VERB_KEEP="kept"
fi
echo "Project: $DIR ($PURPOSE, $TEAM, $repo_text; kit v$KIT_VERSION)"
if [ ! -d "$DIR" ]; then
  if [ "$DRY" = yes ]; then
    echo "  (folder does not exist yet; it would be created)"
  else
    mkdir -p "$DIR" || die "could not create $DIR"
  fi
fi

files=$(cd "$TEMPLATE_DIR" && find . -type f | LC_ALL=C sort)
while IFS= read -r f; do
  [ -n "$f" ] || continue
  handle_file "${f#./}"
done <<EOF
$files
EOF

if [ "$DIFF" = yes ]; then
  echo "Diff: $SAME same, $DIFFERS differ, $MISSING missing (run without --diff to add missing files)."
  exit 0
fi

# Separate mode: the code folders stay empty until they are cloned.
if [ "$REPOS" = separate ]; then
  for part in backend frontend; do
    d="$DIR/code/$part"
    if code_repo_ready "$part"; then
      :  # its files were handled above
    elif [ -d "$d" ] && [ -n "$(ls -A "$d" 2>/dev/null)" ]; then
      warn "code/$part/ has files but is not a git clone; left untouched"
    elif [ -d "$d" ]; then
      printf '  %-9s %s\n' "waiting" "code/$part/ (empty: git clone the $part repository here, then run again)"
    elif [ "$DRY" = yes ]; then
      printf '  %-9s %s\n' "$VERB_ADD" "code/$part/ (empty, for git clone)"
    else
      mkdir -p "$d" || die "could not create code/$part/"
      printf '  %-9s %s\n' "$VERB_ADD" "code/$part/ (empty: git clone the $part repository here, then run again)"
    fi
  done
fi

# A .gitignore that was kept may lack what this mode needs.
gi="$DIR/.gitignore"
if [ -f "$gi" ]; then
  for pattern in .env node_modules/; do
    grep -qxF "$pattern" "$gi" || warn ".gitignore has no '$pattern' line"
  done
  if [ "$TEAM" = team ]; then
    grep -qxF "session/HANDOFF.md" "$gi" || warn ".gitignore has no 'session/HANDOFF.md' line (team mode)"
  fi
  if [ "$REPOS" = separate ]; then
    for pattern in code/backend/ code/frontend/; do
      grep -qxF "$pattern" "$gi" || warn ".gitignore has no '$pattern' line (separate mode)"
    done
  fi
fi

# ------------------------------------------------------------------- git
if [ "$GIT" = yes ]; then
  if [ -e "$DIR/.git" ]; then
    echo "  git       already a repository: no init, no commit"
  elif [ "$DRY" = yes ]; then
    echo "  git       would run git init and make the first commit"
  else
    command -v git >/dev/null 2>&1 || die "git not found"
    git -C "$DIR" init -q || die "git init failed"
    git -C "$DIR" add -A || die "git add failed"
    secrets=$(git -C "$DIR" diff --cached --name-only |
      grep -E '(^|/)\.env(\.(local|development|production|staging|test))?$')
    if [ -n "$secrets" ]; then
      git -C "$DIR" reset -q
      die "refusing to commit real env files: $secrets (add them to .gitignore, then commit by hand)"
    fi
    git -C "$DIR" commit -q -m "Set up project with claude-code-project-kit v$KIT_VERSION" ||
      die "git commit failed (are user.name and user.email set?). The repository exists; commit by hand."
    echo "  git       initialised; first commit $(git -C "$DIR" rev-parse --short HEAD)"
  fi
fi

if [ "$DRY" = yes ]; then
  echo "Dry run: $ADDED to add, $KEPT to keep, $WARNINGS warning(s)."
else
  echo "Done: $ADDED added, $KEPT kept, $WARNINGS warning(s)."
fi

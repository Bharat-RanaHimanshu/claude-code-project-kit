#!/usr/bin/env bash
# run-tests.sh: tests for the kit's scripts. Runs on Linux, macOS (bash 3.2)
# and Git Bash on Windows. Set TEST_BASH to choose the bash that runs the scripts.
#
# Usage: bash tests/run-tests.sh

# Check conditions are single-quoted on purpose (check() evals them later, so
# variables used only there look unused), and $COMMON is split into options on purpose.
# shellcheck disable=SC2016,SC2034,SC2086

B=${TEST_BASH:-bash}
KIT=$(cd "$(dirname "$0")/.." && pwd)
S="$KIT/skills"
NP="$S/new-project/scripts/new-project.sh"
CHECK="$S/new-project/scripts/check-project.sh"
NEXT="$S/new-project/scripts/next-id.sh"
MD2HTML="$S/deep-doc/scripts/md-to-html.sh"
WRAP="$S/deep-doc/scripts/wrap-page.sh"
STATE="$S/handoff/scripts/repo-state.sh"

T=$(mktemp -d)
trap 'rm -rf "$T"' EXIT
export GIT_CONFIG_GLOBAL="$T/gitconfig" GIT_CONFIG_NOSYSTEM=1
git config --global user.name "Kit Test"
git config --global user.email "kit-test@example.com"
git config --global init.defaultBranch main
git config --global core.autocrlf false
unset CLAUDE_PROJECT_DIR

PASS=0; FAIL=0
check() {  # $1 = description, $2 = shell condition
  if eval "$2"; then printf '  PASS  %s\n' "$1"; PASS=$((PASS + 1))
  else printf '  FAIL  %s\n' "$1"; FAIL=$((FAIL + 1)); fi
}
snapshot() {  # checksum of every file outside .git folders
  (cd "$1" && find . -type f ! -path '*/.git/*' | LC_ALL=C sort | while IFS= read -r f; do
    printf '%s %s\n' "$(cksum < "$f")" "$f"; done)
}
touched_since() {  # files changed after the marker file
  find "$1" -type f -newer "$2" ! -path '*/.git/*'
}
json_ok() {
  if command -v python3 >/dev/null 2>&1; then python3 -m json.tool "$1" >/dev/null
  elif command -v node >/dev/null 2>&1; then node -e "JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'))" "$1"
  else return 0; fi
}
section() { printf '\n== %s\n' "$1"; }

NAME='Acme & Co "Shop" / v2'
DESC='Online shop for A&B: $prices, \paths, 100% uptime & {braces}'
COMMON="--backend Node22 --frontend React19"

echo "Testing with: $("$B" --version | head -n 1)"

# --------------------------------------------------------------------------
section "Mode A: learning + solo + single repository + git"
A="$T/shop-a"
"$B" "$NP" --dry-run --dir "$A" --name "$NAME" --description "$DESC" $COMMON --learning --solo --single --git > "$T/a0.txt"
check "dry run on a new folder creates nothing" '[ ! -e "$A" ]'
check "dry run lists files to add" 'grep -q "to add" "$T/a0.txt"'
"$B" "$NP" --dir "$A" --name "$NAME" --description "$DESC" $COMMON --learning --solo --single --git > "$T/a1.txt"
check "first run succeeds" 'grep -q "^Done: [0-9]* added, 0 kept, 0 warning" "$T/a1.txt"'
snapshot "$A" > "$T/a1.snap"; head_a=$(git -C "$A" rev-parse HEAD)
touch "$T/marker-a"; sleep 1
"$B" "$NP" --dir "$A" --name "$NAME" --description "$DESC" $COMMON --learning --solo --single --git > "$T/a2.txt"
snapshot "$A" > "$T/a2.snap"
check "second run adds nothing" 'grep -q "^Done: 0 added" "$T/a2.txt"'
check "second run leaves every file byte-identical" 'cmp -s "$T/a1.snap" "$T/a2.snap"'
check "second run rewrites no file" '[ -z "$(touched_since "$A" "$T/marker-a")" ]'
check "second run makes no commit" '[ "$(git -C "$A" rev-parse HEAD)" = "$head_a" ]'
check "no placeholders left" '! grep -rq "{{" "$A" --exclude-dir=.git'
check "name and description kept literally (& \" / \\ \$ {})" 'grep -qxF "# $NAME" "$A/CLAUDE.md" && grep -qxF "$DESC" "$A/CLAUDE.md"'
check "CLAUDE.md.tmpl became CLAUDE.md" '[ -f "$A/CLAUDE.md" ] && [ -f "$A/code/backend/CLAUDE.md" ] && [ -z "$(find "$A" -name "*.tmpl")" ]'
check "kit version stamped in CLAUDE.md" 'grep -q "claude-code-project-kit v[0-9]" "$A/CLAUDE.md"'
check "learning lines only" 'grep -q "Working style: learning" "$A/CLAUDE.md" && ! grep -q "Working style: production" "$A/CLAUDE.md"'
check "solo + single lines only" 'grep -q "Team:\*\* solo" "$A/CLAUDE.md" && grep -q "one repository" "$A/CLAUDE.md" && ! grep -qE "Team:\*\* team|separate repositories" "$A/CLAUDE.md"'
check ".gitignore has no team or separate lines" '! grep -qE "HANDOFF|^code/" "$A/.gitignore"'
check "HANDOFF.md is committed (solo)" 'git -C "$A" ls-files --error-unmatch session/HANDOFF.md >/dev/null 2>&1'
check "every folder has a README.md" '[ -z "$(cd "$A" && find . -type d ! -path "./.git*" ! -path "./.claude*" ! -path "./.vscode*" | while IFS= read -r d; do [ -f "$d/README.md" ] || echo "$d"; done)" ]'
check "generated files are LF-only" '! grep -rlq "$(printf "\r")" "$A" --exclude-dir=.git'
check "settings.json and extensions.json are valid JSON" 'json_ok "$A/.claude/settings.json" && json_ok "$A/.vscode/extensions.json"'
check "testing strategy in place (docs/testing.md, CLAUDE.md, plan format)" '[ -f "$A/docs/testing.md" ] && grep -q "^## Testing" "$A/CLAUDE.md" && grep -q "full\*\* test suite passes" "$A/CLAUDE.md" && grep -q "^## Tests" "$A/session/plans/README.md" && grep -q "Integration tests" "$A/code/backend/CLAUDE.md" && grep -q "End-to-end tests" "$A/code/frontend/CLAUDE.md"'
check "root CLAUDE.md under 200 lines" '[ "$(wc -l < "$A/CLAUDE.md")" -lt 200 ]'
check "check-project passes on a fresh project" '"$B" "$CHECK" "$A" >/dev/null'
check "next-id: D-002, T-005, L-001" '[ "$("$B" "$NEXT" D "$A")" = D-002 ] && [ "$("$B" "$NEXT" T "$A")" = T-005 ] && [ "$("$B" "$NEXT" L "$A")" = L-001 ]'

# --------------------------------------------------------------------------
section "Mode B: production + team + separate repositories + git"
P="$T/shop-b"
"$B" "$NP" --dir "$P" --name "Shop B" --description "Team project" $COMMON --production --team --separate --git > "$T/b1.txt"
head_b=$(git -C "$P" rev-parse HEAD)
check "code/backend and code/frontend exist and are empty" '[ -d "$P/code/backend" ] && [ -z "$(ls -A "$P/code/backend")" ] && [ -d "$P/code/frontend" ] && [ -z "$(ls -A "$P/code/frontend")" ]'
check ".gitignore has the team and separate lines" 'grep -qxF session/HANDOFF.md "$P/.gitignore" && grep -qxF code/backend/ "$P/.gitignore" && grep -qxF code/frontend/ "$P/.gitignore"'
check "HANDOFF.md exists but is not committed (team)" '[ -f "$P/session/HANDOFF.md" ] && ! git -C "$P" ls-files --error-unmatch session/HANDOFF.md >/dev/null 2>&1'
check "production + team + separate lines only" 'grep -q "Working style: production" "$P/CLAUDE.md" && grep -q "Team:\*\* team" "$P/CLAUDE.md" && grep -q "separate repositories" "$P/CLAUDE.md" && ! grep -qE "Working style: learning|one repository" "$P/CLAUDE.md"'
snapshot "$P" > "$T/b1.snap"; touch "$T/marker-b"; sleep 1
"$B" "$NP" --dir "$P" --name "Shop B" --description "Team project" $COMMON --production --team --separate --git > "$T/b2.txt"
snapshot "$P" > "$T/b2.snap"
check "second run changes nothing" 'cmp -s "$T/b1.snap" "$T/b2.snap" && [ -z "$(touched_since "$P" "$T/marker-b")" ] && [ "$(git -C "$P" rev-parse HEAD)" = "$head_b" ]'
check "second run reports the code folders as waiting" '[ "$(grep -c "^  waiting" "$T/b2.txt")" = 2 ]'
R="$T/backend-origin"; git init -q "$R"; printf '# Backend repo\n' > "$R/README.md"; git -C "$R" add -A; git -C "$R" commit -qm init
git clone -q "$R" "$P/code/backend"
"$B" "$NP" --dir "$P" --name "Shop B" --description "Team project" $COMMON --production --team --separate --git > "$T/b3.txt"
check "after cloning: CLAUDE.md added, the clone's README kept" '[ -f "$P/code/backend/CLAUDE.md" ] && [ "$(cat "$P/code/backend/README.md")" = "# Backend repo" ]'
check "backend CLAUDE.md says it is its own repository" 'grep -q "its own git repository" "$P/code/backend/CLAUDE.md"'
check "frontend still empty" '[ -z "$(ls -A "$P/code/frontend")" ]'
snapshot "$P" > "$T/b3.snap"; touch "$T/marker-b3"; sleep 1
"$B" "$NP" --dir "$P" --name "Shop B" --description "Team project" $COMMON --production --team --separate --git > /dev/null
check "run after cloning changes nothing" 'cmp -s "$T/b3.snap" "$(snapshot "$P" > "$T/b4.snap"; echo "$T/b4.snap")" && [ -z "$(touched_since "$P" "$T/marker-b3")" ]'
check "repo-state reports root and backend" '"$B" "$STATE" "$P" > "$T/state.txt" && grep -q "^== root" "$T/state.txt" && grep -q "^== backend" "$T/state.txt" && ! grep -q "^== frontend" "$T/state.txt"'

# --------------------------------------------------------------------------
section "Existing folder: scan, and a real .env"
C="$T/legacy"; mkdir -p "$C/Docs" "$C/server" "$C/src" "$C/docs"
: > "$C/README.md"; : > "$C/notes.txt"; : > "$C/HANDOFF.md"
printf 'node_modules/\n' > "$C/.gitignore"; printf 'SECRET=1\n' > "$C/.env"
"$B" "$NP" --scan --dir "$C" > "$T/scan.txt"
check "scan suggests server -> code/backend/" 'grep -q "rename    server  ->  code/backend/" "$T/scan.txt"'
check "scan flags Docs as a merge into docs/" 'grep -q "merge     Docs  ->  docs/" "$T/scan.txt"'
check "scan recognises the env file" 'grep -q "env file  .env" "$T/scan.txt"'
"$B" "$NP" --dir "$C" --name Legacy --description Old $COMMON --production --solo --single --git > "$T/c.txt" 2>&1
check "warns that the kept .gitignore lacks .env" 'grep -q "no .\.env. line" "$T/c.txt"'
check "refuses to commit the real .env" 'grep -q "refusing to commit real env files" "$T/c.txt" && ! git -C "$C" rev-parse -q --verify HEAD >/dev/null 2>&1'
check "existing files untouched" '[ ! -s "$C/README.md" ] && [ "$(cat "$C/.gitignore")" = "node_modules/" ]'

# --------------------------------------------------------------------------
section "Diff against the template"
"$B" "$NP" --diff --dir "$A" --name "$NAME" --description "$DESC" $COMMON --learning --solo --single > "$T/d1.txt"
check "a fresh project matches the template" 'grep -q "^Diff: [0-9]* same, 0 differ, 0 missing" "$T/d1.txt"'
printf 'extra line\n' >> "$A/docs/runbook.md"; rm "$A/docs/story.md"
snapshot "$A" > "$T/d.snap"
"$B" "$NP" --diff --dir "$A" --name "$NAME" --description "$DESC" $COMMON --learning --solo --single > "$T/d2.txt"
check "diff reports the changed and the missing file" 'grep -q "differs   docs/runbook.md" "$T/d2.txt" && grep -q "missing   docs/story.md" "$T/d2.txt"'
check "diff changes nothing" 'cmp -s "$T/d.snap" "$(snapshot "$A" > "$T/d2.snap"; echo "$T/d2.snap")"'
"$B" "$NP" --dir "$A" --name "$NAME" --description "$DESC" $COMMON --learning --solo --single > "$T/d3.txt"
check "a normal run restores the missing file" 'grep -q "added     docs/story.md" "$T/d3.txt" && [ -f "$A/docs/story.md" ]'

# --------------------------------------------------------------------------
section "check-project finds problems"
E="$T/checks"
"$B" "$NP" --dir "$E" --name Checks --description "Check test" $COMMON --learning --solo --single > /dev/null
mkdir -p "$E/docs/features" "$E/session/plans/done"
printf '# Login\n\nSee [the API](../api.md) and [nowhere](../missing.md).\n\n```\n[not a link](inside-a-code-block.md)\n```\n' > "$E/docs/features/login.md"
printf '\n## D-001: Duplicate\n' >> "$E/docs/decisions.md"
printf '# Plan: x\n\n**Status:** done\n' > "$E/session/plans/x.md"
printf '# Plan: y\n\n## Outcome\n\nWritten when the plan is finished: placeholder\n' > "$E/session/plans/done/y.md"
"$B" "$CHECK" "$E" > "$T/e.txt"; code=$?
check "exit code 1 when problems are found" '[ "$code" = 1 ]'
check "finds a doc missing from docs/README.md" 'grep -q "docs/README.md has no row for docs/features/login.md" "$T/e.txt"'
check "finds a broken link (and ignores code blocks)" 'grep -q "broken link in docs/features/login.md: ../missing.md" "$T/e.txt" && ! grep -q "inside-a-code-block" "$T/e.txt"'
check "finds a repeated decision number" 'grep -q "D-001 found where D-002 was expected" "$T/e.txt"'
check "finds a finished plan that wasn't moved" 'grep -q "session/plans/x.md is done but not moved" "$T/e.txt"'
check "finds a done plan without an Outcome" 'grep -q "session/plans/done/y.md has no Outcome" "$T/e.txt"'

# --------------------------------------------------------------------------
section "HTML pages"
printf '# Login\n\nIntro.\n\n## How it works\n\n```mermaid\nflowchart LR\n  A -->|calls| B\n```\n' > "$A/docs/features/login.md"
printf '| [features/login.md](features/login.md) | Login | draft | today |\n' >> "$A/docs/README.md"
"$B" "$MD2HTML" --project "$A" docs/features/login.md > "$T/h1.txt"
page="$A/docs/visual/features-login.html"
check "md-to-html makes features-login.html" '[ -f "$page" ]'
check "the page records its source, checksum and kind" 'grep -q "<meta name=\"kit-source\" content=\"docs/features/login.md\" data-sum=\"[0-9][0-9]*\" data-kind=\"quick\">" "$page"'
check "the first heading becomes the title" 'grep -q "<title>Login</title>" "$page"'
check "no fragment file left behind" '[ -z "$(find "$A/docs/visual" -name ".*.body.html")" ]'
"$B" "$MD2HTML" --project "$A" --all > "$T/h2.txt"
check "--all makes index.html and skips folder READMEs" '[ -f "$A/docs/visual/index.html" ] && [ ! -f "$A/docs/visual/features-README.html" ]'
printf '<p>Rich body</p>\n' > "$T/rich.body.html"
"$B" "$WRAP" --project "$A" --title 'Rich <A & B>' --source docs/features/login.md --body "$T/rich.body.html" --out "$page" > /dev/null
check "wrap-page escapes the title" 'grep -q "<title>Rich &lt;A &amp; B&gt;</title>" "$page"'
"$B" "$MD2HTML" --project "$A" --all > "$T/h3.txt"
check "--all keeps a rich page" 'grep -q "kept      docs/visual/features-login.html" "$T/h3.txt" && grep -q "data-kind=\"rich\"" "$page"'
"$B" "$MD2HTML" --project "$A" --force docs/features/login.md > /dev/null
check "--force replaces it with a quick page" 'grep -q "data-kind=\"quick\"" "$page"'
check "check-project passes with fresh pages" '"$B" "$CHECK" "$A" > "$T/h4.txt" || { cat "$T/h4.txt"; false; }'
printf '\nMore.\n' >> "$A/docs/features/login.md"
check "check-project reports an outdated page" '! "$B" "$CHECK" "$A" > "$T/h5.txt" && grep -q "features-login.html is out of date" "$T/h5.txt"'
printf '<html><body>x</body></html>\n' > "$T/bad.body.html"
check "wrap-page rejects a full HTML document as a body" '! "$B" "$WRAP" --title t --body "$T/bad.body.html" --out "$T/bad.html" 2>/dev/null'

# --------------------------------------------------------------------------
section "install.sh"
I="$T/home/.claude/skills"
"$B" "$KIT/install.sh" --target "$I" > "$T/i1.txt"
count=$(find "$S" -mindepth 1 -maxdepth 1 -type d | wc -l); count=$((count + 0))
check "installs every skill" '[ "$(find "$I" -name SKILL.md | wc -l | tr -d " ")" = "$count" ]'
"$B" "$KIT/install.sh" --target "$I" > "$T/i2.txt"
check "second install changes nothing" 'grep -q "0 installed, 0 updated, $count unchanged" "$T/i2.txt"'
printf 'local edit\n' >> "$I/pickup/SKILL.md"
mkdir -p "$I/brief"; printf -- '---\nname: brief\n---\nWrites into docs/briefs\n' > "$I/brief/SKILL.md"
"$B" "$KIT/install.sh" --target "$I" > "$T/i3.txt"
check "a changed skill is updated and the old copy backed up" 'grep -q "updated    pickup" "$T/i3.txt" && ! grep -q "local edit" "$I/pickup/SKILL.md" && grep -rq "local edit" "$T/home/.claude/kit-backups"'
check "the v1 brief skill is retired" '[ ! -e "$I/brief" ] && grep -q "retired    brief" "$T/i3.txt"'
R="$T/repo"; mkdir -p "$R"; git -C "$R" init -q
"$B" "$KIT/install.sh" --target "$R/.claude/skills" > /dev/null
git -C "$R" add -A; git -C "$R" commit -qm skills
printf 'local edit\n' >> "$R/.claude/skills/pickup/SKILL.md"
"$B" "$KIT/install.sh" --target "$R/.claude/skills" > "$T/i4.txt"
check "backups inside a repository are git-ignored" 'grep -q "updated    pickup" "$T/i4.txt" && [ -d "$R/.claude/kit-backups" ] && [ -z "$(git -C "$R" status --porcelain)" ]'

printf '\nRESULT: %s passed, %s failed\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]

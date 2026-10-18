# claude-code-project-kit

This repository is the kit itself: Claude Code skills, a project template and helper scripts. The README explains what each skill does.

## Rules for changing the kit

- **Bash only, compatible with bash 3.2** (macOS) and Git Bash on Windows: no associative arrays, `mapfile`, `${var,,}`, `|&`, `;;&` or `printf '%(…)T'`. Avoid GNU-only flags (`sed -i`, `stat -c`, `sha256sum`); use `cksum`, temp files and `find -newer`.
- Scripts start with `shopt -u patsub_replacement 2>/dev/null || true` when they use `${var//pattern/replacement}` with user text.
- **LF line endings** everywhere (`.gitattributes` enforces it).
- Skills refer to their scripts as `<skill-dir>/scripts/…` or `<kit>/<other-skill>/scripts/…`, never `~/.claude/skills/…`.
- Template files never write into an existing project file. CLAUDE.md files in the template are named `CLAUDE.md.tmpl`.
- Inline scripts in `page-shell.html` must never contain the text `</script>`, not even in a comment.
- Library versions in the page shell are exact and carry SRI hashes; update both together.

## Commits

- Commits are authored by the repository owner. Commit messages and pull requests contain no co-author, session or tool attribution lines.

## Before committing

1. `bash tests/run-tests.sh` passes (and `shellcheck -s bash skills/*/scripts/*.sh install.sh tests/*.sh` is clean).
2. If the page shell or HTML scripts changed: `bash tests/build-fixtures.sh /tmp/fx` then `node tests/render-test.mjs /tmp/fx/project/docs/visual` (needs `npm install --no-save playwright`).
3. The README's skill table, the template's `README.md` and `CLAUDE.md.tmpl` agree with the skills.
4. `skills/new-project/VERSION` is bumped and `CHANGELOG.md` has an entry for user-visible changes.

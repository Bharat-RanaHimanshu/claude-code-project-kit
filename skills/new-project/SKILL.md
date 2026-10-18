---
name: new-project
description: Set up a new project, or bring an existing folder up to standard, with claude-code-project-kit's structure (CLAUDE.md, inputs, research, code/backend, code/frontend, docs, session) by running the bundled script on its template, so every project comes out identical. Also adds the code folders' files after cloning, and shows how an older project differs from the current template. Use when the user wants to create, start, scaffold or standardise a project, or runs /new-project.
argument-hint: "[project name]"
---

# new-project

Creates or completes a project from `template/` with `scripts/new-project.sh`. The script writes the project files, so every project is identical. **Never write the template's files into a project by hand.** Claude gathers the answers, runs the script and reports.

**Paths:** `<skill-dir>` is this skill's base directory (shown when the skill loads). In Git Bash on Windows, write it with forward slashes (`C:/Users/…`).

Name given with the command (may be empty): `$ARGUMENTS`

## 1. Gather everything in one go

| Value | Script option | Notes |
|---|---|---|
| Folder | `--dir` | Where the project lives. |
| Name | `--name` | |
| Description | `--description` | One line. |
| Stack | `--backend`, `--frontend` | e.g. `Python 3.12 + FastAPI`, `React 19 + Vite`. `none` if there is no such side; `TBD` if not chosen yet. |
| Purpose | `--learning` / `--production` | Learning: Claude explains the why, introduces concepts, checks understanding. Production: rigour first, short explanations. |
| Solo or team | `--solo` / `--team` | Team mode git-ignores `session/HANDOFF.md`. |
| Code repositories | `--single` / `--separate` | Separate: `code/backend` and `code/frontend` are clones of their own repositories (for example from Bitbucket). |
| Use git? | `--git` | `git init` and a first commit, only if the user says yes. |

Use what the user already said. Ask for **all** missing values in **one** message, never one at a time. Don't guess the purpose, the modes or git: ask.

**Re-run in an existing project** (after cloning the code repositories, or to compare with a newer kit): read the name, description, stacks and modes from the project's root `CLAUDE.md` instead of asking again.

## 2. Existing folder: propose renames first

If the folder exists and isn't empty:

1. `bash "<skill-dir>/scripts/new-project.sh" --scan --dir "<folder>"`
2. Show the proposed renames (for example `Docs → docs/`, `server → code/backend/`), the merges, and anything that doesn't fit.
3. Rename, move or delete **only** what the user explicitly approves. Use `git mv` inside a git repository, `mv` otherwise. Never delete without an explicit OK.
4. Then do a dry run and show it before the real run.

## 3. Run the script

```bash
bash "<skill-dir>/scripts/new-project.sh" --dry-run \
  --dir "<folder>" --name "<name>" --description "<one line>" \
  --backend "<backend stack>" --frontend "<frontend stack>" \
  --learning --solo --single     # or --production, --team, --separate; add --git only if the user said yes
```

Dry run first for an existing folder; for a new or empty folder go straight to the real run (the same command without `--dry-run`).

What the script does:

- Copies every template file that doesn't exist yet, filling in the name, description, date, stacks and kit version, and keeping only the lines for the chosen modes.
- **Never overwrites** an existing file. Lists every file as `added` or `kept`, so running it twice changes nothing.
- Separate mode: leaves `code/backend/` and `code/frontend/` empty (git clone needs an empty folder) and git-ignores them. After cloning, running it again adds their `CLAUDE.md` and `README.md`.
- `--git`: `git init` and a first commit, only if the folder isn't a repository yet. Refuses to commit real env files.
- `--diff`: compares an existing project with the current template (changes nothing). Use it when the kit has been updated: show the user what's new, and apply only the changes they approve, by editing those files.

## 4. Report and hand over

Show the script's output (added, kept, warnings), then the next steps:

- Separate mode: `git clone <url> code/backend` and `git clone <url> code/frontend`, then `/new-project` again to add their files.
- Open the project folder itself in Claude Code, so its `CLAUDE.md` and `.claude/settings.json` load.
- Start with **`/kickoff`** (task T-001): it writes the charter and lists what to research and learn.

If the script prints an error, show it and stop. Don't work around it by writing files by hand.

## Other scripts in this skill

The other kit skills use these; they work on any kit project:

- `scripts/next-id.sh D|T|L [project]`: the next free decision, task or lesson ID.
- `scripts/check-project.sh [project]`: checks the conventions (index tables, IDs, handoff size, plan outcomes, outdated HTML, broken links, placeholders).

## Changing the standard

To change the standard for future projects, edit `template/` and this skill in the kit repository, never one project's copy, and bump `VERSION`. Existing projects keep their files; `--diff` shows them what changed.

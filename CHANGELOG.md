# Changelog

All notable changes to this kit. The version lives in `skills/new-project/VERSION` and is stamped into every project's `CLAUDE.md`.

## 2.1.0 (2026-10-18)

A testing strategy in every project, so a change can't silently break older behaviour.

### Added
- `docs/testing.md` in the template: four test layers (unit, integration, contract, end-to-end), rules, tools and commands, test data, CI, and a **coverage map** showing which tests prove each requirement, endpoint and flow.
- A **Testing** section in the project's `CLAUDE.md`; the definition of done now requires the **full** suite to pass, tests for new behaviour, regression tests for bug fixes, and an updated coverage map.
- Plans get a **Tests** section listing tests per layer, written before or with the code.
- Code folders list commands per layer and an "all tests" command; tracker task T-004 sets testing up.
- `/done` runs the full suite and refuses to weaken failing tests; `/kickoff` adds coverage-map rows for every goal; `/retro` checks the map is complete; `check-project.sh` requires `docs/testing.md`.
- Learning mode explains what each test proves; production mode runs the suite in CI on every push.

## 2.0.0 (2026-10-18)

The full project lifecycle, with learning built in.

### Added
- **`kickoff`**: writes `docs/charter.md` and turns unknowns into research and learning tasks.
- **`feature-plan`**: one plan per feature, approved before code.
- **`done`**: runs the definition of done for real and writes the plan's Outcome.
- **`retro`**: brings the docs up to date and writes `docs/story.md` with a reading guide and test-yourself questions.
- **Learning or production mode** in `new-project`: different working style in the project's `CLAUDE.md`.
- `docs/charter.md`, `docs/learnings.md` (append-only, L-001 and up), `docs/concepts/`, `docs/story.md` in the template.
- deep-doc kind **`concept`**: general explanations that stay useful in later projects.
- Plans get **Concepts involved** and **Outcome** sections; commit messages start with the task ID.
- **Quick HTML pages** (`md-to-html.sh`): Markdown rendered in the browser, with no writing by Claude. Rich pages only on request.
- `next-id.sh` (no hand-counted IDs), `check-project.sh` (conventions, outdated pages, broken links), `new-project.sh --diff` (compare a project with the current template).
- `install.sh`, automated tests (Linux, macOS bash 3.2, Windows Git Bash, Chromium), this changelog, MIT licence.

### Changed
- **Markdown first**: research reports are Markdown (`research/YYYY-MM-DD-topic.md`); every HTML page is generated into `docs/visual/` only when asked.
- `plan` is now **`feature-plan`** and `brief` is now **`status-brief`**: the old names clash with built-in Claude Code commands. `install.sh` retires the old copies.
- Skills find their scripts relative to their own folder, so the kit works from `~/.claude/skills`, from claude.ai-synced skills, or anywhere else.
- Skill descriptions are narrower, so they don't compete with general built-in skills.
- Template `CLAUDE.md` files are stored as `CLAUDE.md.tmpl`, so they never load as instructions while working on the kit.

## 1.0.0 (2026-10-18)

First version: `new-project`, `deep-doc`, `brief`, `research-report`, `handoff`, `pickup`, the project template and the shared page shell.

# docs

Living documentation: kept true to the code and updated as the project changes. Every doc is Markdown; HTML versions are generated into `visual/` only on request.

- **Goes in:** how the project works and why: the files below and the folders `features/`, `flows/`, `concepts/`, `briefs/` and `visual/`.
- **Doesn't go in:** team documents (→ `inputs/`), research reports (→ `research/`), plans and working notes (→ `session/`).
- **Naming:** lower case with hyphens. Feature, flow and concept docs are named after their subject (`features/password-reset.md`, `flows/checkout.md`, `concepts/jwt.md`); briefs are dated (`briefs/2026-03-14-launch-status.md`).
- **Updated:** whenever behaviour, architecture, a flow or the API changes (part of the definition of done). Update a doc's row below every time the doc changes.

**Statuses:** `not started` · `draft` · `current` · `outdated`

| Doc | What it covers | Status | Updated |
|---|---|---|---|
| [charter.md](charter.md) | Why the project exists: problem, goals, success criteria, scope | not started | {{DATE}} |
| [architecture.md](architecture.md) | How the system is put together, and why | not started | {{DATE}} |
| [api.md](api.md) | The contract between frontend and backend | not started | {{DATE}} |
| [runbook.md](runbook.md) | How to set up, run, test, deploy and fix it | not started | {{DATE}} |
| [testing.md](testing.md) | Test layers, rules, commands and the coverage map | not started | {{DATE}} |
| [glossary.md](glossary.md) | Every project term, defined once | current | {{DATE}} |
| [decisions.md](decisions.md) | Decision log, D-001 and up, append-only | current | {{DATE}} |
| [learnings.md](learnings.md) | Lessons log, L-001 and up, append-only | current | {{DATE}} |
| [tracker.md](tracker.md) | Tasks: Now, Next, Blocked, Done | current | {{DATE}} |
| [story.md](story.md) | The project's story and reading guide, written at the end | not started | {{DATE}} |

Feature docs, flow docs, concept docs and briefs get a row here when they are created.

---
name: feature-plan
description: Write the plan for one feature or change in a kit project before any code is touched, in session/plans/<feature>.md (goal, context, concepts involved, small numbered steps, files to change, risks, how we'll check it works), link it to a tracker task, then stop and wait for the user's approval. Use before any non-trivial work in a project with session/plans/, or when the user says plan this feature, let's plan, how should we build this, or runs /feature-plan.
argument-hint: "<feature>"
---

# feature-plan

A plan is how we agree on the work **before** it happens, and later the record of how it was done.

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

Feature (may be empty): `$ARGUMENTS`

## 1. Gather context (cheaply)

- `docs/charter.md`: does this serve a goal? If it's out of scope, say so before planning.
- `docs/decisions.md`, `research/README.md` and `docs/glossary.md` for what's already settled.
- The relevant docs in `docs/features/`, `docs/flows/`, `docs/api.md`.
- The code it touches. Use a subagent for broad searches; read only the files that matter.

If a real choice between options comes up and isn't decided yet, stop and say so: it needs research (`research-report`) or a decision from the user first. Don't bury an undecided choice inside a plan.

## 2. Write session/plans/<feature>.md

Name it after the feature, lower case with hyphens. Use the format in `session/plans/README.md`:

- **Status:** `draft`. **Tracker:** the task ID. If there's no task yet, add one (ID from `bash "<kit>/new-project/scripts/next-id.sh" T`; update "Last ID used").
- **Goal:** what will be true when it's finished.
- **Context:** why now, what exists; link the charter, decisions (D-nnn) and research.
- **Concepts involved:** the ideas the work relies on, linking `docs/concepts/`. In a learning project, list new concepts explicitly: each gets a concept doc before or during the work.
- **Steps:** numbered, small, each checkable on its own (`1. [ ] …`). A step that takes more than an hour or touches many files is too big: split it.
- **Files to change:** path, and what changes.
- **Risks:** each with how we'll reduce it or notice it.
- **How we'll check it works:** tests to add or run, manual checks with expected results.
- **Outcome:** leave the placeholder; `/done` fills it.

## 3. Stop for approval

Show the user a short summary: goal, number of steps, the main risk, and anything you need them to decide. **Don't change any code until they approve.** When they do:

- set **Status** to `approved`;
- move the task to **Now** in `docs/tracker.md`;
- update the handoff's Next step if this changes it.

If they ask for changes, edit the plan and ask again.

## While working

Tick steps as they're done (`[x]`). If reality forces a different approach, update the plan and say so: the Outcome will explain the difference.

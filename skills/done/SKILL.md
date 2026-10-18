---
name: done
description: Close a task or feature in a kit project by running the definition of done for real, not from memory. Runs the tests, updates the tracker, updates the docs that the change affects, logs decisions and lessons, writes the plan's Outcome and moves it to done/, runs the project checks, and offers a commit with the task ID. Reports a checklist and never claims done while an item fails. Use when the user says done, finished, wrap this task up, close T-nnn, or a plan's last step is complete.
argument-hint: "[T-nnn]"
---

# done

The definition of done lives in the project's `CLAUDE.md`. This skill checks every item and shows the result.

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

Task (may be empty, then use the task in Now): `$ARGUMENTS`

## The checklist, in order

1. **It works and the tests pass.** Run the test command from the code folder's `CLAUDE.md` and show the result. If there are no tests for the change, say so; in a production project, write them first.
2. **Docs match the change.** Decide which docs the change affects: behaviour (`docs/features/`), a journey (`docs/flows/`), structure (`docs/architecture.md`), the API (`docs/api.md`), settings (`docs/runbook.md` and `.env.example`). Update them following the deep-doc rules and their rows in `docs/README.md`. A new concept gets a doc in `docs/concepts/`. If nothing needs updating, say why.
3. **Decisions logged.** Every choice with real alternatives made during the task has an entry in `docs/decisions.md` (ID from `bash "<kit>/new-project/scripts/next-id.sh" D`).
4. **Lessons logged.** Every bug and its root cause, dead end or surprise from the task has an entry in `docs/learnings.md` (ID from `next-id.sh L`). Ask the user too: "anything you learned here that should be written down?"
5. **Plan closed.** In `session/plans/<feature>.md`: tick the steps, write the **Outcome** (what was actually done, what changed from the plan and why, links to the L- and D-entries), set **Status** to `done`, then move it with `git mv` (or `mv`) to `session/plans/done/`.
6. **Tracker updated.** Move the task to Done with today's date; add follow-up tasks with new IDs.
7. **Project checks pass.** `bash "<kit>/new-project/scripts/check-project.sh"` reports nothing. Fix what it reports.
8. **Committed.** Ask before committing. The message starts with the task ID: `T-012: Add the login form`; mention decision IDs in the body. In separate mode, commit code in its own repository and the docs at the project root.

## Learning projects: check understanding

Before the last step, ask the user to explain the key idea of this task back in two or three sentences, or to predict what a small change would do. Correct any misunderstanding directly, and log it as a lesson if it was a real one.

## Report

Show the checklist with ✓ or ✗ and one line each. If anything is ✗, the task is **not done**: say what's missing. If the user accepts it anyway, record why in the task's Done line. Then suggest the next task, or `/handoff` if the session is ending.

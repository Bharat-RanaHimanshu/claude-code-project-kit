---
name: done
description: Close a task or feature in a kit project by running the definition of done for real, not from memory. Runs the full test suite (so older behaviour can't silently break), updates the tracker, updates the docs that the change affects, logs decisions and lessons, writes the plan's Outcome and moves it to done/, runs the project checks, and offers a commit with the task ID. Reports a checklist and never claims done while an item fails. Use when the user says done, finished, wrap this task up, close T-nnn, or a plan's last step is complete.
argument-hint: "[T-nnn]"
---

# done

The definition of done lives in the project's `CLAUDE.md`. This skill checks every item and shows the result.

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

Task (may be empty, then use the task in Now): `$ARGUMENTS`

## The checklist, in order

1. **The full suite passes.** Run the **all tests** command from each code folder's `CLAUDE.md` (in separate mode, in each repository), not just the new tests, and show the counts (passed, failed, skipped). A failure in an older test means the change broke something: fix it, never delete or weaken the test to make it pass.
2. **The new behaviour is tested.** Every test listed in the plan's Tests section exists and passes. A bug fix has a regression test that failed before the fix. Missing tests are written now, not left for later.
3. **The coverage map is current.** Add or update the rows in `docs/testing.md` for every requirement, endpoint or flow this task touched.
4. **Docs match the change.** Decide which docs the change affects: behaviour (`docs/features/`), a journey (`docs/flows/`), structure (`docs/architecture.md`), the API (`docs/api.md`), settings (`docs/runbook.md` and `.env.example`). Update them following the deep-doc rules and their rows in `docs/README.md`. A new concept gets a doc in `docs/concepts/`. If nothing needs updating, say why.
5. **Decisions logged.** Every choice with real alternatives made during the task has an entry in `docs/decisions.md` (ID from `bash "<kit>/new-project/scripts/next-id.sh" D`).
6. **Lessons logged.** Every bug and its root cause, dead end or surprise from the task has an entry in `docs/learnings.md` (ID from `next-id.sh L`), linked to its regression test. Ask the user too: "anything you learned here that should be written down?"
7. **Plan closed.** In `session/plans/<feature>.md`: tick the steps, write the **Outcome** (what was actually done, what changed from the plan and why, links to the L- and D-entries), set **Status** to `done`, then move it with `git mv` (or `mv`) to `session/plans/done/`.
8. **Tracker updated.** Move the task to Done with today's date; add follow-up tasks with new IDs.
9. **Project checks pass.** `bash "<kit>/new-project/scripts/check-project.sh"` reports nothing. Fix what it reports.
10. **Committed.** Ask before committing. The message starts with the task ID: `T-012: Add the login form`; mention decision IDs in the body. No co-author, session or tool attribution lines. In separate mode, commit code in its own repository and the docs at the project root.

## Learning projects: check understanding

Before the last step, ask the user to explain the key idea of this task back in two or three sentences, or to predict what a small change would do. Correct any misunderstanding directly, and log it as a lesson if it was a real one.

## Report

Show the checklist with ✓ or ✗ and one line each. If anything is ✗, the task is **not done**: say what's missing. If the user accepts it anyway, record why in the task's Done line. Then suggest the next task, or `/handoff` if the session is ending.

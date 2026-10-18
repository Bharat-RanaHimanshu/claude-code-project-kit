---
name: handoff
description: Save the working state of a kit project so the next session, or this one after compaction, can continue with no memory of the conversation. Checks git in every repository, logs unlogged decisions and lessons, updates the tracker, then rewrites session/HANDOFF.md (under 8,000 characters) with the goal, done, in progress, the exact next step, decisions, what didn't work, how to check, open questions, and each repository's branch and last commit. Use at the end of each task, before the context fills up, before stopping, or when the user says handoff, wrap up, save progress or "done for today".
---

# handoff

Write for a reader with **no memory of this conversation**: a new session, or this one after compaction.

**Paths:** `<skill-dir>` is this skill's base directory (shown when the skill loads); `<kit>` is its parent folder. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

## 1. Check the repositories

```bash
bash "<skill-dir>/scripts/repo-state.sh"
```

Run it from the project root, or pass the project folder as the first argument. It prints the branch, last commit, uncommitted changes and recent commits for the root, `code/backend` and `code/frontend` (whichever are git repositories).

Uncommitted changes go into the handoff. If the task is finished, remind the user that the definition of done needs the code committed (or suggest `/done`). Don't commit without asking.

## 2. Bring the records up to date

1. **Lessons first.** Every bug and its root cause, dead end or surprise from this session that isn't in `docs/learnings.md` yet gets an entry (ID from `bash "<kit>/new-project/scripts/next-id.sh" L`). The handoff's "What didn't work" section is rewritten every time; the learnings log is where lessons survive.
2. **Decisions:** every choice with real alternatives that isn't in `docs/decisions.md` yet gets an entry (`next-id.sh D`).
3. **Tracker:** move tasks between Now, Next, Blocked and Done; add new tasks (`next-id.sh T`) and update "Last ID used". Never reuse an ID.
4. **Plan:** tick the finished steps of the active plan.

## 3. Rewrite session/HANDOFF.md

Rewrite the whole file; don't append. Use exactly this structure:

```markdown
# Handoff

**Updated:** YYYY-MM-DD HH:MM

## Repositories

| Repo | Branch | Last commit | Uncommitted |
|---|---|---|---|
| root | main | a1b2c3d 2026-10-18 T-012: Add the login form | none |

## Goal
What we're trying to achieve right now, and why. One short paragraph.

## Done
- What's finished and still relevant, with T-numbers.

## In progress
- What's half done: the file, what's there, what's missing. Link the active plan.

## Next step
The single, exact next action (file, function, command), specific enough to start without asking.

## Decisions made
- D-nnn: one line each. The details live in docs/decisions.md.

## What didn't work
- The approach, and why it failed, with its L-number.

## How to check
- Commands or steps that show the current state works, with the expected results.

## Open questions
- Questions for the user, or unknowns that block progress.
```

## Rules

- **Under 8,000 characters.** Check with `wc -c session/HANDOFF.md`. If it's over, cut detail that lives elsewhere (decisions, learnings, tracker, docs) and link to it instead.
- Concrete beats vague: file paths, function names, exact error messages, commit hashes.
- Record what *is*, not what you hope: if the tests weren't run, say so.
- No secrets, and nothing from env files.
- Team mode (see the root `CLAUDE.md`): the handoff is git-ignored. Never force-add it.

## 4. Check and confirm

Run `bash "<kit>/new-project/scripts/check-project.sh"` and fix what it reports. Then tell the user in two or three lines: the handoff is written (with its character count), which decisions, lessons and tasks were updated, and anything still uncommitted.

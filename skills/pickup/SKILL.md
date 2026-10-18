---
name: pickup
description: Resume work in a kit project at the start of a session or after a break. Reads session/HANDOFF.md and docs/tracker.md, compares them with the real git state of every repository, runs the project checks, reports where things stand in at most ten lines, flags anything stale, then asks before continuing with the next step, unless the user said "go". Use when the user says pickup, resume, continue, carry on, where were we or what's next, or starts a session in a project that has session/HANDOFF.md.
argument-hint: "[go]"
---

# pickup

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

Argument (may be empty): `$ARGUMENTS`

## 1. Read

1. `session/HANDOFF.md`
2. `docs/tracker.md`: Now, Blocked and the top of Next
3. The git state and the project checks, from the project root:

   ```bash
   bash "<kit>/handoff/scripts/repo-state.sh"
   bash "<kit>/new-project/scripts/check-project.sh"
   ```

Read nothing else yet: no docs, no code, no research reports. Pickup has to stay cheap.

## 2. Compare, and flag anything stale

For each repository:

- **Branch changed**, or **last commit differs** from the handoff: there is work since the handoff. List it with `git -C <repo> log --oneline <recorded-hash>..HEAD`.
- **Uncommitted changes** that the handoff doesn't mention.
- A repository that exists now but isn't in the handoff, or the reverse.

Also flag:

- A handoff older than the newest commit, or more than about a week old.
- Tracker items that the handoff calls done but are still open, or the reverse.
- A next step that refers to a file that no longer exists.
- Problems reported by `check-project.sh`.
- A missing handoff, or the untouched setup placeholder: say so, and start from the tracker instead (for a new project, that's `/kickoff`).

## 3. Report: ten lines at most

```text
Goal: …
Last session (YYYY-MM-DD): …
Done: …
In progress: …
Next step: …
Repos: root main@a1b2c3d ✓ · backend feature/login@9f8e7d6 ⚠ 2 commits since the handoff
Checks: all passed (or: 2 problems: …)
Stale: … (or: nothing stale)
Blocked / open: …
```

Then:

- If the user said **go** (for example `/pickup go`), start on the next step straight away. Stop and ask anyway if something stale makes the next step unsafe (for example, the code it depends on changed since the handoff).
- Otherwise ask one question: continue with the next step, or something else?

## Rules

- Facts come from the files and git only. When the handoff and git disagree, git wins; say so.
- Don't silently fix stale records. Report them, and update them as part of the work once the user agrees.

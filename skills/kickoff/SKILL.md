---
name: kickoff
description: Start a kit project properly before any code. Interviews the user in one go, writes docs/charter.md (problem, users, goals, measurable success criteria, scope and non-goals, constraints, assumptions, risks, milestones), and turns the unknowns into tracker tasks, split into questions to research and concepts to learn. Use right after /new-project, when a kit project has no charter yet, or when the user says kickoff, define the project, or "what are we building".
---

# kickoff

The charter answers **why this project exists and how we'll know it worked**. Everything later (research, plans, the final story) refers back to it.

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

## 1. Read what exists

- `CLAUDE.md` (purpose: learning or production; stacks; modes)
- `inputs/README.md`, then the inputs it lists (use a subagent for long documents and ask it for a summary of requirements, constraints and open questions)
- `docs/charter.md` if it's already started

## 2. Ask once

Ask for everything the inputs don't already answer, in **one** message:

1. The problem: what's wrong or missing today, and who feels it?
2. Who is it for, and what do they need?
3. Goals: what must it achieve?
4. Success: how will we know it worked? Push for something measurable or checkable.
5. Scope: what's in, and what is deliberately out (non-goals)?
6. Constraints: deadline, budget, stack, skills, rules.
7. What do you already know you don't know?

For a learning project, also ask: **what do you want to be able to do or explain by the end?** These become learning goals in the charter.

Don't invent answers. Where the user doesn't know yet, record it under Unknowns.

## 3. Write docs/charter.md

Fill every section of the template: In one line, The problem, Who it's for, Goals (plus **Learning goals** for a learning project), Success criteria, Scope, Non-goals, Constraints, Assumptions, Unknowns, Risks, Milestones. Remove the "not started" status line and set `**Status:** current · **Updated:** YYYY-MM-DD` instead. Keep it to about one page.

## 4. Turn unknowns into work

Split every unknown into one of three kinds, and give each a tracker task in **Next** (get IDs with `bash "<kit>/new-project/scripts/next-id.sh" T`, and update "Last ID used"):

| Kind | Example | Task text |
|---|---|---|
| A choice between options | Which database? Which auth provider? | `Research: <question> (research-report)` |
| A concept to understand | How do JWTs work? What is an index? | `Learn: <concept> (deep-doc concept)` |
| A fact to find out | What's the API rate limit? | `Find out: <fact>` |

Order them: what blocks the first plan comes first.

## 5. Record

- Log scope decisions that had real alternatives in `docs/decisions.md` (for example, "web only, no mobile app"), with the next D-number.
- Update the charter's row in `docs/README.md` (status `current`, today's date).
- Move T-001 (the kickoff task) to Done.
- Set the **Phase** line in the root `CLAUDE.md` to `Research`.
- Run `bash "<kit>/new-project/scripts/check-project.sh"` and fix what it reports.

## 6. Hand over

Show the user the charter in a few lines (one line, success criteria, non-goals) and the ordered list of research and learning tasks. Suggest the first one. Don't start coding: the next step is research, then `/feature-plan`.

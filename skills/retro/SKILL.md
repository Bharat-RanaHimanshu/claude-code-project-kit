---
name: retro
description: Close a kit project, or a major phase of it, so the knowledge survives. Brings every doc up to date with the final code, consolidates the lessons, and writes docs/story.md (why it existed, a timeline, key decisions and why, what changed, what went well and badly, reusable lessons, concepts learned, test-yourself questions, and a reading guide for understanding the project in an hour). Offers an HTML export at the end. Use when the user says retro, retrospective, wrap up the project, close the project, or we're finished.
---

# retro

The goal: someone (including the user, months from now) can understand **what was built, how it works and why**, and reuse the lessons in the next project.

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

## 1. Make the docs true

Use subagents to compare each doc with the final code (one per area: architecture, each feature, each flow, the API, the runbook). For every difference, update the doc following the deep-doc rules, and set its row in `docs/README.md` to `current` with today's date. Docs that no longer apply are marked `outdated` with one line saying why, not deleted.

Run the full test suite and record the result. Check the coverage map in `docs/testing.md`: every goal, success criterion, endpoint and flow has a test, or a line saying why not. Also check: every decision has a status (superseded ones say so), the tracker's open tasks are either done, moved to a "Later" list, or dropped with a reason, and the charter's success criteria have a verdict (met, partly, not met).

## 2. Consolidate the lessons

Read `docs/learnings.md`. Group the entries by theme and pick the five to ten most important. Each becomes a **reusable lesson**: a general rule someone could apply in another project, with links to the L-entries behind it.

## 3. Write docs/story.md

Fill the template's sections:

- **In one line**
- **Why it existed:** the charter's problem and goals, in a short paragraph.
- **Timeline:** a Mermaid `timeline` built from the dates in decisions, plans in `session/plans/done/` and `git log`.
- **Key decisions, and why:** in order, one line each, linking D-nnn and the research behind them.
- **What changed along the way:** from the plans' Outcomes: where reality differed from the plan, and why.
- **The system in one picture:** one diagram (twelve boxes at most) and a paragraph; link `docs/architecture.md`.
- **What went well** and **What was hard**: specific, linking the lessons.
- **What I'd do differently:** concrete, for the next similar project.
- **Reusable lessons:** from step 2.
- **Concepts learned:** links to `docs/concepts/`, one line each on why it mattered here.
- **Test yourself:** five to ten questions that check real understanding (why, what-if, trade-offs; not trivia), each with a short answer in a collapsible `<details>` block. Especially important in a learning project.
- **Reading guide:** "to understand this project in an hour, read these in this order", with a one-line reason for each.

Set the status line and the row in `docs/README.md`. Run `bash "<kit>/new-project/scripts/check-project.sh"` and fix what it reports.

## 4. Offer HTML (only if wanted)

Ask whether the user wants HTML versions:

- **Quick site, almost no tokens:** `bash "<kit>/deep-doc/scripts/md-to-html.sh" --all` makes a page for every doc and report in `docs/visual/`, starting at `docs/visual/index.html`.
- **Rich pages, written by Claude:** for the few pages that deserve it (usually the story and the architecture), following the deep-doc skill's rich-page steps.

## 5. Close

- Set the **Phase** line in the root `CLAUDE.md` to `Done` (or the next phase).
- Run `/handoff` so the final state is recorded.
- Tell the user where to start reading (`docs/story.md`), and list the reusable lessons in a few lines.

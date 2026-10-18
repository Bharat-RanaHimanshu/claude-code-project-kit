---
name: research-report
description: Research a decision question for a kit project (a project with research/ and docs/decisions.md) and write the result as a Markdown report in research/, named YYYY-MM-DD-topic.md. Answer first, then question and constraints, options compared in a table, sourced findings, recommendation, risks, next steps and sources. Then adds a row to research/README.md and logs the decisions. Use when the user asks to research, compare or evaluate options, tools, libraries, vendors or approaches for their project. For open-ended research outside a kit project, the general deep-research skill fits better.
argument-hint: "<question>"
---

# research-report

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

This skill answers **"which option, and why?"** for the project. To explain **how something works** (a concept), use deep-doc with kind `concept` instead.

## 1. Pin down the question

Write down the question in one sentence, the constraints (budget, stack, deadline, team skills, must-haves), and what the answer must let the user decide. Check `research/README.md` first: if an earlier report already answers it, say so and only redo it if the user wants a fresh look. Read `docs/charter.md`, `inputs/` and `docs/decisions.md` for constraints the user may not have repeated. If the question or constraints are still unclear, ask before researching.

## 2. Research

- Use **subagents** for the web research (for example one per option or sub-question). Each returns findings with the source URL, publisher and date.
- Prefer primary sources (official docs, release notes, pricing pages, papers) over blog posts. Note the date of every source, and flag anything older than about a year on a fast-moving topic.
- Check every claim the recommendation depends on against a second source.
- If web search isn't available, say so. Never present memory as researched fact.

## 3. Write the report

File: `research/YYYY-MM-DD-<topic>.md`, lower case with hyphens.

```markdown
# <The question, as a title>

> Research report · YYYY-MM-DD · Decision: D-nnn (or "pending")

## Answer
The conclusion in two or three sentences. A reader who stops here knows what to do.

## Question and constraints

## Options compared
A table: one row per option, one column per criterion that matters.
Where there are numbers, add a chart: a Mermaid xychart-beta or pie block, or a ```chart block
(renders as an interactive chart in the HTML version; see the deep-doc skill's references/page-shell.md).

## Findings
Each finding with its source: "… [3]".

## Recommendation
What to do, and what would change the answer.

## Risks
Of the recommended option, with mitigations.

## Next steps
Concrete, with owners and dates where known.

## Sources
1. Title. Publisher, date. URL
```

## 4. Record it

1. Add a row to the table in `research/README.md`: date, link to the report, the question, the conclusion in one sentence.
2. Log every decision that came out of it in `docs/decisions.md` (ID from `bash "<kit>/new-project/scripts/next-id.sh" D`; "Why" links to the report). A decision the user hasn't made yet is logged as `Proposed`.
3. Add new terms to `docs/glossary.md`, and follow-up work to `docs/tracker.md` (IDs from `next-id.sh T`).
4. If something surprised you or a common belief turned out wrong, add it to `docs/learnings.md`.

## Rules

- **Answer first.**
- Every factual claim has a source. Opinions and inferences are labelled as such.
- No padding: an option ruled out early gets one line saying why.

## HTML, only when asked

Quick page: `bash "<kit>/deep-doc/scripts/md-to-html.sh" research/<name>.md`. A rich page (tabs per option, interactive charts, number tiles) only if the user asks; follow the deep-doc skill's rich-page steps.

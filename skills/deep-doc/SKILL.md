---
name: deep-doc
description: Write or update the detailed Markdown docs of a kit project (docs/features, docs/flows, docs/architecture.md, and docs/concepts for general explanations of ideas the project relies on) with a fixed outline that puts why before how. The outline covers a mental model, a diagram first, trade-offs linked to decision IDs, a worked example with real values, edge cases, and where it lives in the code. Makes HTML versions only on request. Use whenever the user asks to document, explain or write up a feature, flow, the architecture or a concept in a project with a docs/ folder, or asks for HTML or visual docs.
argument-hint: "<feature|flow|architecture|concept> <topic> [quick-html|rich-html]"
---

# deep-doc

Detailed docs that a newcomer can read on their own, understanding **why** before **how**. Every doc is **Markdown**; HTML is made only when asked.

**Paths:** `<skill-dir>` is this skill's base directory (shown when the skill loads); `<kit>` is its parent folder. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

## Where docs go

| Kind | File | One per |
|---|---|---|
| Feature | `docs/features/<feature>.md` | user-facing feature or capability |
| Flow | `docs/flows/<journey>.md` | end-to-end journey (for example, sign-up to first order) |
| Architecture | `docs/architecture.md` | project |
| Concept | `docs/concepts/<concept>.md` | idea the project relies on (JWT, indexes, the event loop) |

Names are lower case with hyphens and carry no dates. If the doc exists, update it rather than writing a second one.

## Before writing

1. **Read the code, not your memory.** Open the files the doc describes and trace the real behaviour. Use a subagent for broad code searches. If the code doesn't exist yet, say so in the doc and describe the design from the approved plan and the decisions.
2. Read `docs/glossary.md`, `docs/decisions.md`, and the relevant plan in `session/plans/` if there is one.

## Outline: features, flows and architecture

```markdown
# <Title>

> **Status:** draft | current · **Updated:** YYYY-MM-DD · **Related:** links to other docs

## In short
Two or three sentences: what it is and why it exists.

## The problem
What goes wrong, or is impossible, without it. Who feels it.

## Mental model
An analogy or picture before any detail ("think of it as a cloakroom ticket…").

## How it works
Starts with a diagram, then walks through it.

## Why it's built this way
The trade-offs, each linked to its decision (D-nnn). The alternatives, and why they lost.

## Worked example
One real run with real values: inputs, intermediate states, outputs.

## Edge cases and failures
What can go wrong, what the user sees, how the system recovers.

## Where it is in the code
`path/to/file.ext`: what lives there (function and class names).

## How to check it works
Commands, tests or manual steps, with expected results.
```

## Outline: concepts

Concept docs explain the idea **in general first**, so they stay useful in other projects, then show where it appears here.

```markdown
# <Concept>

> **Status:** draft | current · **Updated:** YYYY-MM-DD

## In short
Two or three sentences a beginner understands.

## Why it exists
The problem it solves; what people did before it.

## Mental model
An analogy or picture.

## How it works
A diagram, then the mechanics, step by step.

## In this project
Where and how the project uses it, with links to code and docs.

## Common pitfalls
Mistakes people make with it, and how to spot them.

## Check your understanding
Two or three questions (why, what-if), with short answers in <details> blocks.

## Further reading
Primary sources: official docs, specs, well-known articles.
```

## Rules

- **Why before how.** Each section opens with the reason, then the mechanics.
- **Define every term** where it first appears, or link to `docs/glossary.md`. Add new terms to the glossary.
- **Write from the code, not from memory.** Name the files and functions you actually read.
- **Standalone.** A reader with no other context can follow it. Link to other docs instead of assuming them.
- Refer to decisions as `D-nnn`, tasks as `T-nnn`, lessons as `L-nnn`.

## Diagrams

Every doc has **at least one** diagram, chosen by the reader's question:

| Reader's question | Mermaid diagram |
|---|---|
| How do the parts connect? | `flowchart` |
| In what order do things happen? | `sequenceDiagram` |
| What states can it be in? | `stateDiagram-v2` |
| What does the data look like? | `erDiagram` |
| How much, how many? | `xychart-beta` (bar or line) or `pie` |
| When? | `timeline` or `gantt` |

- Mermaid code blocks inside the Markdown. GitHub renders them; VS Code does with the *Markdown Preview Mermaid Support* extension.
- About **twelve boxes at most** per diagram. Split a bigger picture into several diagrams.
- **Label every arrow:** `A -->|sends token| B`.
- Quote labels that contain special characters: `A["Save (draft)"]`.

## After writing

- Update the doc's row in `docs/README.md` (status and date), or add one.
- Add new terms to `docs/glossary.md`.
- If writing the doc surfaced a decision with real alternatives, log it in `docs/decisions.md` (ID from `bash "<kit>/new-project/scripts/next-id.sh" D`).

## HTML, only when asked

All generated pages go to `docs/visual/`, are never edited by hand, and are regenerated when their Markdown changes (`check-project.sh` reports outdated ones).

**Quick pages** (default; almost no tokens): the script embeds the Markdown in the shared page shell, and the browser renders it with a contents sidebar, light and dark mode, Mermaid diagrams, tables, ` ```chart ` blocks and `> [!NOTE]` callouts.

```bash
bash "<skill-dir>/scripts/md-to-html.sh" docs/features/login.md   # one or more files
bash "<skill-dir>/scripts/md-to-html.sh" --all                    # every doc and report
```

**Rich pages** (only when the user asks for one; costs tokens): tabs, step-throughs, number tiles and hand-placed charts, written by Claude for the few pages that deserve it.

1. Read `references/page-shell.md` in this skill's folder for the component markup.
2. Convert the Markdown faithfully into an HTML body fragment and write it to `docs/visual/.<page>.body.html`. Headings stay headings; add no facts that aren't in the Markdown.
3. Wrap it:

   ```bash
   bash "<skill-dir>/scripts/wrap-page.sh" --title "<Doc title>" \
     --meta "Generated from docs/features/login.md on YYYY-MM-DD. Do not edit; regenerate." \
     --source docs/features/login.md \
     --body docs/visual/.features-login.body.html --out docs/visual/features-login.html --remove-body
   ```

Page names follow the source path: `docs/features/login.md` → `features-login.html`, `research/2026-03-14-auth.md` → `research-2026-03-14-auth.html`, `docs/README.md` → `index.html`. `md-to-html.sh --all` keeps existing rich pages unless given `--force`.

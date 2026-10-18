---
name: status-brief
description: Write a one-page, plain-language status brief for the team head into a kit project's docs/briefs folder, named by date and topic. Covers the point in one line, why it matters, status (on track, at risk or blocked), how it works in three to five points, what's done since the last brief, risks, decisions needed from the reader, and next steps with real dates. 250 to 400 words of Markdown, no code and no jargon, built only from the tracker, decision log and docs. Use when the user asks for a brief, status update, progress report or one-pager for their manager, team head or lead.
argument-hint: "<topic> [html]"
---

# status-brief

**Paths:** `<kit>` is the folder holding the kit's skills: the parent of this skill's base directory. In Git Bash on Windows, use forward slashes (`C:/Users/…`).

## Sources: these only

- `docs/tracker.md`
- `docs/decisions.md`
- the docs in `docs/`, including the charter and the previous brief in `docs/briefs/` (for "done since the last brief")

Don't use the conversation, memory, the code or `session/`. If the sources don't support a statement, leave it out. If something the reader must know is missing from the sources, tell the user and offer to update the tracker or docs first.

## File

`docs/briefs/YYYY-MM-DD-<topic>.md`, lower case with hyphens. A brief is a snapshot: never edit an old one; write a new one.

## Template

```markdown
# <Topic>: brief, <D Month YYYY>

**In one line:** …

## Why it matters
…

## Status: On track | At risk | Blocked
One or two sentences on why.

## How it works
- Three to five points, in plain language.

## Done since the last brief (<date of the last brief>)
- …

## Risks
- The risk, and what we're doing about it.

## Decisions needed from you
- The decision, the options, and by when. Or: "None this time."

## Next steps
- What, who, by <real date>.
```

## Rules

- **250 to 400 words.** Check with `wc -w` (headings count).
- **No code and no jargon:** no file names, commands, task or decision IDs. Replace a technical term with plain words, or explain it in a few words.
- **Real dates** ("Friday 24 October"), never "soon" or "next sprint".
- Status is exactly one of: on track, at risk, blocked.
- Before saving, reread it as the team head: is every sentence clear without asking anyone?

## After writing

Add the brief's row to `docs/README.md`.

## HTML, only when asked

With `html`, make a quick page: `bash "<kit>/deep-doc/scripts/md-to-html.sh" docs/briefs/<name>.md` (it lands in `docs/visual/briefs-<name>.html`). A rich page (status badge, next steps table) only if the user asks for one; follow the deep-doc skill's rich-page steps.

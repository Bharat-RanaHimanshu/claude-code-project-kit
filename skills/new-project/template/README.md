# {{PROJECT_NAME}}

{{DESCRIPTION}}

Set up on {{DATE}} with [claude-code-project-kit](https://github.com/Bharat-RanaHimanshu/claude-code-project-kit).

## Where things are

| Folder | What's in it |
|---|---|
| `inputs/` | Documents from the team and the client: requirements, plans, designs. Listed in `inputs/README.md`. |
| `research/` | Research reports, one per question. Summary table in `research/README.md`. |
| `code/` | `backend/` and `frontend/`. |
| `docs/` | Project documentation. Start at `docs/README.md`. |
| `session/` | Working notes for Claude between sessions: the handoff note and the feature plans. |

## Start here

- **Why does this exist?** `docs/charter.md`.
- **What happened, and what did we learn?** `docs/story.md` (written at the end), then `docs/learnings.md`.
- **Where does it stand?** The latest brief in `docs/briefs/`, then `docs/tracker.md`.
- **How does it work?** `docs/architecture.md`, then `docs/features/`, `docs/flows/` and `docs/concepts/`.
- **How do I run it?** `docs/runbook.md`.
- **Why was it built this way?** `docs/decisions.md`.

## Working with Claude Code

| Command | What it does |
|---|---|
| `/kickoff` | Writes the charter and lists what we need to research and learn. |
| `/feature-plan` | Writes a plan for a feature and waits for approval. |
| `/pickup` | Resumes: reads the handoff and the tracker, checks git, reports where things stand. |
| `/done` | Runs the definition of done for the current task. |
| `/handoff` | Saves the working state for the next session. |
| `/deep-doc` | Writes a detailed feature, flow, architecture or concept doc. |
| `/research-report` | Researches a question and writes a report. |
| `/status-brief` | Writes a one-page summary for the team head. |
| `/retro` | Closes the project: final docs, the story and the reading guide. |

Diagrams in the docs are Mermaid. GitHub shows them directly; in VS Code, install the recommended extension (*Markdown Preview Mermaid Support*).

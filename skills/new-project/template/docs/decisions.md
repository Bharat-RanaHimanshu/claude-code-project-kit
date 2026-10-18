# Decisions

Append-only log of the decisions that had real alternatives. Entries are numbered D-001 and up, and are never deleted or rewritten. To change a decision, add a new entry that supersedes the old one. The only edit allowed on an old entry is its **Status** line, which changes to `Superseded by D-nnn` so readers of the old entry find the new one.

**Statuses:** `Proposed` · `Accepted` · `Superseded by D-nnn`

Template for a new entry:

```markdown
## D-nnn: Title

- **Date:** YYYY-MM-DD
- **Status:** Accepted
- **Supersedes:** D-nnn (only if it replaces an earlier decision)
- **Context:** what forced the decision
- **Decision:** what we chose
- **Why:** the reasons
- **Alternatives rejected:** each option, and why not
- **Consequences:** what this makes easier, harder or necessary
```

---

## D-001: Use the standard project structure

- **Date:** {{DATE}}
- **Status:** Accepted
- **Context:** Without a fixed structure, every project is organised differently, documents are hard to find, and work loses its context between sessions.
- **Decision:** Use the standard structure (`inputs/`, `research/`, `code/`, `docs/`, `session/`) created by claude-code-project-kit, and its lifecycle: kickoff, research, plan, build, done, retro.
- **Why:** Every project looks the same; Claude resumes from files instead of memory; research, decisions and lessons are kept where they can be found and reused.
- **Alternatives rejected:** A free-form folder per project (no consistency, nothing to resume from). A single notes file (it grows unreadable and mixes working state with documentation).
- **Consequences:** Every project carries the same scaffolding, even small ones. Standard folders are not renamed or repurposed without a new decision.

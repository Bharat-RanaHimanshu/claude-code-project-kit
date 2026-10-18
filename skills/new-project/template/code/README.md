# code

The code, split into `backend/` and `frontend/`. Each has its own `CLAUDE.md` with the stack, the install, run and test commands, and the conventions.

- **Goes in:** source code, tests, and the configuration the code needs.
- **Doesn't go in:** documentation (→ `docs/`), plans (→ `session/plans/`), real env files (never committed; settings are listed in `.env.example`).
{{single}}- **Repositories:** both folders are part of this project's repository.
{{separate}}- **Repositories:** `backend/` and `frontend/` are clones of their own repositories and are git-ignored by this project. Commit code in its own repository.
- **Naming:** follow the conventions of each stack.
- **Updated:** with every code change. The contract between the two sides is `docs/api.md`.

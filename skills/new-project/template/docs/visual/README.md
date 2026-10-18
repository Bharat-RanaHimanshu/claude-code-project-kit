# visual

Generated HTML pages, made only on request from the Markdown docs and research reports, using the shared page shell.

- **Goes in:** generated `.html` pages only. Quick pages come from the md-to-html script; rich interactive pages are written by Claude when asked.
- **Doesn't go in:** anything written by hand. Never edit these files: change the Markdown and regenerate.
- **Naming:** the source path with `/` turned into `-`: `docs/features/login.md` → `features-login.html`, `research/2026-03-14-auth.md` → `research-2026-03-14-auth.html`. `docs/README.md` becomes `index.html`.
- **Updated:** regenerated when the source Markdown changes. Each page records which Markdown it came from, and the check-project script reports pages that are out of date.

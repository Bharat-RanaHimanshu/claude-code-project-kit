# plans

One plan per feature, written with `/feature-plan` before coding and approved before any code changes.

- **Goes in:** active plans, one file per feature.
- **Doesn't go in:** finished or abandoned plans (→ `done/`), documentation of how a finished feature works (→ `docs/features/`), decisions (→ `docs/decisions.md`).
- **Naming:** `<feature>.md`, lower case with hyphens, matching the feature doc's name where there is one: `password-reset.md`.
- **Updated:** written before coding; steps are ticked off as they're done; when the feature meets the definition of done, `/done` writes the Outcome and moves the file to `done/`.

## Plan format

````markdown
# Plan: <feature>

**Status:** draft · approved · in progress · done · abandoned
**Tracker:** T-nnn

## Goal

What will be true when this is finished, in one or two sentences.

## Context

Why now, what exists already. Links to the charter, inputs, research and decisions.

## Concepts involved

The ideas this work relies on, with links to `docs/concepts/` (new ones get a concept doc).

## Steps

1. [ ] A small step that can be checked on its own.
2. [ ] …

## Files to change

- `path/to/file`: what changes

## Risks

- Risk → how we'll reduce it, or how we'll notice it.

## How we'll check it works

- Tests to add or run, and manual checks with their expected results.

## Outcome

Written when the plan is finished: what was actually done, what changed from the plan and why, and links to the lessons (L-nnn) and decisions (D-nnn) it produced.
````

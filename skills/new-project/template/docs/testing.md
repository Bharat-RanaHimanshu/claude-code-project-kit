# Testing

> **Status: not started.** Filled in when the stack is set up (task T-004), then kept current: `/done` updates the coverage map with every task.

## In short

How we know the project works, and keeps working when something changes. Each layer catches a different kind of breakage; the full suite runs before any task is done, so a change that breaks older behaviour is caught before it's committed.

## The layers

| Layer | What it proves | Where it lives | When it runs |
|---|---|---|---|
| **Unit** | One function or module's logic, with its dependencies faked | each code folder, per stack convention (e.g. `tests/unit/`) | constantly while coding; whole suite in seconds |
| **Integration** | Parts work together for real: API with database, service with queue. Only external services are faked, at the boundary | `code/backend/tests/integration/` | before every task is done, and in CI |
| **Contract** | Backend responses and frontend requests both match `docs/api.md` | backend `tests/contract/`; frontend API mocks checked against the same contract | before every task is done, and in CI |
| **End-to-end** | A few critical journeys from `docs/flows/`, through the real UI | `code/frontend/tests/e2e/` | before a release, and in CI |

Most tests are unit tests, fewer are integration and contract tests, and only the most important journeys get end-to-end tests: they're slow and the most fragile.

## Rules

- **Test behaviour, not implementation.** A test says what the code must do, not how it does it, so refactoring doesn't break it.
- **Every requirement is proven.** Each goal and success criterion in `charter.md`, each endpoint in `api.md` and each journey in `flows/` has at least one test, listed in the coverage map.
- **Tests come from the plan, before or with the code.** `/feature-plan` lists the tests per layer; they are written from the goal, not reverse-engineered from the finished code.
- **Every bug gets a regression test first:** a test that fails because of the bug, then the fix that makes it pass. Link it to the bug's entry in `learnings.md`.
- **The full suite runs before a task is done,** not just the new tests. That's what catches breaking older behaviour.
- **Tests are independent:** they pass in any order, create their own data, share no state, and never use the real network, clock or production data.
- **A flaky test is a bug.** Fix it, or quarantine it with a tracker task. Never ignore or delete it silently.

## Tools and commands

| Layer | Tool | Command |
|---|---|---|
| Unit | | |
| Integration | | |
| Contract | | |
| End-to-end | | |
| **Everything** | | |

## Coverage map

What proves each requirement. `/done` adds rows; `/retro` checks nothing is missing.

| Requirement, endpoint or flow | Tests | Layer |
|---|---|---|

## Test data

<!-- Fixtures, factories and seed data, and where they live. Never production data or real secrets. -->

## Continuous integration

<!-- Where the suite runs on every push, and what blocks a merge. -->

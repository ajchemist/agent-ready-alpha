# AGENT-SETUP — agent tasks

`setup-wizard.sh` drives the project bootstrap. The wizard performs the
mechanical steps itself — scaffold verification, `git init`, `bd init
--skip-agents`, `bd setup codex`, project-scoped plugin installation
(`mattpocock-skills`, `ponytail`), the bootstrap decision bead, and removal of
the scaffold kit. When it invokes you, your job is only the generative rest.

You are non-interactive: never ask a question; when a choice appears, take the
documented default. Only file reads and edits are needed — do not run shell
commands.

## Constraints

- `CLAUDE.md` must stay a single `@AGENTS.md` line — there is exactly one
  instruction file, `AGENTS.md`.
- Architecture decisions live in beads as `decision` beads, never in
  `docs/adr/` — do not create that directory. See `docs/agents/domain.md`.

## Your tasks

### 1. Rewrite README.md

**Skip when:** `README.md` no longer mentions `setup-wizard.sh` (already
rewritten).

The shipped `README.md` is an onboarding page for this scaffold and is now
obsolete. Replace it entirely with the project's real README. Defaults:

- **Title:** the repository directory name.
- **Description:** derive one line from whatever exists (git remote, project
  files, anything the user stated); otherwise write `Project description TBD.`
- Include a short **Working with agents** section: instructions live in
  `AGENTS.md`, issues in beads (`bd`).

### 2. Sanity checks

- `CLAUDE.md` contains exactly `@AGENTS.md` — if anything else crept in,
  restore it to that single line.
- `docs/adr/` does not exist — if it does, report it; do not silently delete.

### 3. Report

Print a checklist — one line per task above, each marked `OK`,
`SKIPPED (<reason>)`, or `FAILED (<reason>)`. Then stop. Do not commit; leave
the working tree for the user to review.

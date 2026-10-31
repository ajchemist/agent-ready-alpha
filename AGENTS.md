# Agent Instructions

Single instruction file for every coding agent working in this repository
(Claude Code, Codex, and others). Claude Code reads this file through
`CLAUDE.md`, which contains only `@AGENTS.md` — keep it that way and put all
instructions here.

## Project

See `README.md` for what this project is and how to run it.

## Issue tracking

All work items live in beads (`bd`). Do not create TODO files or markdown task
lists — file a bead instead. See `docs/agents/issue-tracker.md`.

## Architecture decisions

ADRs are beads of type `decision`, not files. There is no `docs/adr/` in this
repository and none should be created. See `docs/agents/domain.md`.

## Agent skills

### Issue tracker

Issues are tracked in beads (`bd`), local to this repo. See `docs/agents/issue-tracker.md`.

### Triage labels

The five canonical triage roles, used verbatim as bead labels. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context: one `CONTEXT.md` at the repo root, created lazily; ADRs live in beads as `decision` issues. See `docs/agents/domain.md`.

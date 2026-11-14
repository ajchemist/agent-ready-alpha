# New Project

This directory was created from an agent-ready scaffold. **It is not set up
yet** — a coding agent completes the setup in one run.

## Onboarding

From the project root, run the interactive wizard:

```bash
bash ./setup-wizard.sh
```

The wizard performs the mechanical steps itself and only hands the generative
rest to a coding agent — it will:

- verify the scaffold's integrity against its manifest
- detect which agent CLIs are installed and logged in, and let you pick one
- initialize git and the beads (`bd`) issue tracker
- install the project's agent skills as project-scoped Claude plugins
- record the bootstrap decision as an ADR bead
- invoke your chosen agent to replace this README with the project's real one
  (its instructions live in `.scaffold/AGENT-SETUP.md`)
- remove the scaffold kit (`.scaffold/` and the wizard itself)

## Requirements

- `git`, `bash`, `python3`
- [beads](https://github.com/steveyegge/beads) (`bd`) — issue tracker CLI
- a coding agent CLI the wizard can drive, logged in: `claude`, `codex`,
  `gemini`, `qwen`, `copilot`, `opencode`, `pi`, `omp`, `kimi`, `goose`, `amp`,
  `droid`, `crush`, `cursor` (the `agent` binary), `kiro-cli`, or `aider`. The
  wizard runs it headless with tool calls auto-approved, so it needs no
  further configuration.

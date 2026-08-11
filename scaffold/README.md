# New Project

This directory was created from an agent-ready scaffold. **It is not set up
yet** — a coding agent completes the setup in one run.

## Onboarding

From the project root, run your coding agent once against the bootstrap
instructions:

```bash
claude -p --permission-mode bypassPermissions \
  "Read ./.scaffold/AGENT-SETUP.md and execute every step in it, in order. You are non-interactive: never ask a question, use the documented defaults."
```

`bypassPermissions` is required in print mode: the bootstrap runs shell
commands (`bd`, `claude plugin`, `git`), and stricter modes deny them with no
way to approve. This directory is freshly created, so the blast radius is the
scaffold itself.

Any agent that can read files and run shell commands works — point it at
`.scaffold/AGENT-SETUP.md`.

The bootstrap will:

- verify the scaffold's integrity against its manifest
- install the project's agent skills as project-scoped Claude plugins
- initialize the beads (`bd`) issue tracker
- record the bootstrap decision as an ADR bead
- replace this README with your project's real README
- remove `.scaffold/`

## Requirements

- `git`, `bash`, `python3`
- [beads](https://github.com/steveyegge/beads) (`bd`) — issue tracker CLI
- a coding agent (Claude Code, Codex, …)

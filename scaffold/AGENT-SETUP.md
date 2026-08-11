# AGENT-SETUP — project bootstrap

You are bootstrapping this project. Execute every step below, in order, from
the repository root. You are non-interactive: never ask a question; when a
choice appears, take the documented default.

Every step states a **Skip when** condition. Re-running this document must
change nothing: check the condition first, and if it holds, mark the step
`SKIPPED` and move on.

Announce each step as `[n/8] <title>` and finish with the report in step 8.

## 1. Verify scaffold integrity

Run:

```bash
bash .scaffold/verify.sh .
```

Expect the last line to read `N/N files match the manifest` with both numbers
equal. On any failure, stop immediately and report it — do not bootstrap a
corrupted scaffold.

## 2. Install agent skills (project scope)

**Skip when:** the `claude` CLI is not installed (note this in the report and
continue), or `.claude/settings.json` already enables both plugins.

Install `mattpocock-skills` from the official Claude plugin marketplace and
`ponytail` from its own marketplace, both at **project scope**:

```bash
claude plugin install mattpocock-skills --scope project
claude plugin marketplace add DietrichGebert/ponytail --scope project
claude plugin install ponytail@ponytail --scope project
```

If the first command cannot resolve `mattpocock-skills` from the official
marketplace, add its marketplace explicitly and retry:

```bash
claude plugin marketplace add mattpocock/skills --scope project
claude plugin install mattpocock-skills@mattpocock --scope project
```

Project-scope installs are recorded in `.claude/settings.json`; the skills
become available from the next agent session.

## 3. Initialize the issue tracker

**Skip when:** never — the command is idempotent by itself.

If `.git/` does not exist yet, first run `git init -b main` (beads installs
git hooks). Then:

```bash
bd init --init-if-missing --skip-agents --non-interactive
```

`--skip-agents` is deliberate: it stops `bd` from writing its own guidance
into `CLAUDE.md`. `CLAUDE.md` must stay a single `@AGENTS.md` line — there is
exactly one instruction file, `AGENTS.md`.

## 4. Wire beads guidance into AGENTS.md

**Skip when:** `bd setup codex --check` reports the integration is installed.

```bash
bd setup codex
```

This inserts a fenced beads block into `AGENTS.md` (idempotent: re-runs
replace the block in place and preserve surrounding content) and installs the
Codex-side skill and hooks. Never run `bd setup -o AGENTS.md` — it overwrites
the entire file.

## 5. Record the bootstrap decision

**Skip when:** `bd list -t decision` already lists a bead titled
`bootstrap: agent conventions adopted`.

```bash
bd create -t decision "bootstrap: agent conventions adopted" \
  -d "Conventions fixed at bootstrap: single instruction file (AGENTS.md; CLAUDE.md is only '@AGENTS.md'); issues and ADRs tracked in beads — ADRs are 'decision' beads, never docs/adr/; agent skills installed as project-scoped Claude plugins (mattpocock-skills, ponytail). Specs live in docs/agents/."
```

Architecture decisions in this project are beads of type `decision` — see
`docs/agents/domain.md`. Never create `docs/adr/`.

## 6. Rewrite README.md

**Skip when:** `README.md` no longer mentions `.scaffold/AGENT-SETUP.md`
(already rewritten).

The shipped `README.md` is an onboarding page for this scaffold and is now
obsolete. Replace it entirely with the project's real README. Defaults:

- **Title:** the repository directory name.
- **Description:** derive one line from whatever exists (git remote, project
  files, anything the user stated); otherwise write `Project description TBD.`
- Include a short **Working with agents** section: instructions live in
  `AGENTS.md`, issues in beads (`bd`).

## 7. Remove the scaffold kit

**Skip when:** `.scaffold/` does not exist, **or any earlier step reported
`FAILED`** — leave `.scaffold/` in place so the bootstrap can be re-run after
the failure is resolved.

```bash
rm -rf .scaffold
```

`.scaffold/` is bootstrap-only tooling; a bootstrapped project keeps no trace
of it.

## 8. Report

Print a checklist — one line per step 1–7, each marked `OK`,
`SKIPPED (<reason>)`, or `FAILED (<reason>)` — followed by the created
decision bead's ID. Then stop. Do not commit; leave the working tree for the
user to review.

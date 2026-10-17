# Domain Docs

How agents should consume this repo's domain documentation when exploring the
codebase. This repo uses the **single-context** layout: one `CONTEXT.md` at
the repository root, and ADRs recorded in beads.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root — the glossary and domain model.
- **`bd list -t decision`** — the ADR log. Read the decisions that touch the
  area you're about to work in (`bd show <id>` for the full record).

If `CONTEXT.md` doesn't exist, **proceed silently**. Don't flag its absence;
don't suggest creating it upfront. The `domain-modeling` skill creates it
lazily when terms or decisions actually get resolved.

## ADRs live in beads

Architecture decisions are beads of type `decision` — there is no `docs/adr/`
directory and none should be created.

- **Record** a decision:

  ```bash
  bd create -t decision "Short decision title" -d "Context, decision, consequences."
  ```

- **The bead ID is the ADR number.** Reference decisions by bead ID in
  commits, issues, and docs.
- **Reverse** a decision by superseding it, never by editing history:

  ```bash
  bd supersede <old-id> --with <new-id>
  ```

  The superseded bead is closed automatically with a reference to its
  replacement.

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor
proposal, a hypothesis, a test name), use the term as defined in `CONTEXT.md`.
Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either
you're inventing language the project doesn't use (reconsider) or there's a
real gap (note it for `domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing decision bead, surface it explicitly
rather than silently overriding:

> _Contradicts decision `<id>` (event-sourced orders) — but worth reopening
> because…_

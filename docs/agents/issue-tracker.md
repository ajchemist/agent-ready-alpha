# Issue tracker: beads

Issues for this repo live in [beads](https://github.com/steveyegge/beads)
(`bd`) — a local-first, git-native issue tracker. The database lives in
`.beads/`; there is no web UI and no remote service. Run `bd` commands from
the repository root.

## Conventions

- Every work item is a bead. No TODO files, no markdown task lists.
- Types: `bug`, `feature`, `task`, `chore`, `epic` for work; `decision` for
  ADRs (see `domain.md`).
- Priority: `-p 0` (urgent) through `-p 3` (someday); default is `2`.
- Triage state is expressed with labels (see `triage-labels.md`).
- Dependencies are first-class: use them instead of "blocked on X" comments.

## Core commands

```bash
bd create "Title" -t task -p 2 -d "Description"   # file an issue
bd list                                           # open issues
bd list -t decision                               # ADR log
bd show <id>                                      # full detail
bd update <id> --status in_progress               # claim work
bd close <id> --reason "done: <what changed>"     # finish work
bd ready                                          # issues unblocked and ready to pick up
bd dep <blocker-id> --blocks <blocked-id>         # record a dependency
bd label add <id> <label>                         # apply a triage label
```

## When a skill says "publish to the issue tracker"

Create beads with `bd create`. For a spec that decomposes into several
tickets, create one bead per ticket and record ordering with `bd dep`; attach
the spec body to the parent bead's description (`--body-file -` accepts
stdin).

## When a skill says "fetch the relevant ticket"

`bd show <id>`. The user will normally pass the bead ID directly; otherwise
find it with `bd list` (`--json` is available for machine reading).

## Picking work

Prefer `bd ready` — it lists issues whose dependencies are all resolved.
Claim with `bd update <id> --status in_progress` before starting; close with a
reason that states what actually changed.

## PRs as a request surface

Off. Pull requests are not part of the triage queue; work enters through
beads only.

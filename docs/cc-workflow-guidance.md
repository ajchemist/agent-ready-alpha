# CC workflow guidance

## What belongs in the cc branch

The cc branch is reserved for the minimal scaffold used by downstream consumers.

Allowed files:
- .claude/installed.json
- .gitignore
- .scaffold/manifest.json

Forbidden files:
- README.md
- scripts/
- .github/
- any repository-specific development files

## How the workflow works

1. The maintenance workflow runs from main.
2. It creates a temporary scaffold in a disposable directory.
3. It writes a manifest containing the SHA-256 hashes for each approved file.
4. It sends the manifest to Omniroute (or the stub implementation when no endpoint is configured).
5. When the verdict is approve, the workflow force-pushes the scaffold to the cc branch.

## Local verification

After cloning the scaffold with degit, run:

```bash
./verify_scaffold.sh
```

The script checks that the checked-out files still match the manifest hashes.

## Drift handling

If a push to cc introduces unexpected files, the validate workflow fails and creates an issue so the drift can be investigated.

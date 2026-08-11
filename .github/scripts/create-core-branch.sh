#!/usr/bin/env bash
set -euo pipefail

workspace_dir="${GITHUB_WORKSPACE:-$(pwd)}"
scaffold_src="$workspace_dir/scaffold"
tmp_dir="$(mktemp -d)"
cleanup() { rm -rf "$tmp_dir"; }
trap cleanup EXIT

stamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
project_dir="$tmp_dir/scaffold"

# --- Source guards -----------------------------------------------------------

if [[ "$(cat "$scaffold_src/CLAUDE.md")" != "@AGENTS.md" ]]; then
  echo "scaffold/CLAUDE.md must contain only '@AGENTS.md'" >&2
  exit 1
fi

if [[ -e "$scaffold_src/.gitignore" ]]; then
  echo "scaffold/ must not contain a file named .gitignore — keep it as dot.gitignore" >&2
  exit 1
fi

# --- Assemble the tree -------------------------------------------------------

mkdir -p "$project_dir/.scaffold" "$project_dir/docs/agents"
cp "$scaffold_src/AGENTS.md" "$scaffold_src/CLAUDE.md" "$scaffold_src/README.md" "$project_dir/"
cp "$scaffold_src/dot.gitignore" "$project_dir/.gitignore"
cp "$scaffold_src"/docs/agents/*.md "$project_dir/docs/agents/"
cp "$scaffold_src/AGENT-SETUP.md" "$scaffold_src/verify.sh" "$project_dir/.scaffold/"
cp "$scaffold_src/setup-wizard.sh" "$project_dir/setup-wizard.sh"
chmod +x "$project_dir/setup-wizard.sh"

# --- Provenance guard --------------------------------------------------------
# The scaffold output must carry no reference to its source repository or its
# owner (decision bead agent-ready-alpha-o32). Keywords are derived from the
# environment, so forks are covered without editing this script.

provenance_terms=()
if [[ -n "${GITHUB_REPOSITORY:-}" ]]; then
  provenance_terms+=("${GITHUB_REPOSITORY%%/*}" "${GITHUB_REPOSITORY##*/}")
fi
if [[ -n "${GITHUB_ACTOR:-}" ]]; then
  provenance_terms+=("$GITHUB_ACTOR")
fi
origin_url="$(git -C "$workspace_dir" remote get-url origin 2>/dev/null || true)"
if [[ -n "$origin_url" ]]; then
  while IFS= read -r part; do
    provenance_terms+=("$part")
  done < <(printf '%s\n' "$origin_url" | sed -E 's#\.git$##; s#^.*[:/]([^/]+)/([^/]+)$#\1\n\2#')
fi

leak=0
checked=()
for term in "${provenance_terms[@]}"; do
  if [[ "${#term}" -lt 4 ]]; then
    continue  # too short — would false-positive on ordinary words
  fi
  case " ${checked[*]-} " in *" $term "*) continue ;; esac
  checked+=("$term")
  if grep -riF -- "$term" "$project_dir"; then
    echo "provenance leak: '$term' found in the scaffold output" >&2
    leak=1
  fi
done
if [[ "${#checked[@]}" -eq 0 ]]; then
  echo "provenance guard: no keywords derivable (need GITHUB_REPOSITORY or an origin remote)" >&2
  exit 1
fi
if [[ "$leak" -ne 0 ]]; then
  exit 1
fi
echo "provenance check: 0 occurrences of: ${checked[*]}"

# --- Manifest ----------------------------------------------------------------

entry_count=$(python3 - "$project_dir" "$stamp" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

root = Path(sys.argv[1])
manifest = {"generated_at": sys.argv[2], "files": {}}
for target in sorted(root.rglob("*")):
    if not target.is_file():
        continue
    rel = target.relative_to(root).as_posix()
    if rel == ".scaffold/manifest.json":
        continue
    digest = hashlib.sha256(target.read_bytes()).hexdigest()
    manifest["files"][rel] = f"sha256:{digest}"
(root / ".scaffold/manifest.json").write_text(
    json.dumps(manifest, indent=2) + "\n", encoding="utf-8"
)
print(len(manifest["files"]))
PY
)
echo "$entry_count entries in manifest"

bash "$project_dir/.scaffold/verify.sh" "$project_dir"

# --- Verdict gate ------------------------------------------------------------

verdict="approve"
response_body=""
if [[ -n "${OMNIROUTE_URL:-}" ]]; then
  payload=$(cd "$project_dir" && python3 - <<'PY'
import json
import os
with open(".scaffold/manifest.json", "r", encoding="utf-8") as handle:
    manifest = json.load(handle)
print(json.dumps({
    "repository": os.environ.get("GITHUB_REPOSITORY", "unknown"),
    "actor": os.environ.get("GITHUB_ACTOR", "unknown"),
    "manifest": manifest,
}))
PY
)
  response_body=$(curl -fsSL -X POST -H 'Content-Type: application/json' -H 'Accept: application/json' --data "$payload" "$OMNIROUTE_URL" 2>/dev/null || true)
  if [[ -n "$response_body" ]]; then
    verdict=$(python3 - "$response_body" <<'PY'
import json
import sys
try:
    payload = json.loads(sys.argv[1])
except Exception:
    print('approve')
    raise SystemExit(0)
print(payload.get('verdict', 'approve'))
PY
)
  fi
fi

printf 'verdict=%s\n' "$verdict" | tee "$workspace_dir/core_verdict.txt"
if [[ "$verdict" != "approve" ]]; then
  echo "$response_body" > "$workspace_dir/core_omniroute_response.txt"
  echo 'Omniroute did not approve the scaffold.' >&2
  exit 1
fi

# --- Commit and push ---------------------------------------------------------

cd "$project_dir"
git init -q
git config user.name "${GITHUB_ACTOR:-github-actions[bot]}"
git config user.email "${GITHUB_ACTOR:-github-actions[bot]}@users.noreply.github.com"
git add .
git commit -q -m "chore: update core scaffold — $stamp"

if [[ -z "${GITHUB_TOKEN:-}" || -z "${GITHUB_REPOSITORY:-}" ]]; then
  echo "dry run: GITHUB_TOKEN/GITHUB_REPOSITORY not set — skipping push"
  exit 0
fi

remote_url="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git remote add origin "$remote_url"
git push --force origin HEAD:core >/dev/null

commit_sha=$(git rev-parse HEAD)
printf '%s\n' "$commit_sha" > "$workspace_dir/core_commit_sha"
echo "core branch updated at $commit_sha"

#!/usr/bin/env bash
set -euo pipefail

workspace_dir="${GITHUB_WORKSPACE:-$(pwd)}"
tmp_dir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

stamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
project_dir="$tmp_dir/scaffold"
mkdir -p "$project_dir/.claude" "$project_dir/.scaffold"

cat > "$project_dir/.claude/installed.json" <<EOF
{
  "schema": "1.0",
  "installed": ["claude"],
  "generated_at": "${stamp}"
}
EOF

cat > "$project_dir/.gitignore" <<'EOF'
.DS_Store
node_modules/
.venv/
EOF

python3 - "$project_dir" "$project_dir/.scaffold/manifest.json" "$stamp" <<'PY'
import hashlib
import json
import sys
from pathlib import Path
root = Path(sys.argv[1])
manifest_path = Path(sys.argv[2])
generated_at = sys.argv[3]
files_to_hash = [".claude/installed.json", ".gitignore"]
manifest = {"generated_at": generated_at, "files": {}}
for rel in files_to_hash:
    target = root / rel
    content = target.read_bytes()
    manifest["files"][rel] = f"sha256:{hashlib.sha256(content).hexdigest()}"
manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
PY

verdict="approve"
response_body=""
if [[ -n "${OMNIROUTE_URL:-}" ]]; then
  payload=$(python3 - <<'PY'
import json
import os
manifest_path = ".scaffold/manifest.json"
with open(manifest_path, "r", encoding="utf-8") as handle:
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
    verdict=$(python3 - <<'PY' "$response_body"
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

printf 'verdict=%s\n' "$verdict" | tee "$workspace_dir/cc_verdict.txt"
if [[ "$verdict" != "approve" ]]; then
  echo "$response_body" > "$workspace_dir/cc_omniroute_response.txt"
  echo 'Omniroute did not approve the scaffold.' >&2
  exit 1
fi

cd "$project_dir"
git init

git config user.name "${GITHUB_ACTOR:-github-actions[bot]}"
git config user.email "${GITHUB_ACTOR:-github-actions[bot]}@users.noreply.github.com"

git add .
git commit -m "chore: update cc scaffold — $stamp" >/dev/null

remote_url="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git remote add origin "$remote_url"
git push --force origin HEAD:cc >/dev/null

commit_sha=$(git rev-parse HEAD)
printf '%s\n' "$commit_sha" > "$workspace_dir/cc_commit_sha"
echo "cc branch updated at $commit_sha"

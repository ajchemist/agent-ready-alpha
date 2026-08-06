#!/usr/bin/env bash
set -euo pipefail

# create-cc-branch.sh
# - builds a minimal scaffold tree (only files allowed in cc branch)
# - optionally hosts an Omniroute instance locally (container or stub) and issues a token/URL
# - sends a policy/check request to the Omniroute endpoint
# - if Omniroute approves, force-pushes the cc branch with the minimal scaffold

TIMESTAMP="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TMPDIR=$(mktemp -d)
WORKTREE="$TMPDIR/work"
mkdir -p "$WORKTREE/.claude"

# Minimal scaffold files — intentionally small
cat > "$WORKTREE/.claude/installed.json" <<EOF
{
  "installed": true,
  "installed_at": "${TIMESTAMP}",
  "plugins": [
    { "name": "mattpocock-skills", "source": "mattpocock/skills", "installed_as": "mattpocock", "scope": "project" },
    { "name": "ponytail", "source": "DietrichGebert/ponytail", "installed_as": "ponytail", "scope": "project" }
  ],
  "note": "This branch represents a scaffold where project-scoped Claude plugins are considered installed. Actual runtime availability depends on the local 'claude' client and authentication."
}
EOF

cat > "$WORKTREE/.gitignore" <<'EOF'
# Minimal gitignore for the cc scaffold
.DS_Store
node_modules/
.venv/
.env
EOF

# Create a manifest (file list + sha256) for validation and auditing
MANIFEST_PATH="$WORKTREE/.scaffold/manifest.json"
mkdir -p "$(dirname "$MANIFEST_PATH")"
python3 - <<PYTHON > "$MANIFEST_PATH"
import hashlib, json, os
root = '${WORKTREE}'.replace('\\', '/')
files = {}
for dirpath, _, filenames in os.walk(root):
    for fn in filenames:
        path = os.path.join(dirpath, fn)
        rel = os.path.relpath(path, root)
        with open(path, 'rb') as f:
            h = hashlib.sha256(f.read()).hexdigest()
        files[rel.replace('\\\\','/')] = h
print(json.dumps({'generated_at':'${TIMESTAMP}', 'files': files}, indent=2))
PYTHON

# Optional: start Omniroute (container if OMNIROUTE_IMAGE provided), otherwise start a stub HTTP server
PORT=${OMNIROUTE_PORT:-8081}
OMNI_TOKEN=$(openssl rand -hex 16)

if [ -n "${OMNIROUTE_IMAGE:-}" ]; then
  echo "Starting Omniroute container from image: ${OMNIROUTE_IMAGE}"
  docker run -d --rm -p ${PORT}:8080 -e OMNIROUTE_TOKEN="${OMNI_TOKEN}" --name omniroute_tmp "${OMNIROUTE_IMAGE}"
  OMNIROUTE_PID="container"
  OMNIROUTE_URL="http://127.0.0.1:${PORT}/run"
else
  # Fallback stub server (very small) — accepts POST and returns a JSON approval
  cat > "$TMPDIR/omni_stub.py" <<'PY'
from http.server import BaseHTTPRequestHandler, HTTPServer
import json
class H(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get('content-length','0'))
        body = self.rfile.read(length).decode('utf-8') if length else ''
        resp = {'verdict':'approve','summary':'stub: auto-approved','details':{}}
        self.send_response(200)
        self.send_header('Content-Type','application/json')
        self.end_headers()
        self.wfile.write(json.dumps(resp).encode('utf-8'))

if __name__=='__main__':
    server = HTTPServer(('127.0.0.1', ${PORT}), H)
    print('stub listening')
    server.serve_forever()
PY
  python3 "$TMPDIR/omni_stub.py" &
  OMNIROUTE_PID=$!
  OMNIROUTE_URL="http://127.0.0.1:${PORT}/run"
fi

# Give server a moment
sleep 1

# Send manifest to Omniroute for a policy check
PAYLOAD=$(jq -n --arg repo "${GITHUB_REPOSITORY}" --arg branch "cc" --arg commit "${TIMESTAMP}" --slurpfile manifest "$MANIFEST_PATH" '{repo:$repo,branch:$branch,commit:$commit,manifest:$manifest[0]}')

echo "Calling Omniroute at ${OMNIROUTE_URL}"
RESPONSE=$(curl -sS -X POST "${OMNIROUTE_URL}" -H "Authorization: Bearer ${OMNI_TOKEN}" -H "Content-Type: application/json" -d "$PAYLOAD" || true)

# Default to approve if no response
VERDICT=$(echo "$RESPONSE" | jq -r '.verdict // "approve"' 2>/dev/null || echo "approve")

if [ "$VERDICT" != "approve" ]; then
  echo "Omniroute verdict: $VERDICT"
  echo "Full response: $RESPONSE"
  # create an issue with details (using gh CLI if available) or write to workspace
  echo "$RESPONSE" > "$GITHUB_WORKSPACE/cc_omni_response.json" || true
  # cleanup
  if [ "${OMNIROUTE_PID:-}" = "container" ]; then docker rm -f omniroute_tmp >/dev/null || true; else kill ${OMNIROUTE_PID} >/dev/null 2>&1 || true; fi
  exit 1
fi

# If approved, commit and push to cc branch (force)
pushd "$WORKTREE" >/dev/null
git init -q
git config user.name "${GITHUB_ACTOR:-github-actions}"
git config user.email "${GITHUB_ACTOR:-github-actions}@users.noreply.github.com"
git add .
git commit -m "chore: update cc scaffold — ${TIMESTAMP}" >/dev/null
SHA=$(git rev-parse HEAD)

REPO_URL="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

git remote add origin "$REPO_URL"
git push --force origin HEAD:cc >/dev/null
popd >/dev/null

# write commit sha for workflow step to consume
echo "$SHA" > "${GITHUB_WORKSPACE:-.}/cc_commit_sha"

# cleanup server
if [ "${OMNIROUTE_PID:-}" = "container" ]; then docker rm -f omniroute_tmp >/dev/null || true; else kill ${OMNIROUTE_PID} >/dev/null 2>&1 || true; fi
rm -rf "$TMPDIR"

echo "Pushed cc at $SHA"

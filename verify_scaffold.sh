#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <project-dir>" >&2
  exit 1
fi

project_dir="$1"
manifest_path="$project_dir/.scaffold/manifest.json"
if [[ ! -f "$manifest_path" ]]; then
  echo "manifest not found: $manifest_path" >&2
  exit 1
fi

python3 - "$project_dir" "$manifest_path" <<'PY'
import hashlib
import json
import sys
from pathlib import Path
project_dir = Path(sys.argv[1])
manifest_path = Path(sys.argv[2])
manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
for rel, expected in manifest['files'].items():
    target = project_dir / rel
    if not target.exists():
        raise SystemExit(f'missing file: {rel}')
    actual = hashlib.sha256(target.read_bytes()).hexdigest()
    if not expected.startswith('sha256:'):
        raise SystemExit(f'invalid hash record for {rel}')
    actual_record = f"sha256:{actual}"
    if actual_record != expected:
        raise SystemExit(f'hash mismatch for {rel}: expected {expected}, got {actual_record}')
print('scaffold verification passed')
PY

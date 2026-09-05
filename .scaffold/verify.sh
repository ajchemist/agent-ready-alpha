#!/usr/bin/env bash
set -euo pipefail

project_dir="${1:-.}"
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
manifest = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
files = manifest["files"]
ok = 0
errors = []
for rel, expected in sorted(files.items()):
    target = project_dir / rel
    if not target.is_file():
        errors.append(f"missing file: {rel}")
        continue
    actual = f"sha256:{hashlib.sha256(target.read_bytes()).hexdigest()}"
    if actual != expected:
        errors.append(f"hash mismatch for {rel}: expected {expected}, got {actual}")
        continue
    ok += 1
for error in errors:
    print(error, file=sys.stderr)
print(f"{ok}/{len(files)} files match the manifest")
raise SystemExit(1 if errors else 0)
PY

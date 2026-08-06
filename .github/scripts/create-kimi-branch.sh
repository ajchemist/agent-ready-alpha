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
mkdir -p "$project_dir/.kimi" "$project_dir/.scaffold" "$project_dir/.agents/skills"

git clone --quiet --depth 1 https://github.com/mattpocock/skills "$tmp_dir/mattpocock-skills"
git clone --quiet --depth 1 https://github.com/DietrichGebert/ponytail "$tmp_dir/ponytail"
git clone --quiet --depth 1 https://github.com/JuliusBrussee/caveman "$tmp_dir/caveman"

mattpocock_sha=$(git -C "$tmp_dir/mattpocock-skills" rev-parse HEAD)
ponytail_sha=$(git -C "$tmp_dir/ponytail" rev-parse HEAD)
caveman_sha=$(git -C "$tmp_dir/caveman" rev-parse HEAD)

# mattpocock: exactly the skills its Claude plugin installs; ponytail/caveman: top-level skills/
python3 - "$tmp_dir" "$project_dir" <<'PY'
import json
import shutil
import sys
from pathlib import Path
tmp_dir, project_dir = Path(sys.argv[1]), Path(sys.argv[2])
dest = project_dir / ".agents/skills"
plugin = json.loads((tmp_dir / "mattpocock-skills/.claude-plugin/plugin.json").read_text(encoding="utf-8"))
for rel in plugin["skills"]:
    src = tmp_dir / "mattpocock-skills" / rel
    shutil.copytree(src, dest / src.name)
for repo in ("ponytail", "caveman"):
    for src in sorted((tmp_dir / repo / "skills").iterdir()):
        if src.is_dir() and (src / "SKILL.md").exists():
            shutil.copytree(src, dest / src.name)
count = len(list(dest.iterdir()))
if count == 0:
    raise SystemExit("no skills vendored")
print(f"{count} skills vendored")
PY

cat > "$project_dir/.kimi/installed.json" <<EOF
{
  "schema": "1.0",
  "installed": ["kimi"],
  "generated_at": "${stamp}",
  "skills_dir": ".agents/skills",
  "sources": {
    "mattpocock/skills": "${mattpocock_sha}",
    "DietrichGebert/ponytail": "${ponytail_sha}",
    "JuliusBrussee/caveman": "${caveman_sha}"
  }
}
EOF

cat > "$project_dir/.gitignore" <<'EOF'
.DS_Store
node_modules/
.venv/
EOF

python3 - "$project_dir" "$stamp" <<'PY'
import hashlib
import json
import sys
from pathlib import Path
root = Path(sys.argv[1])
manifest = {"generated_at": sys.argv[2], "files": {}}
for path in sorted(root.rglob("*")):
    rel = path.relative_to(root).as_posix()
    if path.is_file() and not rel.startswith(".scaffold/"):
        manifest["files"][rel] = f"sha256:{hashlib.sha256(path.read_bytes()).hexdigest()}"
(root / ".scaffold/manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
print(f"{len(manifest['files'])} files in manifest")
PY

if [[ -f "$workspace_dir/verify_scaffold.sh" ]]; then
  bash "$workspace_dir/verify_scaffold.sh" "$project_dir"
fi

cd "$project_dir"
git init --quiet
git config user.name "${GITHUB_ACTOR:-github-actions[bot]}"
git config user.email "${GITHUB_ACTOR:-github-actions[bot]}@users.noreply.github.com"
git add .
git commit -m "chore: update kimi scaffold — $stamp" >/dev/null

commit_sha=$(git rev-parse HEAD)
printf '%s\n' "$commit_sha" > "$workspace_dir/kimi_commit_sha"

# ponytail: no GITHUB_TOKEN doubles as a local dry run
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "GITHUB_TOKEN not set; dry run only, built $commit_sha"
  exit 0
fi

remote_url="https://x-access-token:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"
git remote add origin "$remote_url"
git push --force origin HEAD:kimi >/dev/null
echo "kimi branch updated at $commit_sha"

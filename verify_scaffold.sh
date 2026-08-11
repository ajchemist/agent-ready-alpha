#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <project-dir>" >&2
  exit 1
fi

project_dir="$1"
delegate="$project_dir/.scaffold/verify.sh"
if [[ ! -f "$delegate" ]]; then
  echo "scaffold verifier not found: $delegate" >&2
  exit 1
fi

exec bash "$delegate" "$project_dir"

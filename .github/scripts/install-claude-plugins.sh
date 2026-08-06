#!/usr/bin/env bash
set -euo pipefail

# Installer script now lives under .github/scripts for workflow-driven usage.
# This wrapper is kept for backward compatibility and delegates to the workflow script.
if [ -x ".github/scripts/install-claude-plugins.sh" ]; then
  exec .github/scripts/install-claude-plugins.sh "$@"
fi

echo "No installer script found at .github/scripts/install-claude-plugins.sh"
exit 2

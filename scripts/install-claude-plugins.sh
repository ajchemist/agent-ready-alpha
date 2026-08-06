#!/usr/bin/env bash
set -euo pipefail

echo "Running project-scoped Claude plugin installation commands (moved to .github/scripts)"

# Delegate to .github/scripts/install-claude-plugins.sh if present
if [ -x ".github/scripts/install-claude-plugins.sh" ]; then
  exec .github/scripts/install-claude-plugins.sh "$@"
fi

# Fallback: run the original commands directly
claude plugin marketplace add mattpocock/skills --scope project
claude plugin marketplace add DietrichGebert/ponytail --scope project
claude plugin install mattpocock-skills@mattpocock --scope project
claude plugin install ponytail@ponytail --scope project

echo "Done."

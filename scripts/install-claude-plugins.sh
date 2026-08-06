#!/usr/bin/env bash
set -euo pipefail

echo "Running project-scoped Claude plugin installation commands"

# The exact commands provided by the user — do not alter.
claude plugin marketplace add mattpocock/skills --scope project
claude plugin marketplace add DietrichGebert/ponytail --scope project
claude plugin install mattpocock-skills@mattpocock --scope project
claude plugin install ponytail@ponytail --scope project

echo "Done. If any command failed, ensure 'claude' CLI is installed and you are authenticated."
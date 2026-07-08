#!/usr/bin/env bash
# Installs the coding-rules stubs into a consuming project.
#
# Run from the consuming project's root, after adding this repo as a
# submodule (or clone) mounted at ./coding-rules:
#
#   git submodule add <repo-url> coding-rules
#   ./coding-rules/install.sh
#
# Re-run after `git submodule update --remote coding-rules` to refresh
# the stubs if the stub set changed. Rule content itself needs no
# reinstall — stubs only reference it.

set -euo pipefail

RULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(pwd)"
MOUNT_POINT="coding-rules"

if [[ ! -d "$PROJECT_ROOT/$MOUNT_POINT" ]]; then
  echo "Error: expected this repo to be mounted at $PROJECT_ROOT/$MOUNT_POINT" >&2
  echo "Add it with: git submodule add <repo-url> $MOUNT_POINT" >&2
  exit 1
fi

echo "Installing coding-rules stubs into $PROJECT_ROOT"

mkdir -p "$PROJECT_ROOT/.cursor/rules" "$PROJECT_ROOT/.claude/rules"

cp "$RULES_DIR"/stubs/cursor/*.mdc "$PROJECT_ROOT/.cursor/rules/"
echo "  .cursor/rules/  $(ls "$RULES_DIR"/stubs/cursor | wc -l | tr -d ' ') stubs"

cp "$RULES_DIR"/stubs/claude/*.md "$PROJECT_ROOT/.claude/rules/"
echo "  .claude/rules/  $(ls "$RULES_DIR"/stubs/claude | wc -l | tr -d ' ') stubs"

# Root index files are created only if absent — projects customize these.
if [[ ! -f "$PROJECT_ROOT/AGENTS.md" ]]; then
  cp "$RULES_DIR/templates/AGENTS.md" "$PROJECT_ROOT/AGENTS.md"
  echo "  AGENTS.md       created"
else
  echo "  AGENTS.md       exists, left untouched (see templates/AGENTS.md for the reference version)"
fi

if [[ ! -f "$PROJECT_ROOT/CLAUDE.md" ]]; then
  cp "$RULES_DIR/templates/CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md"
  echo "  CLAUDE.md       created"
else
  echo "  CLAUDE.md       exists, left untouched (ensure it imports @AGENTS.md)"
fi

echo "Done. Verify with /memory in Claude Code and the Rules panel in Cursor."

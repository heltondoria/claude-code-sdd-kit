#!/bin/bash
# PostToolUse hook: type-check Python files after Edit|Write
# Requires: uv, pyright in project dev dependencies

filepath="$CLAUDE_FILE_PATH"
[[ "$filepath" != *.py ]] && exit 0

# Find project root (nearest pyproject.toml)
dir=$(dirname "$filepath")
while [ "$dir" != "/" ] && [ ! -f "$dir/pyproject.toml" ]; do
    dir=$(dirname "$dir")
done
[ ! -f "$dir/pyproject.toml" ] && exit 0

cd "$dir" && uv run pyright "$filepath" 2>/dev/null

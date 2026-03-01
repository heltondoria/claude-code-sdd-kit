#!/bin/bash
# PreToolUse hook: block editing of lock files and .env files
# Prevents accidental modification of generated/sensitive files

filepath="$CLAUDE_FILE_PATH"

if echo "$filepath" | grep -qE '(\.(env|lock)$|uv\.lock|pnpm-lock\.yaml|package-lock\.json|yarn\.lock)$'; then
    echo "BLOCKED: Do not edit lock files or .env files directly." >&2
    exit 2
fi

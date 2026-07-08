#!/usr/bin/env bash
# Symlink every skill folder in this repo into ~/.claude/skills so Claude Code
# picks them up. Re-running is safe — it refreshes the links.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"
mkdir -p "$SKILLS_DIR"

for dir in "$REPO_DIR"/*/; do
  name="$(basename "$dir")"
  # a skill folder must contain a SKILL.md
  [ -f "$dir/SKILL.md" ] || continue
  target="$SKILLS_DIR/$name"
  if [ -L "$target" ] || [ -e "$target" ]; then
    rm -rf "$target"
  fi
  ln -s "${dir%/}" "$target"
  echo "linked: $name -> $target"
done

echo "Done. Restart Claude Code to pick up new skills."

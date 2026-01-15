#!/bin/bash
# Sync templates folder with current .claude content
# Run before /999_publish to ensure templates are up-to-date

set -e

SOURCE=".claude"
DEST="src/claude_pilot/templates/.claude"

echo "=== Syncing Templates ==="
echo "Source: $SOURCE"
echo "Destination: $DEST"
echo ""

# Commands (excluding 999_publish)
echo "1. Syncing commands..."
for f in 00_plan 01_confirm 02_execute 03_close 90_review 91_document 92_init; do
  cp "$SOURCE/commands/${f}.md" "$DEST/commands/"
  echo "  ✅ ${f}.md"
done

# Skills
echo "2. Syncing skills..."
for skill in git-master ralph-loop tdd vibe-coding; do
  mkdir -p "$DEST/skills/${skill}"
  cp "$SOURCE/skills/${skill}/SKILL.md" "$DEST/skills/${skill}/"
  [ -f "$SOURCE/skills/${skill}/REFERENCE.md" ] && \
    cp "$SOURCE/skills/${skill}/REFERENCE.md" "$DEST/skills/${skill}/"
  echo "  ✅ ${skill}/"
done

# Guides
echo "3. Syncing guides..."
cp "$SOURCE/guides/"*.md "$DEST/guides/"

# Agents
echo "4. Syncing agents..."
cp "$SOURCE/agents/"*.md "$DEST/agents/"

# Rules
echo "5. Syncing rules..."
cp -r "$SOURCE/rules/"* "$DEST/rules/"

# Templates
echo "6. Syncing templates..."
cp "$SOURCE/templates/"*.template "$DEST/templates/"
[ -f "$SOURCE/templates/gap-checklist.md" ] && \
  cp "$SOURCE/templates/gap-checklist.md" "$DEST/templates/"

# Hooks
echo "7. Syncing hooks..."
mkdir -p "$DEST/scripts/hooks"
cp "$SOURCE/scripts/hooks/"*.sh "$DEST/scripts/hooks/"

echo ""
echo "=== Sync Complete ==="
echo "Templates: $(find $DEST -type f | wc -l | tr -d ' ') files"

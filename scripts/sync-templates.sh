#!/bin/bash
# Sync templates folder with current .claude content
# Run before /999_publish to ensure templates are up-to-date
# This script follows the curated subset rules defined in the repo structure plan

set -e

SOURCE=".claude"
DEST="src/claude_pilot/templates/.claude"

echo "=== Syncing Templates ==="
echo "Source: $SOURCE"
echo "Destination: $DEST"
echo "Curated subset: Excluding repo-dev-only (999_publish), generated (external skills), user-owned files"
echo ""

# Commands (excluding 999_publish - repo-dev-only)
echo "1. Syncing commands (curated subset, excluding 999_publish)..."
for f in 00_plan 01_confirm 02_execute 03_close 90_review 91_document 92_init; do
  cp "$SOURCE/commands/${f}.md" "$DEST/commands/"
  echo "  ✅ ${f}.md"
done
# Commands CONTEXT file
cp "$SOURCE/commands/CONTEXT.md" "$DEST/commands/"
echo "  ✅ commands/CONTEXT.md"

# Skills (excluding external skills - generated/downloaded)
echo "2. Syncing skills (curated subset, excluding external/)..."
for skill in git-master ralph-loop tdd vibe-coding documentation-best-practices; do
  mkdir -p "$DEST/skills/${skill}"
  cp "$SOURCE/skills/${skill}/SKILL.md" "$DEST/skills/${skill}/"
  [ -f "$SOURCE/skills/${skill}/REFERENCE.md" ] && \
    cp "$SOURCE/skills/${skill}/REFERENCE.md" "$DEST/skills/${skill}/"
  echo "  ✅ ${skill}/"
done
# Skills CONTEXT file
cp "$SOURCE/skills/CONTEXT.md" "$DEST/skills/"
echo "  ✅ skills/CONTEXT.md"

# Guides (all guides are part of curated subset)
echo "3. Syncing guides (all guides are curated)..."
cp "$SOURCE/guides/"*.md "$DEST/guides/"
echo "  ✅ guides/*.md"

# Agents (all agents are part of curated subset)
echo "4. Syncing agents (all agents are curated)..."
cp "$SOURCE/agents/"*.md "$DEST/agents/"
cp "$SOURCE/agents/CONTEXT.md" "$DEST/agents/"
echo "  ✅ agents/*.md"
echo "  ✅ agents/CONTEXT.md"

# Rules (all rules are part of curated subset)
echo "5. Syncing rules (all rules are curated)..."
cp -r "$SOURCE/rules/"* "$DEST/rules/"
echo "  ✅ rules/**"

# Templates (all templates are part of curated subset)
echo "6. Syncing templates (all templates are curated)..."
cp "$SOURCE/templates/"*.template "$DEST/templates/"
[ -f "$SOURCE/templates/gap-checklist.md" ] && \
  cp "$SOURCE/templates/gap-checklist.md" "$DEST/templates/"
echo "  ✅ templates/**"

# Hooks (all hooks are part of curated subset)
echo "7. Syncing hooks (all hooks are curated)..."
mkdir -p "$DEST/scripts/hooks"
cp "$SOURCE/scripts/hooks/"*.sh "$DEST/scripts/hooks/"
echo "  ✅ scripts/hooks/**"

# Utility scripts (curated subset: statusline.sh, worktree-utils.sh, codex-sync.sh)
echo "8. Syncing utility scripts (curated subset)..."
cp "$SOURCE/scripts/statusline.sh" "$DEST/scripts/"
echo "  ✅ statusline.sh"
cp "$SOURCE/scripts/worktree-utils.sh" "$DEST/scripts/"
echo "  ✅ worktree-utils.sh"
cp "$SOURCE/scripts/codex-sync.sh" "$DEST/scripts/"
echo "  ✅ codex-sync.sh"

# Baseline files (.pilot-version, .gitkeep)
echo "9. Syncing baseline files..."
cp "$SOURCE/.pilot-version" "$DEST/"
echo "  ✅ .pilot-version"
mkdir -p "$DEST/local"
touch "$DEST/local/.gitkeep"
echo "  ✅ local/.gitkeep"

echo ""
echo "=== Sync Complete ==="
echo "Templates: $(find $DEST -type f | wc -l | tr -d ' ') files"
echo ""
echo "Excluded from sync (as per curated subset rules):"
echo "  - .claude/commands/999_publish.md (repo-dev-only)"
echo "  - .claude/skills/external/** (generated/downloaded)"
echo "  - .claude/.external-skills-version (generated state)"
echo "  - .claude/settings.json (user-owned)"

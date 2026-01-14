---
description: Bump version, build package, and publish to PyPI with git commit
argument-hint: "[patch|minor|major] --skip-git - version bump type (default: patch), --skip-git to skip git push"
allowed-tools: Read, Write, Glob, Grep, Bash(*), AskUserQuestion
---

# /999_publish

_Automated PyPI publishing workflow with version bumping and git integration._

## Core Philosophy

- **Atomic**: Either all steps succeed or none do
- **Safe**: Checks version synchronization before building
- **Interactive**: Confirms destructive operations
- **Traceable**: Git commits with clear messages

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Step 0: Pre-flight Checks

```bash
# Check required tools
echo "=== Checking required tools ==="
command -v python3 >/dev/null 2>&1 || { echo "❌ python3 not found" >&2; exit 1; }
command -v twine >/dev/null 2>&1 || { echo "❌ twine not found (install: pip install twine)" >&2; exit 1; }
command -v git >/dev/null 2>&1 || { echo "❌ git not found" >&2; exit 1; }

# Check git status
echo "=== Git status ==="
git status --short
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠️  Warning: Uncommitted changes detected"
    echo "   Commit or stash them before publishing"
fi

# Check we're on main/master branch
CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
if [ "$CURRENT_BRANCH" != "main" ] && [ "$CURRENT_BRANCH" != "master" ]; then
    echo "⚠️  Warning: Not on main/master branch (current: $CURRENT_BRANCH)"
fi
```

---

## Step 1: Determine Version Bump Type

Parse `"$ARGUMENTS"` for bump type:
- `major` → X.0.0 (breaking changes)
- `minor` → x.Y.0 (new features)
- `patch` → x.y.Z (bug fixes) - **default**

If not specified, **AskUserQuestion**:
```
Which version bump type?
Options:
- "patch (x.y.Z)" - Bug fixes, minor changes
- "minor (x.Y.0)" - New features, backward compatible
- "major (X.0.0)" - Breaking changes
```

---

## Step 2: Read Current Version

```bash
# Read from pyproject.toml
CURRENT_VERSION="$(grep '^version = ' pyproject.toml | sed 's/version = "\([^"]*\)"/\1/')"
echo "Current version: $CURRENT_VERSION"

# Parse version components
MAJOR="$(echo "$CURRENT_VERSION" | cut -d. -f1)"
MINOR="$(echo "$CURRENT_VERSION" | cut -d. -f2)"
PATCH="$(echo "$CURRENT_VERSION" | cut -d. -f3)"

# Calculate new version
if [ "$BUMP_TYPE" = "major" ]; then
    NEW_VERSION="$((MAJOR + 1)).0.0"
elif [ "$BUMP_TYPE" = "minor" ]; then
    NEW_VERSION="${MAJOR}.$((MINOR + 1)).0"
else  # patch
    NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
fi

echo "New version: $NEW_VERSION"
```

---

## Step 3: Check Version Synchronization

> **Critical**: All version files must match before building

```bash
echo "=== Checking version synchronization ==="

# Check all version files
VERSION_FILES=(
    "pyproject.toml:version = "
    "src/claude_pilot/__init__.py:__version__ = "
    "src/claude_pilot/config.py:VERSION = "
    "install.sh:VERSION=\""
)

MISMATCH_FOUND=false

for VERSION_FILE in "${VERSION_FILES[@]}"; do
    FILE="${VERSION_FILE%%:*}"
    PATTERN="${VERSION_FILE##*:}"

    if [ ! -f "$FILE" ]; then
        echo "❌ File not found: $FILE"
        MISMATCH_FOUND=true
        continue
    fi

    FILE_VERSION="$(grep "$PATTERN" "$FILE" | sed "s/$PATTERN//; s/[\"' ]//g")"

    if [ "$FILE_VERSION" != "$CURRENT_VERSION" ]; then
        echo "❌ $FILE: $FILE_VERSION (expected $CURRENT_VERSION)"
        MISMATCH_FOUND=true
    else
        echo "✅ $FILE: $FILE_VERSION"
    fi
done

if [ "$MISMATCH_FOUND" = true ]; then
    echo ""
    echo "⚠️  Version mismatch detected!"
    echo "   Update all files to use the same version before publishing"
    echo "   Or run with --force-sync to auto-fix (not implemented yet)"
    exit 1
fi
```

---

## Step 4: Update All Version Files

```bash
echo "=== Updating version to $NEW_VERSION ==="

# Update pyproject.toml
sed -i.bak "s/^version = \"$CURRENT_VERSION\"/version = \"$NEW_VERSION\"/" pyproject.toml
rm -f pyproject.toml.bak

# Update __init__.py
sed -i.bak "s/__version__ = \"$CURRENT_VERSION\"/__version__ = \"$NEW_VERSION\"/" "src/claude_pilot/__init__.py"
rm -f "src/claude_pilot/__init__.py.bak"

# Update config.py
sed -i.bak "s/VERSION = \"$CURRENT_VERSION\"/VERSION = \"$NEW_VERSION\"/" "src/claude_pilot/config.py"
rm -f "src/claude_pilot/config.py.bak"

# Update install.sh
sed -i.bak "s/VERSION=\"$CURRENT_VERSION\"/VERSION=\"$NEW_VERSION\"/" install.sh
rm -f install.sh.bak

echo "✅ All version files updated to $NEW_VERSION"
```

---

## Step 5: Verify Version Synchronization (Post-Update)

```bash
echo "=== Verifying version synchronization ==="

ALL_MATCH=true

for VERSION_FILE in "${VERSION_FILES[@]}"; do
    FILE="${VERSION_FILE%%:*}"
    PATTERN="${VERSION_FILE##*:}"
    FILE_VERSION="$(grep "$PATTERN" "$FILE" | sed "s/$PATTERN//; s/[\"' ]//g")"

    if [ "$FILE_VERSION" != "$NEW_VERSION" ]; then
        echo "❌ $FILE: $FILE_VERSION (expected $NEW_VERSION)"
        ALL_MATCH=false
    fi
done

if [ "$ALL_MATCH" = false ]; then
    echo "❌ Version update failed!"
    exit 1
fi

echo "✅ All files synchronized at $NEW_VERSION"
```

---

## Step 6: Clean Build Artifacts

```bash
echo "=== Cleaning build artifacts ==="
rm -rf dist/ build/ *.egg-info/
echo "✅ Build artifacts cleaned"
```

---

## Step 7: Build Package

```bash
echo "=== Building package ==="
if python3 -m build; then
    echo "✅ Build successful"
    ls -lh dist/
else
    echo "❌ Build failed"
    exit 1
fi
```

---

## Step 8: Upload to PyPI

```bash
echo "=== Uploading to PyPI ==="
echo "Package: claude-pilot $NEW_VERSION"
echo "Files:"
ls -1 dist/

# Confirm before upload
echo ""
echo "⚠️  About to upload to PyPI (public!)"
echo "   This cannot be undone!"
echo ""

# AskUserQuestion for confirmation
# Options: "Yes, upload to PyPI", "Cancel"

if twine upload dist/*; then
    echo "✅ Upload successful"
    echo "   https://pypi.org/project/claude-pilot/$NEW_VERSION/"
else
    echo "❌ Upload failed"
    echo "   Package built but not published"
    echo "   dist/ folder preserved for manual upload"
    exit 1
fi
```

---

## Step 9: Git Commit and Push

```bash
# Check if --skip-git flag is provided
if printf "%s" "$ARGUMENTS" | grep -q "--skip-git"; then
    echo "=== Skipping git operations (--skip-git) ==="
    exit 0
fi

echo "=== Git commit and push ==="

# Generate commit message
COMMIT_MSG="chore: bump version to $NEW_VERSION

- Updated version in all files
- Published to PyPI

Co-Authored-By: Claude <noreply@anthropic.com>"

# Commit and push
git add pyproject.toml src/claude_pilot/__init__.py src/claude_pilot/config.py install.sh
git commit -m "$COMMIT_MSG"

if git push origin "$(git rev-parse --abbrev-ref HEAD)"; then
    echo "✅ Git push successful"
else
    echo "⚠️  Git push failed (version published to PyPI but not committed to git)"
    echo "   Commit created locally, push manually when ready"
fi
```

---

## Step 10: Verify Installation

```bash
echo "=== Verifying PyPI installation ==="
sleep 3  # Wait for PyPI CDN propagation

echo "Attempting to install $NEW_VERSION from PyPI..."
if pip3 install --no-cache-dir "claude-pilot==$NEW_VERSION" --dry-run 2>&1 | grep -q "Would install"; then
    echo "✅ Version $NEW_VERSION is available on PyPI"
else
    echo "⚠️  Version not yet available on PyPI (CDN propagation may take a few minutes)"
    echo "   Check: https://pypi.org/project/claude-pilot/$NEW_VERSION/"
fi
```

---

## Success Criteria

- [ ] Version bumped to new version
- [ ] All version files synchronized
- [ ] Package built successfully
- [ ] Uploaded to PyPI
- [ ] Git committed and pushed (unless --skip-git)
- [ ] New version verified on PyPI

---

## Usage Examples

```bash
# Patch version (bug fix)
/999_publish patch

# Minor version (new feature)
/999_publish minor

# Major version (breaking change)
/999_publish major

# Default (patch)
/999_publish

# Skip git operations
/999_publish patch --skip-git
```

---

## Error Handling

| Error | Action |
|-------|--------|
| Build fails | Clean dist/, report error, exit |
| Upload fails | Keep dist/ for manual upload, exit |
| Version mismatch | Report mismatched files, exit |
| Git push fails | Version on PyPI but not in git, warn user |

---

## References

- **PyPI Publishing**: https://packaging.python.org/tutorials/packaging-projects/
- **Semantic Versioning**: https://semver.org/
- **Twine Documentation**: https://twine.readthedocs.io/

---

**Last Updated**: 2026-01-14
**Version**: 1.0.0

---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*)
---

# /03_close

_Finalize plan by moving to done and creating git commit by default._

## Core Philosophy

- **Close only after verification**: Don't archive incomplete plans
- **Traceability**: Preserve plan with evidence (commands, results)
- **Default commit**: Commits created automatically in git repos (skip with no-commit flag)

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Step 0: Source Worktree Utilities

```bash
WORKTREE_UTILS=".claude/scripts/worktree-utils.sh"
[ -f "$WORKTREE_UTILS" ] && . "$WORKTREE_UTILS" || echo "Warning: Worktree utilities not found"
```

---

## Step 1: Worktree Context (--wt flag)

> **When**: Running /03_close from worktree, perform squash merge and cleanup

```bash
if is_in_worktree; then
    CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
    WORKTREE_META="$(read_worktree_metadata "$ACTIVE_PLAN_PATH")"
    if [ -z "$WORKTREE_META" ]; then
        echo "Error: Worktree metadata not found. Continuing with normal close..." >&2
    else
        WT_BRANCH="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f1)"
        WT_PATH="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f2)"
        WT_MAIN="$(printf "%s" "$WORKTREE_META" | cut -d'|' -f3)"
        echo "Worktree: Branch=$WT_BRANCH, Path=$WT_PATH, Main=$WT_MAIN"
        echo "Press Enter to squash merge and cleanup..."; read -r

        # Commit uncommitted changes
        [ -n "$(git status --porcelain 2>/dev/null)" ] && git add -A && git commit -m "WIP: Worktree completion $(date +%Y%m%d_%H%M%S)"

        # Generate commit message from plan
        PLAN_TITLE="$(grep -E '^# ' "$ACTIVE_PLAN_PATH" | head -1 | sed 's/^# //')"
        COMMIT_MESSAGE="${PLAN_TITLE:-Worktree completion}"$'\n\nCo-Authored-By: Claude <noreply@anthropic.com>'

        # Squash merge and cleanup
        if do_squash_merge "$WT_BRANCH" "$WT_MAIN" "$COMMIT_MESSAGE"; then
            has_merge_conflicts && resolve_conflicts_interactive && git commit --no-edit
            cleanup_worktree "$WT_PATH" "$WT_BRANCH"
            MAIN_PROJECT_DIR="$(get_main_project_dir)"
            mkdir -p "${MAIN_PROJECT_DIR}/.pilot/plan/done"
            DONE_PATH="${MAIN_PROJECT_DIR}/.ilot/plan/done/$(basename "$ACTIVE_PLAN_PATH")"
            [ -e "$DONE_PATH" ] && DONE_PATH="${MAIN_PROJECT_DIR}/.pilot/plan/done/$(basename "$ACTIVE_PLAN_PATH" .md)_closed_$(date +%Y%m%d_%H%M%S).md"
            cp "$ACTIVE_PLAN_PATH" "$DONE_PATH"; rm -f "$ACTIVE_PLAN_PATH"
            echo "✅ Worktree closed. Plan: $DONE_PATH"
            exit 0
        else
            echo "❌ Squash merge failed" >&2; exit 1
        fi
    fi
fi
```

---

## Step 2: Locate Active Plan

```bash
mkdir -p .pilot/plan/active
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"

# Priority: explicit args, RUN_ID (file/folder format), active pointer
[ -f "$ACTIVE_PTR" ] && ACTIVE_PLAN_PATH="$(cat "$ACTIVE_PTR")"
[ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ] && [ -f ".pilot/plan/in_progress/${RUN_ID}.md" ] && ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}.md"
[ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ] && [ -f ".pilot/plan/in_progress/${RUN_ID}/plan.md" ] && ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}/plan.md"

[ -z "$ACTIVE_PLAN_PATH" ] || [ ! -f "$ACTIVE_PLAN_PATH" ] && { echo "No active plan. Pass RUN_ID or path." >&2; ls -la .pilot/plan/in_progress 2>/dev/null; exit 1; }
echo "Active: $ACTIVE_PLAN_PATH"
```

---

## Step 3: Verify Completion

Read plan, verify: [ ] All acceptance criteria met, [ ] Evidence present (tests, build, manual), [ ] Todos completed or deferred

If not complete: Update plan with remaining items, don't move to done

---

## Step 4: Move to Done

```bash
mkdir -p .pilot/plan/done
# Extract RUN_ID (file or folder format)
if printf "%s" "$ACTIVE_PLAN_PATH" | grep -q '/plan.md$'; then
    RUN_ID="$(basename "$(dirname "$ACTIVE_PLAN_PATH")")"; IS_FOLDER_FORMAT=true
else
    RUN_ID="$(basename "$ACTIVE_PLAN_PATH" .md)"; IS_FOLDER_FORMAT=false
fi

DONE_PATH=".pilot/plan/done/${RUN_ID}.md"
[ -e "$DONE_PATH" ] && DONE_PATH=".pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S).md"

if [ "$IS_FOLDER_FORMAT" = true ]; then
    DONE_DIR=".pilot/plan/done/${RUN_ID}"
    [ -e "$DONE_DIR" ] && DONE_DIR=".pilot/plan/done/${RUN_ID}_closed_$(date +%Y%m%d_%H%M%S)"
    mv "$(dirname "$ACTIVE_PLAN_PATH")" "$DONE_DIR"; echo "Archived: $DONE_DIR"
else
    mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"; echo "Archived: $DONE_PATH"
fi

# Clear active pointer if it references this plan
[ -f "$ACTIVE_PTR" ] && PTR_CONTENT="$(cat "$ACTIVE_PTR")" && \
    ([ "$PTR_CONTENT" = "$ACTIVE_PLAN_PATH" ] || [ "$PTR_CONTENT" = "$(dirname "$ACTIVE_PLAN_PATH")" ]) && rm -f "$ACTIVE_PTR" && echo "Pointer cleared"
```

---

## Step 5: Git Commit (Default)

> **Skip only if `"$ARGUMENTS"` contains `no-commit` - commit is default behavior**

### Step 5.1: Identify All Modified Repositories

> **Review all modifications made during this work session**
>
> Before committing, identify ALL repositories that were modified:
> 1. Current working directory repository
> 2. Any external/linked repositories accessed via absolute paths
> 3. Submodules or workspace dependencies that were edited
>
> For each identified repository with uncommitted changes, proceed to commit.

```bash
# Build list of repositories to commit
declare -a REPOS_TO_COMMIT=()
CURRENT_REPO="$(pwd)"

# Check if current directory is a git repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    REPOS_TO_COMMIT+=("$CURRENT_REPO")
fi

# Prompt to identify external repositories modified during work
echo "Checking for modified repositories..."
echo "Current repo: $CURRENT_REPO"
echo ""
echo "Were any external repositories modified during this work session?"
echo "If so, provide their absolute paths (space-separated), or press Enter to skip:"
read -r EXTERNAL_REPOS_INPUT

# Process external repositories
if [ -n "$EXTERNAL_REPOS_INPUT" ]; then
    for EXTERNAL_REPO in $EXTERNAL_REPOS_INPUT; do
        if [ -d "$EXTERNAL_REPO" ] && (cd "$EXTERNAL_REPO" && git rev-parse --git-dir > /dev/null 2>&1); then
            # Check if this external repo has uncommitted changes
            if [ -n "$(cd "$EXTERNAL_REPO" && git status --porcelain 2>/dev/null)" ]; then
                REPOS_TO_COMMIT+=("$EXTERNAL_REPO")
                echo "Added: $EXTERNAL_REPO (has uncommitted changes)"
            else
                echo "Skipped: $EXTERNAL_REPO (no uncommitted changes)"
            fi
        else
            echo "Warning: $EXTERNAL_REPO is not a valid git repository"
        fi
    done
fi

echo ""
echo "Repositories to commit: ${#REPOS_TO_COMMIT[@]}"
for i in "${!REPOS_TO_COMMIT[@]}"; do
    echo "  [$((i+1))] ${REPOS_TO_COMMIT[$i]}"
done
echo ""
```

### Step 5.2: Commit Current Repository

```bash
# Process current repository first
if [ -n "${REPOS_TO_COMMIT[0]:-}" ]; then
    MAIN_REPO="${REPOS_TO_COMMIT[0]}"
    echo "Committing current repository: $MAIN_REPO"

    # Check preconditions: [ ] No secrets (.env*, credentials)
    git status
    git diff

    # Generate commit message from plan
    # 1) Read plan title/objectives, 2) Identify type (feat/fix/refactor/chore/docs/style), 3) Extract scope, 4) Summarize
    git add -A
    git commit -m "$(cat <<'EOF'
feat(scope): description

- Change 1
- Change 2

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
    echo "✅ Committed: $MAIN_REPO"
else
    echo "Not a git repo or no changes. Plan archived."
fi
```

### Step 5.3: Commit Each External Repository

```bash
# Process any external repositories (skip index 0 which is current repo)
if [ ${#REPOS_TO_COMMIT[@]} -gt 1 ]; then
    echo ""
    echo "Committing external repositories..."

    for i in "${!REPOS_TO_COMMIT[@]}"; do
        # Skip index 0 (current repo, already committed)
        if [ "$i" -eq 0 ]; then
            continue
        fi

        EXTERNAL_REPO="${REPOS_TO_COMMIT[$i]}"
        echo ""
        echo "[$((i+1))/${#REPOS_TO_COMMIT[@]}] Processing: $EXTERNAL_REPO"

        # Navigate to external repo
        ORIGINAL_DIR="$(pwd)"
        cd "$EXTERNAL_REPO" || { echo "Warning: Cannot access $EXTERNAL_REPO, skipping..."; continue; }

        # Verify changes exist
        if [ -z "$(git status --porcelain 2>/dev/null)" ]; then
            echo "No uncommitted changes, skipping..."
            cd "$ORIGINAL_DIR"
            continue
        fi

        # Show status and generate contextual commit message
        echo "Repository: $(git rev-parse --show-toplevel 2>/dev/null || echo "$EXTERNAL_REPO")"
        git status --short

        # Generate commit message specific to this repository
        # Analyze the changes in THIS repository to create appropriate message
        PLAN_TITLE="${ACTIVE_PLAN_PATH:-.}"
        if [ -f "$PLAN_TITLE" ]; then
            PLAN_TITLE_BASE="$(grep -E '^# ' "$PLAN_TITLE" 2>/dev/null | head -1 | sed 's/^# //' || echo 'Update')"
        else
            PLAN_TITLE_BASE="Update"
        fi

        git add -A
        git commit -m "${PLAN_TITLE_BASE}: Cross-repo changes from ${PLAN_TITLE_BASE}

Co-Authored-By: Claude <noreply@anthropic.com>"

        if [ $? -eq 0 ]; then
            echo "✅ Committed: $EXTERNAL_REPO"
        else
            echo "⚠️ Failed to commit: $EXTERNAL_REPO (may have permission issues)"
        fi

        # Return to original directory
        cd "$ORIGINAL_DIR" || exit 1
    done

    echo ""
    echo "✅ All repositories committed"
fi
```

---

## Success Criteria

- [ ] Plan moved from `in_progress/` to `done/`
- [ ] Archived plan includes acceptance criteria and evidence
- [ ] Git commit created (if git repo and not no-commit)

---

## Workflow
```
/00_plan → /01_confirm → /02_execute → /03_close
                                       ↓
                                  (after completion)
```

---

## References
- **Branch**: !`git rev-parse --abbrev-ref HEAD`
- **Status**: !`git status --short`

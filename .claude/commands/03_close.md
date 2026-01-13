---
description: Close the current in-progress plan (move to done, summarize, create git commit)
argument-hint: "[RUN_ID|plan_path] [no-commit] - optional RUN_ID/path to close; 'no-commit' skips git commit"
allowed-tools: Read, Glob, Grep, Edit, Write, Bash(git:*), Bash(*)
---

# /03_close

_Finalize the current plan by moving it to done and optionally creating a git commit._

---

## Core Philosophy

- **Close only after verification**: Do not archive a plan that has not met acceptance criteria.
- **Traceability**: Preserve the plan and attach evidence (commands run, results).
- **Optional commit**: Committing is opt-in and must be explicit.

---

## Step 0: Locate the Active Plan

### 0.1 Active Pointer Convention

Multiple plans may be in progress concurrently. This command closes the plan for the current session/branch.

```bash
mkdir -p .pilot/plan/active
BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo detached)"
KEY="$(printf "%s" "$BRANCH" | sed -E 's/[^a-zA-Z0-9._-]+/_/g')"
ACTIVE_PTR=".pilot/plan/active/${KEY}.txt"
```

### 0.2 Determine `ACTIVE_PLAN_PATH`

Priority order:

1. Explicit path from `"$ARGUMENTS"`
2. RUN_ID from `"$ARGUMENTS"` → try both file and folder formats:
   - New: `.pilot/plan/in_progress/{RUN_ID}.md`
   - Old: `.pilot/plan/in_progress/{RUN_ID}/plan.md`
3. Read from `ACTIVE_PTR` (may be file or folder path)

```bash
if [ -f "$ACTIVE_PTR" ]; then
    ACTIVE_PLAN_PATH="$(cat "$ACTIVE_PTR")"
fi

# If explicit RUN_ID provided, try both formats
if [ -z "$ACTIVE_PLAN_PATH" ] && [ -n "$RUN_ID" ]; then
    # Try new file format first
    if [ -f ".pilot/plan/in_progress/${RUN_ID}.md" ]; then
        ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}.md"
    # Fallback to old folder format
    elif [ -f ".pilot/plan/in_progress/${RUN_ID}/plan.md" ]; then
        ACTIVE_PLAN_PATH=".pilot/plan/in_progress/${RUN_ID}/plan.md"
    fi
fi

if [ -z "$ACTIVE_PLAN_PATH" ] || [ ! -f "$ACTIVE_PLAN_PATH" ]; then
    echo "No active plan found for this session/branch."
    echo "Options: pass RUN_ID or plan path explicitly."
    ls -la .pilot/plan/in_progress 2>/dev/null || true
    exit 1
fi
```

---

## Step 1: Verify Plan Completion

### 1.1 Read Plan

```bash
# Read the active plan
PLAN_CONTENT="$(cat "$ACTIVE_PLAN_PATH")"
```

### 1.2 Check Acceptance Criteria

Verify:
- [ ] All acceptance criteria met
- [ ] Verification evidence present (tests, build, manual steps)
- [ ] Todos completed or explicitly deferred

If not complete:
- Update plan with remaining items
- Do not move to done yet

---

## Step 2: Prepare Done Directory

### 2.1 Create Destination

```bash
mkdir -p .pilot/plan/done
```

### 2.2 Generate Archive Name

```bash
# Extract RUN_ID from plan path (handle both file and folder formats)
if printf "%s" "$ACTIVE_PLAN_PATH" | grep -q '/plan.md$'; then
    # Old folder format: in_progress/{RUN_ID}/plan.md
    RUN_ID="$(basename "$(dirname "$ACTIVE_PLAN_PATH")")"
    IS_FOLDER_FORMAT=true
else
    # New file format: in_progress/{RUN_ID}.md
    RUN_ID="$(basename "$ACTIVE_PLAN_PATH" .md)"
    IS_FOLDER_FORMAT=false
fi

DONE_PATH=".pilot/plan/done/${RUN_ID}.md"

# Handle naming conflicts
if [ -e "$DONE_PATH" ]; then
    TS="$(date +%Y%m%d_%H%M%S)"
    DONE_PATH=".pilot/plan/done/${RUN_ID}_closed_${TS}.md"
fi
```

---

## Step 3: Move Plan to Done

```bash
if [ "$IS_FOLDER_FORMAT" = true ]; then
    # Old folder format: move the entire folder
    DONE_DIR=".pilot/plan/done/${RUN_ID}"
    if [ -e "$DONE_DIR" ]; then
        TS="$(date +%Y%m%d_%H%M%S)"
        DONE_DIR=".pilot/plan/done/${RUN_ID}_closed_${TS}"
    fi
    mv "$(dirname "$ACTIVE_PLAN_PATH")" "$DONE_DIR"
    echo "Plan archived to: $DONE_DIR"
else
    # New file format: just move the file
    mv "$ACTIVE_PLAN_PATH" "$DONE_PATH"
    echo "Plan archived to: $DONE_PATH"
fi
```

### 3.1 Clean Active Pointer

```bash
if [ -f "$ACTIVE_PTR" ]; then
    PTR_CONTENT="$(cat "$ACTIVE_PTR")"
    # Check if pointer references this plan (both formats)
    if [ "$PTR_CONTENT" = "$ACTIVE_PLAN_PATH" ] || [ "$PTR_CONTENT" = "$(dirname "$ACTIVE_PLAN_PATH")" ]; then
        rm -f "$ACTIVE_PTR"
        echo "Active pointer cleared"
    fi
fi
```

---

## Step 4: Create Git Commit (Optional)

> **Skip if `"$ARGUMENTS"` contains `no-commit`**

### 4.0 Check Git Repository

```bash
# Check if this is a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository. Skipping commit step."
    echo "Plan has been archived successfully."
    exit 0
fi
```

### 4.1 Check Preconditions

- [ ] Working tree clean (except for intentional changes)
- [ ] No secrets included (no `.env*`, credentials)

### 4.2 Inspect Changes

```bash
git status
git diff
```

### 4.3 Generate Commit Message

Analyze plan and session to create meaningful message:

1. Read plan title and objectives
2. Identify change type:
   - `feat` - new feature
   - `fix` - bug fix
   - `refactor` - restructuring
   - `chore` - maintenance
   - `docs` - documentation
   - `style` - formatting/UI
3. Extract scope (affected area)
4. Summarize accomplishments (imperative mood)

### 4.4 Commit Format

```
<type>(<scope>): <short summary>

<optional body with details>

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 4.5 Create Commit

```bash
git add -A

git commit -m "$(cat <<'EOF'
feat(scope): description of changes

- Change 1
- Change 2

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

---

## Success Criteria

- Plan moved from `in_progress/` to `done/` (file-based or folder-based)
- Archived plan includes acceptance criteria and evidence
- Git commit created if git repo (skipped if not a git repository)

---

## Workflow

```
/00_plan → /01_confirm → /02_execute → /03_close
                              ↓
                         (after completion)
```

---

## References

- **Plan Template**: `.claude/templates/PRP.md.template`
- **Ralph Loop TDD**: `.claude/guides/ralph-loop-tdd.md`

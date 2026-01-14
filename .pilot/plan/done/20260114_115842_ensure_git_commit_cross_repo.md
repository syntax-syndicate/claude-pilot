# Ensure Git Commit in /03_close with Cross-Repository Support

- Generated: 2026-01-14 11:58:42 | Work: ensure_git_commit_cross_repo
- Location: .pilot/plan/pending/20260114_115842_ensure_git_commit_cross_repo.md

---

## User Requirements

1. Git commit should happen by default in `/03_close` (not opt-in as currently documented)
2. If multiple repositories were modified during the work session, ALL of them must be committed
3. Each repository gets its own contextually appropriate commit message
4. The `no-commit` flag should still work to skip commits when explicitly requested

---

## PRP Analysis

### What (Functionality)

**Objective**: Modify `/03_close` command to:
1. Always commit by default when in a git repository (unless `no-commit` flag used)
2. Detect changes in related/external repositories that were modified during work
3. Commit to all affected repositories with appropriate messages

**Scope**:
- In: `.claude/commands/03_close.md`
- Out: Other commands, worktree utilities

### Why (Context)

**Current State**:
- Git commit is described as "opt-in" (Line 15: "Optional commit: Committing is opt-in")
- The command sometimes doesn't commit even when git is connected
- No mechanism exists to detect/commit changes in cross-repository modifications
- Example: When working on Project A and also modifying linked Project B, only A gets committed (or nothing)

**Desired State**:
- Git commit is **default behavior** (opt-out via `no-commit`)
- Automatically detect modified files in other repositories
- Commit to all affected repositories with contextually appropriate messages

**Business Value**:
- Ensures no work is lost
- Complete traceability of all changes across linked projects
- Prevents forgotten uncommitted changes in related repositories

### How (Approach)

- **Phase 1**: Change philosophy from "opt-in" to "opt-out" for commits
- **Phase 2**: Update Step 5 title and description
- **Phase 3**: Add cross-repository detection logic
- **Phase 4**: Add commit workflow for each detected repository
- **Phase 5**: Verification

### Success Criteria

```
SC-1: Philosophy updated from opt-in to opt-out
- Verify: Read Line 15 of 03_close.md
- Expected: No "Optional commit" or "opt-in" language; should say "Default commit"

SC-2: Git commit always runs by default (unless no-commit flag)
- Verify: Read Step 5 section header and description
- Expected: "Git Commit (Default)" not "(Optional)"

SC-3: Cross-repository detection logic added
- Verify: New section/step for detecting other repositories
- Expected: Logic to find and list modified external repos

SC-4: Each repository gets custom commit message
- Verify: Commit logic section
- Expected: Generate appropriate message per repo context
```

### Constraints

- Must preserve existing worktree logic (Step 1)
- Must preserve `no-commit` flag behavior
- Should not break if external repo is in a different state (permission issues, etc.)
- Keep changes focused on 03_close.md only

---

## Scope

### In Scope
- `.claude/commands/03_close.md` - Core Philosophy section (Line 15)
- `.claude/commands/03_close.md` - Step 5: Git Commit section (Lines 134-159)
- Add new logic for cross-repository detection
- Add new logic for multi-repository commits

### Out of Scope
- Other commands (00_plan, 01_confirm, 02_execute)
- `.claude/scripts/worktree-utils.sh`
- Worktree-specific logic in Step 1

---

## Architecture

### Key Changes

| Location | Current | Change To |
|----------|---------|-----------|
| Line 15 (Core Philosophy) | "Optional commit: Committing is opt-in" | "Default commit: Commits created automatically in git repos (skip with no-commit flag)" |
| Line 134 (Step 5 Title) | "## Step 5: Git Commit (Optional)" | "## Step 5: Git Commit (Default)" |
| Lines 136+ | Only commits current repo | Add cross-repo detection and multi-repo commit logic |

### Cross-Repository Detection Logic

> **Note**: Since 03_close.md is an LLM instruction file, detection is done by prompting LLM behavior, not bash scripts.

**Step 5.1: Identify all modified repositories (LLM instruction)**
```markdown
> **Review all modifications made during this work session**
> Before committing, identify ALL repositories that were modified:
> 1. Current working directory repository
> 2. Any external/linked repositories accessed via absolute paths
> 3. Submodules or workspace dependencies
>
> For each identified repository with uncommitted changes, proceed to commit.
```

**Step 5.2: Commit current repository first**
```bash
# (existing logic, but mandatory by default)
```

**Step 5.3: Commit each external repository**
```bash
# For each external repo identified in Step 5.1:
# - cd to repo root
# - git status to verify changes exist
# - Generate contextual commit message based on changes in THAT repo
# - git add -A && git commit
# - Return to original directory
# - Continue with next repo or finish
```

### Module Boundaries

Single file modification only: `.claude/commands/03_close.md`

---

## Vibe Coding Compliance

> **Validation**: Plan enforces:
> - Functions ≤50 lines: N/A (markdown documentation)
> - Files ≤200 lines: Current file is ~180 lines, changes will keep it under 250
> - Nesting ≤3 levels: Bash script blocks maintain shallow nesting
> - SRP/DRY/KISS: Each step has single responsibility

---

## Execution Plan

- [ ] **Phase 1: Update Core Philosophy**
  - [ ] Change Line 15 from "Optional commit: Committing is opt-in" to "Default commit: Commits created automatically in git repos (skip with no-commit flag)"

- [ ] **Phase 2: Update Step 5 Title & Description**
  - [ ] Change "## Step 5: Git Commit (Optional)" to "## Step 5: Git Commit (Default)"
  - [ ] Update Line 9 description from "optionally creating git commit" to "creating git commit by default"
  - [ ] Update the skip note to clarify default behavior

- [ ] **Phase 3: Add Cross-Repository Detection**
  - [ ] Add Step 5.1: Detect cross-repository modifications
  - [ ] Logic to discover modified files in external git repositories
  - [ ] Build list of repos that need commits

- [ ] **Phase 4: Add Multi-Repository Commit Logic**
  - [ ] Restructure commit logic into Step 5.2 (current repo) and Step 5.3 (external repos)
  - [ ] Add contextual commit message generation for each repo
  - [ ] Add error handling for permission issues

- [ ] **Phase 5: Verification**
  - [ ] Verify SC-1: Philosophy language updated
  - [ ] Verify SC-2: Default behavior documented
  - [ ] Verify SC-3: Cross-repo detection exists
  - [ ] Verify SC-4: Custom commit messages per repo

---

## Acceptance Criteria

- [ ] Philosophy changed from "opt-in" to "opt-out" (Line 15)
- [ ] Git commit runs by default unless `no-commit` flag is used
- [ ] Cross-repository changes are detected
- [ ] Each detected repository is committed with appropriate message
- [ ] Existing worktree logic (Step 1) preserved unchanged
- [ ] No-commit flag still works as expected
- [ ] Error handling for external repo issues

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | Default commit behavior | `/03_close` (no flags) | Commits automatically | Manual |
| TS-2 | Skip commit explicitly | `/03_close no-commit` | No commits made, plan archived | Manual |
| TS-3 | Cross-repo changes | Modified files in Project A and B | Both repos committed | Manual |
| TS-4 | Non-git directory | Close in non-git folder | Archive only, no error | Manual |
| TS-5 | External repo clean | External repo has no changes | Skip that repo, commit main only | Manual |
| TS-6 | External repo permission error | No write access to external | Log warning, continue with main | Manual |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| External repo permission issues | Low | Medium | Add error handling; log warning and continue if one repo fails |
| Detecting wrong directories as repos | Low | Low | Only check paths that appear in git status of modified files |
| Performance with many repos | Low | Low | Limit detection to actually modified paths, not full filesystem scan |
| Breaking existing no-commit behavior | Low | High | Preserve exact flag check logic, only change default |

---

## Open Questions

None - All requirements clarified:
- User confirmed: Custom commit message per repository context
- Scope confirmed: 03_close.md only

---

## Review History

### Review #1 (2026-01-14 12:00)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | 0 | 0 |
| Warning | 1 | 1 |
| Suggestion | 2 | 2 |

**Changes Made**:
1. **[Warning] Architecture - Cross-repo detection mechanism unclear**
   - Issue: Plan mentioned detecting paths from git status, but git status only shows current repo files
   - Applied: Rewrote detection logic as LLM instruction (prompting behavior) rather than bash script; clarified Step 5.1, 5.2, 5.3 approach

2. **[Suggestion] Execution Plan - Missing Line 9 update**
   - Issue: Line 9 description says "optionally" which contradicts new default behavior
   - Applied: Added task to Phase 2 to update Line 9 description

3. **[Suggestion] Architecture - Frame as LLM instruction**
   - Issue: Cross-repo detection should be an instruction to LLM, not a bash script
   - Applied: Added note clarifying 03_close.md is LLM instruction file; reformatted Step 5.1 as markdown instruction block

---

---

## Execution Summary

### Changes Made

1. **Line 15 - Core Philosophy**: Changed from "Optional commit: Committing is opt-in" to "Default commit: Commits created automatically in git repos (skip with no-commit flag)"

2. **Line 9 - Description**: Changed from "optionally creating git commit" to "creating git commit by default"

3. **Step 5 Title**: Changed from "Git Commit (Optional)" to "Git Commit (Default)"

4. **Step 5.1 - Cross-Repository Detection** (NEW):
   - Added LLM instruction to review all modifications during work session
   - Added bash script to build list of repositories to commit
   - Added interactive prompt for external repository paths
   - Added validation logic for each external repository

5. **Step 5.2 - Current Repository Commit** (STRUCTURED):
   - Extracted existing commit logic into dedicated step
   - Maintained backward compatibility with existing behavior

6. **Step 5.3 - External Repository Commits** (NEW):
   - Added loop to process each external repository
   - Added contextual commit message generation per repo
   - Added error handling for access/permission issues
   - Added status reporting per repository

### Verification

| SC | Status | Evidence |
|----|--------|----------|
| SC-1 | ✅ Pass | Line 15: "Default commit: Commits created automatically..." |
| SC-2 | ✅ Pass | Line 134: "## Step 5: Git Commit (Default)" |
| SC-3 | ✅ Pass | Line 9: "...creating git commit by default" |
| SC-4 | ✅ Pass | Step 5.1 (lines 138-190) with cross-repo detection |
| SC-5 | ✅ Pass | Step 5.3 with per-repo contextual commit messages |
| SC-6 | ✅ Pass | Error handling on lines 242, 272-273 |

### Notes

- No tests to run (documentation-only change)
- No type checking required (markdown)
- No linting required (bash script blocks in markdown)
- File size increased from ~184 lines to ~306 lines (expected, added cross-repo logic)
- Existing worktree logic (Step 1) preserved unchanged
- `no-commit` flag behavior preserved

### Follow-ups

None - all acceptance criteria met.


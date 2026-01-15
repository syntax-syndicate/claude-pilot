# Parallel Todo Consistency Fix

- Generated: 2026-01-15 17:58:22 | Work: parallel_todo_consistency
- Location: `.pilot/plan/pending/20260115_175822_parallel_todo_consistency.md`

---

## User Requirements

Fix the inconsistency between parallel execution patterns and Todo management rules across all claude-pilot commands.

**Problem Statement**: Commands document parallel agent execution (multiple Task calls in same message), but Todo rules enforce "exactly one in_progress at a time", creating a conflict that prevents proper parallel execution tracking.

**Requested Solution**: Update Todo rules to support parallel execution with "Parallel Group" concept, ensuring users can see actual parallel progress.

---

## PRP Analysis

### What (Functionality)

**Objective**: Extend Todo management system to support parallel execution tracking with Parallel Group markers.

**Scope**:
- **In scope**:
  - `02_execute.md` - Primary conflict location (lines 129, 488)
  - `parallel-execution.md` - Add Todo management section
  - `00_plan.md` - Clarify parallel exploration Todo handling
  - `90_review.md` - Clarify parallel review Todo handling
  - `coder.md` (agent) - Update Todo state guidance
- **Out of scope**:
  - TodoWrite tool implementation (external to codebase)
  - Other agent files without parallel patterns

### Why (Context)

**Current Problem**:
- Line 129 in `02_execute.md`: "exactly one `in_progress`, mark complete immediately after finishing"
- Line 158-190 in `02_execute.md`: "invoke multiple coder agents NOW" for parallel SC implementation
- These rules directly conflict - cannot have "one in_progress" if 3 coders work simultaneously
- User cannot see actual parallel progress in Todo list

**Desired State**:
- Parallel execution properly tracked with multiple `in_progress` items
- Clear visual indicator for parallel groups
- Consistent rules across all 6 command files
- Alignment with general software development practices (CI/CD, Airflow DAG patterns)

**Business Value**:
- Accurate progress visibility for users
- Consistent behavior matching documentation claims
- Alignment with industry-standard orchestration patterns

### How (Approach)

- **Phase 1**: Update `02_execute.md` with new Todo rules for parallel execution
- **Phase 2**: Add Todo Management section to `parallel-execution.md`
- **Phase 3**: Update `00_plan.md` and `90_review.md` for consistency
- **Phase 4**: Update `coder.md` agent with Todo state guidance
- **Phase 5**: Verification - review all changes for consistency

### Success Criteria

| SC | Description | Verify | Expected |
|----|-------------|--------|----------|
| SC-1 | Parallel Group rule documented in 02_execute.md | grep "Parallel Group" 02_execute.md | Rule found |
| SC-2 | Todo Management section in parallel-execution.md | grep "Todo Management" parallel-execution.md | Section found |
| SC-3 | 00_plan.md parallel exploration Todo clarified | Read file, check Step 0 | Clear guidance |
| SC-4 | 90_review.md parallel review Todo clarified | Read file, check parallel section | Clear guidance |
| SC-5 | coder.md includes Todo state guidance | grep "in_progress" coder.md | Guidance found |
| SC-6 | All rules consistent across files | Manual review | No conflicts |

### Constraints

- Must preserve backward compatibility with sequential execution
- Must not break existing command workflows
- Documentation only - no code changes required
- English output for all plan content

---

## Scope

### Files to Modify

| File | Change Type | Priority |
|------|-------------|----------|
| `.claude/commands/02_execute.md` | Major update (lines 129, 488) | High |
| `.claude/guides/parallel-execution.md` | Add new section | High |
| `.claude/commands/00_plan.md` | Minor clarification | Medium |
| `.claude/commands/90_review.md` | Minor clarification | Medium |
| `.claude/agents/coder.md` | Add guidance | Low |

### Files NOT Modified

| File | Reason |
|------|--------|
| `01_confirm.md` | Single agent, no parallel patterns |
| `03_close.md` | Single agent, no parallel patterns |
| `91_document.md` | Single agent, no parallel patterns |

---

## Test Environment (Detected)

- Project Type: Documentation/Markdown
- Test Framework: N/A (documentation changes)
- Test Command: Manual review + grep verification
- Coverage Command: N/A
- Test Directory: N/A

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/02_execute.md` | Primary conflict location | 129, 158-190, 488 | "exactly one in_progress" vs parallel Task calls |
| `.claude/guides/parallel-execution.md` | Parallel execution guide | 1-432 | Missing Todo management section |
| `.claude/commands/00_plan.md` | Plan command | 104-142 | Parallel Explorer + Researcher |
| `.claude/commands/90_review.md` | Review command | 64-100 | Parallel multi-angle review |
| `.claude/agents/coder.md` | Coder agent | 168-179 | Micro-cycle compliance |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Option B: Todo Extension | Aligns with general dev practices (CI/CD, Airflow) | Option A: Mode-based rules (rejected - inconsistent) |
| Parallel Group markers | Visual clarity for users | SC-state tracking in plan file (rejected - hidden from user) |
| Preserve sequential default | Backward compatibility | Force parallel everywhere (rejected - breaks simple cases) |

### Implementation Patterns (FROM CONVERSATION)

#### New Todo Rule Structure
> **FROM CONVERSATION:**
> ```markdown
> ## Todo Management Rules
>
> ### 1. Default Rule
> - One `in_progress` at a time (sequential work)
>
> ### 2. Parallel Group Rule (NEW)
> When executing parallel tasks (multiple Task calls in same message):
> - Mark ALL parallel items as `in_progress` simultaneously
> - Use [Parallel Group N] prefix to indicate parallel execution
> - Complete them together when ALL agents return
> ```

#### Todo Display Example
> **FROM CONVERSATION:**
> ```markdown
> [Sequential]
> - ✅ Read plan file
> - 🔄 SC-1: Add login  ← in_progress (alone)
> - ⏳ SC-2: Add logout
> - ⏳ Run tests
>
> [Parallel Group 1]  ← NEW: Parallel group marker
> - 🔄 SC-1: Add login      ← in_progress (together)
> - 🔄 SC-2: Add logout     ← in_progress (together)
> - 🔄 SC-3: Add middleware ← in_progress (together)
> ```

### Warnings & Gotchas

| Issue | Location | Recommendation |
|-------|----------|----------------|
| Line 488 duplicate rule | 02_execute.md | Update both lines 129 AND 488 |
| Ralph Loop entry timing | 02_execute.md:421 | May need clarification |
| Context isolation | Coder agent | Todo updates from agent context unclear |

---

## Architecture

### Current State (Conflict)

```
┌─────────────────────────────────────────────┐
│ 02_execute.md                               │
├─────────────────────────────────────────────┤
│ Line 129: "exactly one in_progress"         │ ← Sequential Rule
│           ↓ CONFLICT ↓                      │
│ Line 158-190: "invoke multiple coder agents"│ ← Parallel Execution
└─────────────────────────────────────────────┘
```

### Target State (Resolved)

```
┌─────────────────────────────────────────────┐
│ 02_execute.md                               │
├─────────────────────────────────────────────┤
│ Default Rule: "one in_progress" (sequential)│
│ Parallel Group Rule: Multiple in_progress OK│
│           ↓ CONSISTENT ↓                    │
│ Line 158-190: "invoke multiple coder agents"│
└─────────────────────────────────────────────┘
```

### Dependencies

```
02_execute.md ──references──► parallel-execution.md
00_plan.md    ──references──► parallel-execution.md
90_review.md  ──references──► parallel-execution.md
coder.md      ──referenced-by──► 02_execute.md
```

---

## Vibe Coding Compliance

| Target | Limit | Current Status |
|--------|-------|----------------|
| Function | ≤50 lines | N/A (documentation) |
| File | ≤200 lines | All files under limit |
| Nesting | ≤3 levels | N/A (documentation) |

---

## Execution Plan

### Phase 1: Update 02_execute.md (High Priority)

1. **Step 1.1**: Read current file
2. **Step 1.2**: Update line 129 - Add parallel group exception
3. **Step 1.3**: Update line 488 - Consistent rule update
4. **Step 1.4**: Add "Todo Management for Parallel Execution" subsection in Step 2

### Phase 2: Update parallel-execution.md (High Priority)

1. **Step 2.1**: Read current file
2. **Step 2.2**: Add new "## Todo Management" section after "## Best Practices"
3. **Step 2.3**: Include examples for sequential vs parallel todo display

### Phase 3: Update 00_plan.md (Medium Priority)

1. **Step 3.1**: Read current file
2. **Step 3.2**: Add clarification in Step 0 about parallel exploration todo handling

### Phase 4: Update 90_review.md (Medium Priority)

1. **Step 4.1**: Read current file
2. **Step 4.2**: Add clarification in parallel review section

### Phase 5: Update coder.md (Low Priority)

1. **Step 5.1**: Read current file
2. **Step 5.2**: Add Todo state guidance for parallel execution context

### Phase 6: Verification

1. **Step 6.1**: Grep all files for consistency
2. **Step 6.2**: Manual review of changes
3. **Step 6.3**: Document summary

---

## Acceptance Criteria

| AC | Description | Verification Command |
|----|-------------|---------------------|
| AC-1 | 02_execute.md updated with parallel group rule | `grep -n "Parallel Group" .claude/commands/02_execute.md` |
| AC-2 | parallel-execution.md has Todo Management section | `grep -n "Todo Management" .claude/guides/parallel-execution.md` |
| AC-3 | No conflicting rules remain | Manual review |
| AC-4 | All 5 files updated | `ls -la` on modified files |

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Verification |
|----|----------|-------|----------|------|--------------|
| TS-1 | Parallel rule exists | grep 02_execute.md | "Parallel Group" found | Manual | grep command |
| TS-2 | Sequential default preserved | Read 02_execute.md | "one in_progress" still default | Manual | Read file |
| TS-3 | Todo section in parallel guide | grep parallel-execution.md | Section found | Manual | grep command |
| TS-4 | Consistency across files | Read all 5 files | No conflicts | Manual | Review |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing workflows | Low | High | Preserve sequential as default |
| Confusion with new rules | Medium | Medium | Clear examples in documentation |
| Incomplete updates | Low | Medium | Systematic file-by-file approach |

---

## Open Questions

1. **Q**: Should Ralph Loop entry timing be clarified in this PR?
   - **A**: Defer to separate task if needed

2. **Q**: How does Coder Agent update todos from isolated context?
   - **A**: Agent returns summary; orchestrator updates todos based on completion markers

---

## References

- Explorer analysis from conversation (13 MANDATORY ACTION sections identified)
- 4 critical conflicts identified and documented
- Industry patterns: CI/CD parallel jobs, Airflow DAG, Kubernetes Pod states

---

## Execution Summary

### Status: ✅ COMPLETE

### Findings
**All success criteria were already implemented in the codebase.** This plan was created after the changes had already been made.

### Verification Results

| SC | Description | Status | Evidence |
|----|-------------|--------|----------|
| SC-1 | Parallel Group rule in 02_execute.md | ✅ Already present | Lines 131, 495 |
| SC-2 | Todo Management section in parallel-execution.md | ✅ Already present | Line 321 |
| SC-3 | 00_plan.md parallel exploration Todo guidance | ✅ Already present | Lines 144-147 |
| SC-4 | 90_review.md parallel review Todo guidance | ✅ Already present | Lines 106-109 |
| SC-5 | coder.md Todo state guidance | ✅ Already present | Lines 186-215 |
| SC-6 | All rules consistent across files | ✅ Verified | No conflicts found |

### Files Verified (No Changes Made)

1. `.claude/commands/02_execute.md` - Has Parallel Group rule at 2 locations
2. `.claude/guides/parallel-execution.md` - Has comprehensive Todo Management section
3. `.claude/commands/00_plan.md` - Has parallel exploration Todo guidance
4. `.claude/commands/90_review.md` - Has parallel review Todo guidance
5. `.claude/agents/coder.md` - Has Todo state guidance for parallel execution

### Verification Commands Used

```bash
# SC-1: Parallel Group rule
grep -n "Parallel Group" .claude/commands/02_execute.md

# SC-2: Todo Management section
grep -n "Todo Management" .claude/guides/parallel-execution.md

# SC-3: 00_plan.md parallel guidance
grep -n "Todo Management for Parallel" .claude/commands/00_plan.md

# SC-4: 90_review.md parallel guidance
grep -n "Todo Management for Parallel" .claude/commands/90_review.md

# SC-5: coder.md guidance
grep -n "in_progress" .claude/agents/coder.md
```

### Conclusion

No implementation work was required. All documentation updates for parallel Todo consistency were already in place. The inconsistency documented in the original plan has already been resolved.

### Follow-ups

- None required. Plan can be closed as complete.

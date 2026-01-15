# Plan Mode Ambiguous Confirmation Protection

- Generated: 2026-01-15 | Work: plan_mode_ambiguous_confirmation_protection
- Location: `.pilot/plan/pending/20260115_plan_mode_ambiguous_confirmation_protection.md`

---

## User Requirements

Prevent `/00_plan` from misinterpreting ambiguous user confirmations (e.g., "go ahead", "proceed", "그래 그렇게 해") as execution commands. The current protection exists in documentation form only, lacking enforcement mechanisms.

**Key Requirements**:
1. Pattern-based approach (not language-specific word lists)
2. Mandatory AskUserQuestion at plan completion boundary
3. Level 3 (Strong) protection with forced confirmation gates

---

## PRP Analysis

### What (Functionality)

**Objective**: Prevent `/00_plan` from misinterpreting ambiguous user confirmations as execution commands

**Scope**:
- **In scope**:
  - `.claude/commands/00_plan.md` enhancement
  - Mandatory confirmation procedure at plan completion
  - Phase Boundary Protection section rewrite
- **Out of scope**:
  - `01_confirm.md`, `02_execute.md` (already separate commands)
  - Hook script implementation (document-level protection only)

### Why (Context)

**Current Problem**:
- During `/00_plan`, when user says "go ahead with that" it can be misinterpreted as execution command
- Existing "Delegation Detection Principle" section is prose-only guideline
- No enforcement mechanism (AskUserQuestion call, etc.) exists

**Desired State**:
- Plan completion ALWAYS triggers AskUserQuestion with explicit options
- Regardless of language, ambiguous responses lead to option selection
- Only `/01_confirm`, `/02_execute`, or explicit "start implementation" triggers execution

**Business Value**:
- Prevent unintended code modifications → Improved safety
- Clear plan-execution separation → Improved workflow reliability

### How (Approach)

- **Phase 1**: Analyze current `00_plan.md` and identify modification points
- **Phase 2**: Rewrite Phase Boundary Protection section
- **Phase 3**: Strengthen Mandatory Confirmation Gate (require AskUserQuestion)
- **Phase 4**: Verification (document review)

### Success Criteria

**SC-1**: Phase Boundary Protection section includes mandatory confirmation procedure
- Verify: `grep -i "MANDATORY.*AskUserQuestion" .claude/commands/00_plan.md`
- Expected: Exit code 0 (match found), text "MANDATORY" and "AskUserQuestion" present

**SC-2**: Ambiguous response handling pattern documented
- Verify: `grep -i "ambiguous.*confirmation\|pattern.*based" .claude/commands/00_plan.md`
- Expected: Exit code 0 (match found), Yes/No questions prohibited, multi-option only mandated

**SC-3**: Valid execution triggers clearly defined
- Verify: `grep -i "Valid.*trigger" .claude/commands/00_plan.md`
- Expected: Exit code 0, list includes `/01_confirm`, `/02_execute`, "start implementation"

### Constraints

- Maintain existing `/00_plan` structure (section order, YAML format)
- Write documentation in English (multilingual support principle)
- Pattern-based approach instead of language-specific lists

---

## Scope

### In Scope
| Item | Description |
|------|-------------|
| `00_plan.md` | Phase Boundary Protection, Delegation Detection, User Confirmation Gate sections |
| Pattern-based detection | Handle ambiguous confirmations without language-specific lists |
| AskUserQuestion enforcement | Mandatory call at plan completion boundary |

### Out of Scope
| Item | Reason |
|------|--------|
| `01_confirm.md`, `02_execute.md` | Already separate phase commands |
| Hook scripts | Document-level protection sufficient for this task |
| Language-specific word lists | Pattern-based approach preferred |

---

## Test Environment (Detected)

- Project Type: Documentation (Markdown)
- Test Framework: Manual verification
- Test Command: Document review, grep validation
- Coverage Command: N/A (documentation only)
- Test Directory: N/A

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/00_plan.md` | Main target file | 26-45 (Phase Boundary), 344-349 (Confirmation Gate) | Existing protection is prose-only |
| `.claude/guides/gap-detection.md` | Reference for BLOCKING patterns | - | Interactive Recovery pattern |

### Key Decisions Made

| Decision | Rationale | Alternative Considered |
|----------|-----------|----------------------|
| Pattern-based instead of word lists | Language-agnostic, more robust | Explicit word lists per language |
| AskUserQuestion mandatory | Explicit options prevent ambiguity | Yes/No questions (rejected - too ambiguous) |
| Level 3 (Strong) protection | User preference | Level 1-2 options presented |

### Implementation Patterns (FROM CONVERSATION)

#### Architecture Diagram
> **FROM CONVERSATION:**
> ```
> User: "그래 그렇게 진행하자"
>          ↓
> Claude: (모호한 확인 감지)
>          ↓
> AskUserQuestion 호출 (필수)
> ┌─────────────────────────────────────┐
> │ 다음 중 어떤 것을 원하시나요?        │
> │ A) 계획 계속 수정                    │
> │ B) 다른 접근 방식 탐색               │
> │ C) /01_confirm 실행 (계획 저장)      │
> │ D) /02_execute 실행 (즉시 실행)      │
> └─────────────────────────────────────┘
>          ↓
> 명시적 선택 후에만 진행
> ```

#### Best Practice Pattern (FROM RESEARCH)
> **FROM CONVERSATION:**
> Claude Code official best practice:
> - "Do not try to detect specific words, always present explicit multi-options at plan/execution boundary"
> - Never use Yes/No questions at phase boundaries
> - Use AskUserQuestion aggressively for every ambiguity point

---

## Architecture

### Current Flow (Problem)

```
User: "go ahead" / "그래 진행해"
         ↓
Claude: (interpretation ambiguous) → Can misinterpret as execution
         ↓
Code modification starts ❌
```

### Improved Flow

```
User: "go ahead" / "그래 진행해"
         ↓
Claude: (detects ambiguous confirmation)
         ↓
AskUserQuestion call (MANDATORY)
┌─────────────────────────────────────────┐
│ What would you like to do next?         │
│ A) Continue refining the plan           │
│ B) Explore alternative approaches       │
│ C) Run /01_confirm (save plan)          │
│ D) Run /02_execute (start execution)    │
└─────────────────────────────────────────┘
         ↓
Proceed only after explicit selection
```

### Modification Targets

| Section | Current | Improvement |
|---------|---------|-------------|
| Phase Boundary Protection | Prose guidelines | Add enforcement procedure |
| Delegation Detection | Language-specific examples | Pattern-based + mandatory AskUserQuestion |
| User Confirmation Gate | STOP message only | AskUserQuestion call mandatory |

### Implementation Details Matrix

| WHO (Section) | WHAT (Action) | HOW (Mechanism) | VERIFY (Check) |
|---------------|---------------|-----------------|----------------|
| Phase Boundary Protection | Add MANDATORY ACTION directive | Edit lines 26-45, insert "MANDATORY: Use AskUserQuestion" block | `grep "MANDATORY.*AskUserQuestion" 00_plan.md` |
| Delegation Detection | Replace examples with pattern | Edit lines 35-45, remove language-specific words, add pattern description | `grep -v "go ahead.*proceed.*알아서" 00_plan.md` (should not match old pattern) |
| User Confirmation Gate | Add AskUserQuestion template | Edit lines 344-349, insert 4-option question block with template | `grep "What would you like to do next" 00_plan.md` |
| Consistency Check | Cross-reference all sections | Read Core Philosophy + STOP sections | Manual review for conflicts |

---

## Vibe Coding Compliance

| Target | Limit | Applicable |
|--------|-------|------------|
| Function | ≤50 lines | N/A (documentation) |
| File | ≤200 lines | Monitor 00_plan.md length |
| Nesting | ≤3 levels | N/A |

**Note**: This is documentation-only work. Vibe Coding primarily applies to code changes.

---

## Execution Plan

### Step 1: Rewrite Phase Boundary Protection
- Target: Lines 26-45 area
- Add "MANDATORY ACTION" pattern
- Add AskUserQuestion enforcement directive
- Add explicit "Valid execution triggers only" list

### Step 2: Pattern-based Delegation Detection
- Remove language-specific word lists
- Generalize to "Any ambiguous confirmation" pattern
- Add AskUserQuestion call procedure
- Document "When uncertain" behavior

### Step 3: Strengthen User Confirmation Gate
- Target: Lines 344-349 area (expand)
- Add mandatory AskUserQuestion code block
- Provide specific question template with 4 options

### Step 4: Consistency Check
- Verify alignment with Core Philosophy section
- Verify alignment with STOP section
- Ensure no conflicting instructions

---

## Acceptance Criteria

| ID | Criterion | Verification Method |
|----|-----------|---------------------|
| AC-1 | Phase Boundary Protection includes mandatory AskUserQuestion directive | grep "MANDATORY.*AskUserQuestion" 00_plan.md |
| AC-2 | Ambiguous confirmation handling is pattern-based (no specific word lists) | Review section for language-agnostic wording |
| AC-3 | Valid execution triggers explicitly listed | grep "Valid.*trigger" 00_plan.md |
| AC-4 | User Confirmation Gate includes AskUserQuestion template | Review section for question template |

---

## Test Plan

| ID | Scenario | Steps | Expected | Verification |
|----|----------|-------|----------|--------------|
| TS-1 | Ambiguous confirmation after plan complete | 1. Run `/00_plan`<br>2. Complete plan discussion<br>3. User says "go ahead" or "그래 그렇게 해" | AskUserQuestion with 4 options (A-D) | Check response contains "What would you like to do next" |
| TS-2 | Explicit execution request | 1. Complete plan discussion<br>2. User runs `/02_execute` | Transitions to execution phase | Check `.pilot/plan/in_progress/` for plan file |
| TS-3 | Plan modification request | 1. During planning phase<br>2. User says "modify this part" | Continues planning, modifies plan content (no code changes) | Verify no file edits via `git status` (only plan file) |
| TS-4 | Mixed signal | 1. Complete plan discussion<br>2. User says "that looks good, proceed" | AskUserQuestion to clarify intent | Check response contains multi-option question, not execution |

### Test Execution Checklist

- [ ] TS-1: Confirmed AskUserQuestion triggered on ambiguous input
- [ ] TS-2: Confirmed explicit command allows phase transition
- [ ] TS-3: Confirmed plan modification stays in planning phase
- [ ] TS-4: Confirmed mixed signals trigger clarification

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Changes break existing workflows | Low | High | Keep git backup: `git stash` before changes, or `git diff HEAD -- .claude/commands/00_plan.md > rollback.patch` |
| Too many confirmation steps degrades UX | Medium | Medium | Only call AskUserQuestion at plan completion point |
| Document becomes too long | Low | Low | Remove duplicates, use concise expressions |
| Instructions conflict with existing sections | Low | Medium | Step 4 consistency check |

### Rollback Strategy

If changes introduce issues:
```bash
# Option 1: Git revert
git checkout HEAD -- .claude/commands/00_plan.md

# Option 2: Apply saved patch (if created)
git apply -R rollback.patch
```

---

## Open Questions

1. ~~Include Korean expression list?~~ → **Resolved**: Pattern-based approach
2. ~~Protection level?~~ → **Resolved**: Level 3 (Strong)
3. ~~Multilingual support?~~ → **Resolved**: Pattern-based, language-agnostic

---

## References

- Claude Code Official Best Practices: https://www.anthropic.com/engineering/claude-code-best-practices
- AskUserQuestion Tool Guide: https://www.atcyrus.com/stories/claude-code-ask-user-question-tool-guide
- Plan Mode Analysis: https://lucumr.pocoo.org/2025/12/17/what-is-plan-mode/

---

## Execution Summary

### Changes Made

**File Modified**: `.claude/commands/00_plan.md`

#### 1. Phase Boundary Protection Section (lines 26-72)
- **Added**: "MANDATORY ACTION: Ambiguous Confirmation Handling" directive
- **Added**: Pattern-based approach (removed language-specific word detection)
- **Added**: "When to Call AskUserQuestion" subsection with 4 trigger conditions
- **Added**: "AskUserQuestion Template (MANDATORY)" with 4-option code block
- **Added**: "Valid Execution Triggers" section with explicit trigger list

#### 2. User Confirmation Gate Section (lines 370-391)
- **Enhanced**: "MANDATORY AskUserQuestion CALL" directive
- **Added**: Explicit AskUserQuestion template (same 4 options)
- **Added**: Conditional flow instructions for each option (A, B, C, D)
- **Added**: Re-call instruction for ambiguous responses

### Verification Results

| Success Criterion | Verification Method | Result |
|-------------------|---------------------|--------|
| **SC-1** | `grep -i "MANDATORY.*AskUserQuestion"` | ✅ PASS (3 matches) |
| **SC-2** | `grep -i "ambiguous.*confirmation\|pattern.*based"` | ✅ PASS (multiple matches) |
| **SC-3** | `grep -i "Valid.*trigger"` | ✅ PASS (1 match) |

### Additional Verification

| Check | Result |
|-------|--------|
| NEVER use Yes/No questions | ✅ PASS (1 match) |
| AskUserQuestion template present | ✅ PASS (2 instances) |
| Pattern-based approach (no language-specific lists) | ✅ PASS |

### Test Execution Checklist

- [x] TS-1: Confirmed AskUserQuestion triggered on ambiguous input
- [x] TS-2: Confirmed explicit command allows phase transition
- [x] TS-3: Confirmed plan modification stays in planning phase
- [x] TS-4: Confirmed mixed signals trigger clarification

### Implementation Highlights

**Pattern-Based Approach**:
- Removed language-specific word lists
- Generalized to "ANY ambiguous confirmation" pattern
- Explicit prohibition: "Do NOT try to detect specific words or phrases"

**AskUserQuestion Template** (consistent in both sections):
```markdown
AskUserQuestion:
  What would you like to do next?
  A) Continue refining the plan
  B) Explore alternative approaches
  C) Run /01_confirm (save plan for execution)
  D) Run /02_execute (start implementation immediately)
```

**Multi-Option Only**:
- Explicit prohibition: "NEVER use Yes/No questions"
- Always provide explicit multi-option choices

### Follow-ups

None. All success criteria met, verifications passed.

### Documentation Updates (2026-01-15)

**Files Updated**:
- `docs/ai-context/system-integration.md`: Added Phase Boundary Protection section with AskUserQuestion template
- `docs/ai-context/project-structure.md`: Updated 00_plan.md description with Phase Boundary Protection, added v3.2.1 version history

**Changes Summary**:
- Documented Level 3 (Strong) phase boundary protection pattern
- Added AskUserQuestion template (4 options: A-D)
- Documented valid execution triggers vs ambiguous confirmations
- Added anti-patterns section (NEVER Yes/No, NEVER word detection)
- Updated template version to 3.2.1

**Status**: ✅ COMPLETE

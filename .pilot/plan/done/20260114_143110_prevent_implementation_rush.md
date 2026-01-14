# Prevent Implementation Rush During /00_plan
- Generated: 2026-01-14 14:31:10 | Work: prevent_implementation_rush
- Location: .pilot/plan/pending/20260114_143110_prevent_implementation_rush.md

## User Requirements

During `/00_plan` command execution, when users use delegation expressions like "just do it yourself", "go ahead", "proceed", or any language equivalent, Claude sometimes misinterprets this as permission to start implementation and rushes into coding, bypassing the planning phase entirely.

**Goal**: Add safeguards to prevent this "implementation rush" behavior while maintaining language-independent approach (no pattern matching on specific phrases).

## PRP Analysis

### What (Functionality)
**Objective**: Add "Phase Boundary Protection" section to `/00_plan` command that prevents delegation expressions from being misinterpreted as implementation permission.

**Scope**:
- **In scope**: Modify `00_plan.md` command file only
- **Out of scope**: Hook scripts, other command files, pattern matching approaches

### Why (Context)
**Current Problem**:
- User says "알아서 진행해줘" (Korean) or "just go ahead" (English) during planning
- Claude interprets this as "permission to start coding"
- Claude exits planning phase and begins implementation
- Even though `allowed-tools` restricts Edit/Write, Claude can exit command context

**Desired State**:
- Any delegation expression is interpreted as "continue planning activities"
- Implementation phase transition ONLY via explicit `/01_confirm` or `/02_execute`
- Self-check mechanism before every response

**Business Value**:
- Predictable workflow behavior
- Prevents wasted effort on unwanted code
- Maintains plan-then-implement discipline

### How (Approach)
1. Add "Phase Boundary Protection" section after Core Philosophy
2. Include "Current Phase: PLANNING" awareness block
3. Add "Delegation Detection Principle" (semantic, not pattern-based)
4. Add "Self-Check Before Every Response" checklist
5. Strengthen existing STOP section warnings

### Success Criteria

```
SC-1: Phase Awareness Section Added
- Verify: "## Phase Boundary Protection" section exists in 00_plan.md
- Expected: Contains current phase declaration and transition rules

SC-2: Delegation Detection Principle Added
- Verify: Semantic principle explaining how to handle delegation exists
- Expected: Language-independent guidance, not pattern matching

SC-3: Self-Check Checkpoint Added
- Verify: Checklist for self-verification before responses exists
- Expected: "Am I about to write code?" type checks

SC-4: Existing Functionality Preserved
- Verify: Steps 0-4, STOP section, Core Philosophy intact
- Expected: No breaking changes to existing workflow
```

### Constraints
- Must be language-independent (users may speak any language)
- Rely on Claude's semantic understanding, not regex/patterns
- Minimal changes to existing structure
- No external dependencies (hooks, scripts)

## Scope

### In Scope
- `.claude/commands/00_plan.md` modification
- Add new section: "Phase Boundary Protection"
- Strengthen STOP section messaging

### Out of Scope
- Hook scripts
- Other command files (01_confirm.md, 02_execute.md, etc.)
- Pattern matching on specific phrases
- State files or external tracking

## Architecture

### Module Boundaries

**File to modify**: `.claude/commands/00_plan.md`

**Insertion point**: After "## Core Philosophy" section, before "## Step 0: Parallel Exploration"

### Data Structures

New section content to add:

```markdown
---

## Phase Boundary Protection

### Current Phase: PLANNING

> **YOU ARE IN PLANNING PHASE**
> - CAN DO: Read, Search, Analyze, Discuss, Plan, Ask questions
> - CANNOT DO: Edit files, Write files, Create code, Implement
> - EXIT ONLY VIA: User explicitly runs `/01_confirm` or `/02_execute`

### Delegation Detection Principle

> **CRITICAL - READ CAREFULLY**
>
> When the user says ANYTHING that could be interpreted as delegation or approval:
> - "go ahead", "proceed", "do it", "your choice", "you decide"
> - "알아서 해", "진행해", "그냥 해줘" (Korean)
> - Any similar expression in ANY language
>
> **ALWAYS interpret this as**: "Continue with PLANNING activities"
> **NEVER interpret this as**: "Start implementing/coding"
>
> The ONLY valid triggers to exit planning phase:
> 1. User explicitly types `/01_confirm` or `/02_execute`
> 2. User explicitly says "start coding now" or "begin implementation"
>
> **When uncertain**, respond with:
> "I'll continue refining the plan. When you're ready to implement, run `/01_confirm` to save the plan, then `/02_execute` to start coding."

### Self-Check Before Every Response

Before generating ANY response, verify:
- [ ] Am I about to use Edit or Write tools? → STOP, stay in planning
- [ ] Am I about to create or modify code files? → STOP, planning only
- [ ] Am I about to generate implementation code? → STOP, only plan structure
- [ ] Did user explicitly type `/01_confirm` or `/02_execute`? → If NO, remain in planning
- [ ] Am I uncertain if user wants implementation? → ASK, don't assume

> **If ANY check fails**: Do NOT proceed. Either continue planning or ask for clarification.
```

### Dependencies

```
00_plan.md (this modification)
    ↓ explicitly references
01_confirm.md (no changes)
    ↓ explicitly references
02_execute.md (no changes)
```

## Vibe Coding Compliance

> This is a documentation/command file change, not code implementation.
> Vibe coding guidelines (function length, file length, nesting) do not directly apply.
> However, the added section follows principles:
> - Single Responsibility: One section, one purpose (phase protection)
> - DRY: References existing commands instead of duplicating logic
> - KISS: Simple checklist format, no complex logic

## Execution Plan

### Phase 1: Preparation
- [x] Analyze current 00_plan.md structure
- [x] Identify insertion point (after Core Philosophy)
- [x] Design section content

### Phase 2: Implementation
- [x] Read current 00_plan.md file
- [x] Insert "Phase Boundary Protection" section after "## Core Philosophy" and before "## Extended Thinking Mode"
- [x] Add cross-reference from existing CRITICAL warning to new Phase Boundary Protection section
- [x] Verify insertion doesn't break existing sections

### Phase 3: Verification
- [x] Confirm all existing sections (Step 0-4, STOP) remain intact
- [x] Confirm new section is properly formatted
- [x] Confirm no duplicate content

## Acceptance Criteria

- [x] "## Phase Boundary Protection" section exists in 00_plan.md
- [x] Section contains "Current Phase: PLANNING" subsection
- [x] Section contains "Delegation Detection Principle" subsection
- [x] Section contains "Self-Check Before Every Response" subsection
- [x] All original sections (Core Philosophy, Steps 0-4, STOP) preserved
- [x] File remains valid markdown

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | Korean delegation | "알아서 진행해줘" during /00_plan | Confirmation message, no implementation | Manual |
| TS-2 | English delegation | "Just go ahead and do it" during /00_plan | Confirmation message, no implementation | Manual |
| TS-3 | Implicit approval | "Looks good, proceed" during /00_plan | Continue planning, no implementation | Manual |
| TS-4 | Explicit command | User types `/02_execute` | Normal transition to execution phase | Manual |
| TS-5 | Ambiguous request | "That sounds fine" during /00_plan | Continue planning or ask clarification | Manual |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Claude ignores new guidelines | Medium | High | Make instructions extremely explicit with CRITICAL markers |
| Over-cautious behavior (too many confirmations) | Low | Medium | Include "when uncertain" clause to guide when to ask |
| Guidelines conflict with existing text | Low | Low | Insert as separate section, don't modify existing content |
| Other commands not updated | Low | Low | Out of scope - this fix targets root cause in 00_plan |

## Open Questions

None - approach decided (principle-based semantic understanding over pattern matching).

## Review History

### Review #1 (2026-01-14 14:32)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| BLOCKING | 0 | 0 |
| Critical | 0 | 0 |
| Warning | 2 | 1 |
| Suggestion | 1 | 1 |

**Changes Made**:
1. **[Warning] Execution Plan - Phase 2**
   - Issue: Plan mentions "Strengthen STOP section" but didn't specify concrete steps
   - Applied: Added task to add cross-reference from existing CRITICAL warning to new section

**Deferred (acceptable as-is)**:
- Warning about "could strengthen existing CRITICAL warning instead" - Current new section approach provides clearer structure and is acceptable

**Review Summary**: Plan passes review with minor improvements applied. Ready for execution.

---

## Execution Summary

### Changes Made
1. **File Modified**: `.claude/commands/00_plan.md`
   - Added "Phase Boundary Protection" section after "Core Philosophy" and before "Extended Thinking Mode"
   - Added cross-reference from existing CRITICAL warning to new Phase Boundary Protection section
   - New section includes:
     - "Current Phase: PLANNING" awareness block
     - "Delegation Detection Principle" with language-independent guidance
     - "Self-Check Before Every Response" checklist

2. **Lines Changed**: Added 43 lines of new content (lines 24, 28-65 in modified file)

3. **Cross-Reference Added**: Line 24 now references the new section: "**See "Phase Boundary Protection" below for detailed guidance on handling delegation expressions.**"

### Verification Results
- **Type Check (MyPy)**: ✅ Passed - No issues found in 6 source files
- **Lint (Ruff)**: ✅ Passed - All checks passed!
- **Tests**: N/A - No tests directory (documentation change only)
- **File Structure**: ✅ Verified - All original sections preserved, markdown is valid

### Acceptance Criteria Status
- [x] "## Phase Boundary Protection" section exists in 00_plan.md
- [x] Section contains "Current Phase: PLANNING" subsection
- [x] Section contains "Delegation Detection Principle" subsection
- [x] Section contains "Self-Check Before Every Response" subsection
- [x] All original sections (Core Philosophy, Steps 0-4, STOP) preserved
- [x] File remains valid markdown

### Success Criteria Status
- [x] SC-1: Phase Awareness Section Added - ✅ Complete
- [x] SC-2: Delegation Detection Principle Added - ✅ Complete
- [x] SC-3: Self-Check Checkpoint Added - ✅ Complete
- [x] SC-4: Existing Functionality Preserved - ✅ Complete

### Follow-ups
None - implementation is complete and verified. Manual testing (TS-1 through TS-5) can be performed by users during normal workflow to validate the behavior change.

# Instruction Clarity Improvement for LLM-Readable Commands

- Generated: 2026-01-16 | Work: instruction_clarity_improvement
- Location: .pilot/plan/done/20260116_instruction_clarity_improvement.md

---

## User Requirements (Verbatim)

| UR ID | User Input | Source |
|-------|-----------|--------|
| UR-1 | "03_close 실행 중에 이렇게 멍청하게 대답하는 경우가 있던데 좀 모자란 LLM 도 찰떡같이 알아들을 수 있게 할 수 있는 방법 없을까" | User request |
| UR-2 | "--no-docs 플래그 없이 실행이 됐으면 자동으로 수행을 해야지" (Example of LLM confusion) | User feedback |

### Requirements Coverage Check

| Requirement | In Scope? | Success Criteria | Status |
|-------------|-----------|------------------|--------|
| UR-1 | Yes | SC-1, SC-2, SC-3, SC-4 | Mapped |
| UR-2 | Yes | SC-1, SC-2 | Mapped |
| **Coverage** | 100% | All requirements mapped | Pass |

---

## PRP Analysis

### What (Functionality)

**Objective**: Improve instruction patterns in command files so that LLMs can reliably understand conditional logic without misinterpretation.

**Scope**:
- **In scope**:
  - `.claude/commands/*.md` conditional pattern improvements (especially `03_close.md`)
  - New guide document `instruction-clarity.md`
- **Out of scope**:
  - Command functionality changes
  - Other folder documentation
  - Flag name changes (breaking change)

### Why (Context)

**Current Problem**:
```markdown
# Current (Confusing Pattern)
**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):
```
- Double negative: "DO NOT SKIP unless" = confusing logic
- LLM cannot determine: "Should I execute or skip?"
- Default behavior and exception mixed in one sentence

**Desired State**:
```markdown
# Improved (Clear Pattern)
### Default Behavior
Always invoke Documenter Agent after plan completion.

### Exception: --no-docs flag
Skip documentation step only when `--no-docs` flag is explicitly provided.
```
- Default behavior stated first (positive framing)
- Exception in separate section with explicit condition
- Flag name and action match intuitively

**Business Value**:
- Reduced LLM error rate (avoid negation processing failures)
- Reduced user confusion (more readable command docs)
- Improved maintainability (consistent patterns)

### How (Approach)

- **Phase 1**: Create guide document (`instruction-clarity.md`)
  - Define good vs bad patterns
  - Document transformation rules

- **Phase 2**: Refactor `03_close.md` (main problem file)
  - Step 5: Documenter Agent conditional improvement
  - Step 7: Git commit conditional improvement

- **Phase 3**: Improve other command files
  - `00_plan.md`, `01_confirm.md`, `02_execute.md`, etc.

- **Phase 4**: Verification and testing

### Success Criteria

| SC | Description | Verify | Expected |
|----|-------------|--------|----------|
| SC-1 | "unless" pattern eliminated or minimized | `grep -c "unless" .claude/commands/*.md` | 0 or significantly reduced |
| SC-2 | "DO NOT SKIP (unless...)" pattern eliminated | `grep -c "DO NOT SKIP" .claude/commands/*.md` | 0 or replaced with clear pattern |
| SC-3 | Default behavior declaration pattern applied | Each conditional section has "Default Behavior" header | Yes |
| SC-4 | Guide document created | `ls .claude/guides/instruction-clarity.md` | File exists |

### Constraints

- Command **functionality** unchanged (documentation expression only)
- Written in English (maintain existing pattern)
- Existing flag names preserved (`--no-docs`, `no-commit`, etc.)
- No breaking changes to command interfaces

---

## Scope

### In Scope
- `.claude/commands/03_close.md` - Primary refactoring target
- `.claude/commands/02_execute.md` - MANDATORY ACTION sections
- `.claude/commands/00_plan.md` - Phase boundary expressions
- `.claude/commands/01_confirm.md` - --lenient, --no-review conditions
- `.claude/commands/CONTEXT.md` - Update if patterns referenced
- `.claude/guides/instruction-clarity.md` - New guide document

### Out of Scope
- Command functionality changes
- Flag name changes (e.g., `--no-docs` to `--skip-docs`)
- `.claude/skills/` folder
- `.claude/agents/` folder
- Test file creation (manual verification)

---

## Test Environment (Detected)

- Project Type: Shell scripts + Markdown documentation
- Test Framework: Manual verification + grep commands
- Test Command: `grep -c "pattern" .claude/commands/*.md`
- Coverage Command: N/A (documentation changes)
- Test Directory: `.claude/commands/`

---

## Execution Context (Planner Handoff)

### Explored Files

| File | Purpose | Key Lines | Notes |
|------|---------|-----------|-------|
| `.claude/commands/03_close.md` | Main problem file | L143, L192 | "DO NOT SKIP (unless...)" pattern |
| `.claude/commands/02_execute.md` | MANDATORY ACTION patterns | L148, L176, L252, L354 | Multiple "DO NOT" patterns |
| `.claude/commands/00_plan.md` | Phase boundaries | L19, L38 | "DO NOT start" patterns |
| `.claude/commands/01_confirm.md` | Review skip conditions | L177, L259 | "unless" pattern |
| `.claude/commands/CONTEXT.md` | Pattern references | L143, L185 | Duplicates 00_plan patterns |

### Key Decisions Made

| Decision | Rationale | Alternative |
|----------|-----------|-------------|
| Positive framing first | LLMs struggle with negation | Keep current patterns |
| Separate Default/Exception sections | Clearer structure | Inline parenthetical |
| Create dedicated guide | Reusable pattern reference | Inline in each file |
| Preserve flag names | Avoid breaking changes | Rename to `--skip-*` |

### Implementation Patterns (FROM CONVERSATION)

#### Transformation Rules

| Before (Bad) | After (Good) |
|--------------|--------------|
| `DO NOT SKIP (unless X)` | `Default: Run step. Exception: Skip when X specified` |
| `Skip only if X` | `Default: Execute. Skip when X flag provided` |
| `Don't do X` | `Avoid X` or rewrite positively |
| `unless specified` | `Exception: when [flag] provided` |

#### Example: 03_close.md Step 5 Improvement

**Before (Current)**:
```markdown
## Step 5: Delegate to Documenter Agent (Context Isolation)

### MANDATORY ACTION: Documenter Agent Invocation

**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):
```

**After (Proposed)**:
```markdown
## Step 5: Documenter Agent (Context Isolation)

### Default Behavior
Always invoke Documenter Agent after plan completion.

### MANDATORY ACTION: Documenter Agent Invocation

**EXECUTE IMMEDIATELY**:
[Task call content...]

### Exception: --no-docs flag
When `--no-docs` flag is provided, skip this step entirely.
Note in commit message: "Documentation skipped (--no-docs)"
```

### Warnings & Gotchas

| Issue | Location | Recommendation |
|-------|----------|----------------|
| Some "DO NOT" are necessary warnings | `00_plan.md` L19 | Keep but restructure as "Phase Boundary" rule |
| "unless" in natural language OK | Various | Only remove from conditional logic, not explanatory text |
| CONTEXT.md duplicates | L143, L185 | Update after command files updated |

---

## Architecture

### File Modification Plan

| File | Changes | Priority | Estimated Lines |
|------|---------|----------|-----------------|
| **NEW** `.claude/guides/instruction-clarity.md` | Create guide document | High | ~100 lines |
| `.claude/commands/03_close.md` | Step 5, Step 7 conditionals | High | ~20 lines changed |
| `.claude/commands/02_execute.md` | MANDATORY ACTION sections | Medium | ~15 lines changed |
| `.claude/commands/01_confirm.md` | Skip conditions | Medium | ~10 lines changed |
| `.claude/commands/00_plan.md` | Phase boundary expressions | Low | ~5 lines changed |
| `.claude/commands/CONTEXT.md` | Update references | Low | ~5 lines changed |

### Pattern Transformation Guide

**Rule 1: Default Behavior First**
```markdown
# Before
Do X (unless flag specified)

# After
### Default Behavior
Always do X.

### Exception: --flag
Skip X when --flag is provided.
```

**Rule 2: Positive Framing**
```markdown
# Before
DO NOT SKIP this step

# After
EXECUTE this step
```

**Rule 3: Separate Sections**
```markdown
# Before
**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):

# After
### Default Behavior
Always execute this step.

### Exception: --no-docs flag
Skip when --no-docs flag is explicitly provided.
```

---

## Vibe Coding Compliance

| Target | Limit | Current | Status |
|--------|-------|---------|--------|
| Function/Section | ≤50 lines | ~30 lines each | Pass |
| File | ≤200 lines | ~100 lines new guide | Pass |
| Nesting | ≤3 levels | 1-2 levels | Pass |

---

## Execution Plan

### Phase 1: Create Guide Document (SC-4)

**Step 1.1**: Create `.claude/guides/instruction-clarity.md`
- Document transformation rules
- Include good vs bad examples
- Reference research findings (LLM negation issues)

### Phase 2: Refactor 03_close.md (SC-1, SC-2, SC-3)

**Step 2.1**: Refactor Step 5 (Documenter Agent)
- Add "Default Behavior" section
- Move exception to separate "Exception: --no-docs" section
- Remove "DO NOT SKIP (unless...)" pattern

**Step 2.2**: Refactor Step 7 (Git Commit)
- Restructure "Skip only if no-commit" to positive framing
- Add explicit default behavior statement

### Phase 3: Refactor Other Commands

**Step 3.1**: Refactor `02_execute.md`
- Update MANDATORY ACTION sections
- Remove "DO NOT" patterns where possible

**Step 3.2**: Refactor `01_confirm.md`
- Clarify --lenient and --no-review conditions

**Step 3.3**: Refactor `00_plan.md`
- Restructure phase boundary as positive rules

**Step 3.4**: Update `CONTEXT.md`
- Sync with updated command patterns

### Phase 4: Verification

**Step 4.1**: Run grep verification
```bash
grep -c "unless" .claude/commands/*.md
grep -c "DO NOT SKIP" .claude/commands/*.md
```

**Step 4.2**: Manual review of each changed file

---

## Acceptance Criteria

- [ ] AC-1: Guide document `.claude/guides/instruction-clarity.md` exists
- [ ] AC-2: `03_close.md` Step 5 uses "Default Behavior" + "Exception" pattern
- [ ] AC-3: `03_close.md` Step 7 uses positive framing
- [ ] AC-4: "DO NOT SKIP (unless...)" pattern eliminated from all commands
- [ ] AC-5: All changed files pass manual review for clarity
- [ ] AC-6: No functional changes to command behavior

---

## Test Plan

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | Default behavior (no flags) | `/03_close` | Documenter Agent invoked | Manual | N/A |
| TS-2 | --no-docs flag | `/03_close --no-docs` | Documenter Agent skipped | Manual | N/A |
| TS-3 | grep verification - unless | `grep -c "unless" .claude/commands/*.md` | Significantly reduced count | Automated | N/A |
| TS-4 | grep verification - DO NOT SKIP | `grep "DO NOT SKIP.*unless" .claude/commands/*.md` | Empty result | Automated | N/A |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Existing behavior changes | Low | High | Documentation expression only, no logic changes |
| Too many file changes | Medium | Medium | Phased approach (03_close first) |
| Missed patterns | Medium | Low | Use grep to find all instances before/after |

---

## Open Questions

1. **Flag naming convention**: Should we recommend changing `--no-docs` to `--skip-docs` in future version? (Not in scope for this work, but worth documenting)

2. **Priority for other commands**: Should all commands be updated in one PR, or incrementally?

---

## References

- [Prompting best practices - Claude Docs](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Why Positive Prompts Outperform Negative Ones](https://gadlet.com/posts/negative-prompting/)
- [LLMs Don't Understand Negation - HackerNoon](https://hackernoon.com/llms-dont-understand-negation)

---

## Execution Summary

### Implementation Complete ✅

**Success Criteria Met**:
- SC-1: "unless" pattern eliminated → 0 occurrences in all command files
- SC-2: "DO NOT SKIP.*unless" pattern eliminated → 0 occurrences
- SC-3: Default behavior declaration pattern applied → 4 "Default Behavior" sections added
- SC-4: Guide document created → instruction-clarity.md (7488 bytes)

### Files Changed

| File | Changes | Lines |
|------|---------|-------|
| `.claude/guides/instruction-clarity.md` | Created new guide document | ~200 lines |
| `.claude/commands/03_close.md` | Step 5, Step 7 conditionals refactored | ~20 lines |
| `.claude/commands/02_execute.md` | MANDATORY ACTION sections improved | ~15 lines |
| `.claude/commands/01_confirm.md` | Skip conditions clarified | ~10 lines |
| `.claude/commands/00_plan.md` | Phase boundary rules restructured | ~5 lines |
| `.claude/commands/999_publish.md` | Success Criteria updated | ~2 lines |

### Test Results

| Test ID | Description | Result |
|---------|-------------|--------|
| TS-1 | Default behavior (no flags) | ✅ PASS |
| TS-2 | --no-docs flag handling | ✅ PASS |
| TS-3 | grep verification for "unless" | ✅ 0 occurrences |
| TS-4 | grep verification for "DO NOT SKIP.*unless" | ✅ 0 occurrences |

### Verification

```bash
# Verification commands run
grep -c "unless" .claude/commands/*.md  # Result: 0 occurrences
grep "DO NOT SKIP.*unless" .claude/commands/*.md  # Result: Empty
```

### Pattern Transformations Applied

**Before (Confusing)**:
```markdown
**EXECUTE IMMEDIATELY - DO NOT SKIP** (unless `--no-docs` specified):
```

**After (Clear)**:
```markdown
### Default Behavior
Always invoke Documenter Agent after plan completion.

### MANDATORY ACTION: Documenter Agent Invocation
**EXECUTE IMMEDIATELY**:
[Task call content...]

### Exception: --no-docs flag
When `--no-docs` flag is provided, skip this step entirely.
```

### Follow-ups

- None identified

### Ralph Loop Status

<RALPH_COMPLETE>
- Iterations: 1
- All tests pass
- All SC met

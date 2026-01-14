# Issue: /01_confirm Plan Extraction Gap

**Created**: 2026-01-14
**Status**: Open
**Priority**: High
**Related Plan**: `.pilot/plan/pending/20260114_215100_context_isolation_skills_agents.md`

---

## Problem Summary

`/01_confirm` command failed to fully capture detailed implementation specifications discussed during `/00_plan` conversation, specifically the **Command Update documentation patterns**.

---

## Discovery Timeline

1. **During /00_plan**: Discussed detailed Command update patterns including:
   - Task invocation syntax
   - Result processing sections
   - Context Flow Diagrams
   - Token savings visualization

2. **After /01_confirm**: Plan file was created with only abstract Phase 4:
   ```markdown
   ### Phase 4: Command Updates (Priority: High)
   - [ ] 4.1 Update `/02_execute.md` with Task delegation to coder agent
   - [ ] 4.2 Update `/03_close.md` with Task delegation to documenter agent
   ```

3. **User caught the gap**: "커맨드 수정 (명확한 에이전트 호출 추가) 도 계획되어있나? 아까 5순위였던거"

4. **Manual fix applied**: Phase 4 expanded to 9 sub-tasks with concrete code examples.

---

## Root Cause Analysis

| Factor | Description |
|--------|-------------|
| **Implicit vs Explicit** | Detailed examples were shown as "proposals" in conversation, not explicitly marked as "include in plan" |
| **Context Length** | Long conversation may have caused detail loss during extraction |
| **Template Gap** | `/01_confirm` template doesn't emphasize preserving code examples from conversation |
| **No Verification Step** | No step to compare extracted plan against conversation highlights |

---

## Detailed Content Lost

The following detailed content was discussed but not initially extracted:

### 1. Task Invocation Syntax
```markdown
Task:
  agent: coder
  prompt: |
    Execute the following plan:
    Plan Path: {PLAN_PATH}
    ...
```

### 2. Result Processing Pattern
```markdown
## Step 3: Process Coder Results

Wait for Coder Agent completion. Expect:
- CODER_COMPLETE handling
- CODER_BLOCKED handling
```

### 3. Context Flow Diagram
```
/02_execute (Orchestrator - Main Context)
    │
    ├─► Task: Coder Agent (Isolated Context)
    │       └─► [80K tokens consumed internally]
    │       └─► Returns: "3 files changed, tests pass" (1K)
    ...
Total Main Context: ~5K tokens (vs 110K+ without isolation)
```

---

## Impact

| Aspect | Impact |
|--------|--------|
| **Plan Quality** | Incomplete plan would lead to incomplete execution |
| **Next Session** | Executor would lack guidance on HOW to update commands |
| **Reproducibility** | Pattern would repeat for future detailed discussions |

---

## Proposed Solutions

### Short-term (This Plan)
- [x] Manually expanded Phase 4 with detailed sub-tasks
- [x] Added code examples directly in plan file
- [x] Updated SC-5, SC-6, AC-3~AC-6 for verification

### Long-term (Process Improvement)

#### Option A: Enhance /01_confirm Template
Add explicit step:
```markdown
## Step 1.5: Conversation Highlights Extraction

Before extracting plan, identify:
- [ ] Code examples shown in conversation
- [ ] Detailed implementation patterns discussed
- [ ] Specific syntax/format proposals

Mark these with `> **FROM CONVERSATION:**` in plan file.
```

#### Option B: Add Verification Question
```markdown
## Step 4.5: User Verification

AskUserQuestion:
  question: "The following detailed items were discussed. Should they be included in plan?"
  options:
    - Include all
    - Include selected
    - Skip (executor will decide)
```

#### Option C: Structured Proposal Markers
During `/00_plan`, use markers like:
```markdown
> **📋 INCLUDE IN PLAN:**
> [detailed content here]
```

Then `/01_confirm` extracts all marked sections.

---

## Action Items for Next Session

1. **Execute Current Plan**: Run `/02_execute` on the corrected plan
2. **Evaluate Gap Detection**: Did the current gap detection (Step 7) catch this issue?
3. **Decide on Long-term Fix**: Choose Option A, B, or C for process improvement
4. **Consider New Test Scenario**: Add "detailed discussion extraction" to /01_confirm test plan

---

## Files Modified (This Session)

| File | Change |
|------|--------|
| `.pilot/plan/pending/20260114_215100_context_isolation_skills_agents.md` | Expanded Phase 4, updated SC/AC/TS |

---

## Related Issues

- None yet (first occurrence documented)

---

## References

- Conversation timestamp: 2026-01-14 ~21:00
- User observation: "아까 5순위였던거" referring to proposed implementation priority

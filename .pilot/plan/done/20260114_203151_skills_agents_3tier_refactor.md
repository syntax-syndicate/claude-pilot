# Skills/Agents System & 3-Tier Documentation Refactor

- Generated: 2026-01-14 20:31:51 | Work: skills_agents_3tier_refactor
- Location: `.pilot/plan/pending/20260114_203151_skills_agents_3tier_refactor.md`

---

## User Requirements

1. **AGENTS.md Cleanup**: Remove legacy AGENTS.md (not officially supported by Claude Code)
2. **Skills/Agents System**: Design structure aligned with Claude Code official best practices
3. **3-Tier Documentation Enhancement**:
   - Integrate documentation into workflow (not optional)
   - Add auto-compression/splitting when documents get too long
4. **Subagent Pattern**: Use Task tool for verification/exploration (context preservation)
5. **Handoff Section Sync**: Fix `/01_confirm` missing "Execution Context" in Plan Structure
6. **Review Command Improvement**: Add Plan Type detection for conditional Test File requirement

---

## PRP Analysis

### What (Functionality)

| Item | Description |
|------|-------------|
| **AGENTS.md Removal** | Delete root AGENTS.md, update CLI config |
| **Rules Directory** | Create `.claude/rules/` with Claude Code official pattern |
| **3-Tier Integration** | Embed documentation checklist in `/03_close` |
| **Document Auto-Management** | Implement compression/splitting logic for long documents |
| **Handoff Sync** | Add "Execution Context" to `/01_confirm` Plan Structure |
| **Review Improvement** | Add Plan Type detection in `/90_review` for conditional validation |

### Why (Context)

| Current State | Problem |
|---------------|---------|
| AGENTS.md in root | Claude Code doesn't read it (Codex/OpenCode pattern) |
| /91_document is optional | 3-Tier documentation gets neglected |
| Documents accumulate | No size management, becomes unwieldy |
| No subagent usage | Missing context preservation benefits |
| /01_confirm missing Execution Context | Handoff info can be lost when creating plan file |
| /90_review always requires Test File | Config/doc plans incorrectly flagged as BLOCKING |

### How (Approach)

#### Phase 1: Legacy Cleanup
- Remove `AGENTS.md` from root
- Update `src/claude_pilot/config.py` USER_FILES list
- Update documentation references

#### Phase 2: Rules Directory Setup
- Create `.claude/rules/core/` for always-loaded rules
- Create `.claude/rules/documentation/` for 3-Tier path-specific rules

#### Phase 3: 3-Tier Workflow Integration
- Modify `/03_close` to include documentation checklist
- Add document size monitoring and auto-management

#### Phase 4: Document Auto-Management
- Implement size thresholds per tier
- Add compression/splitting logic
- Update `/91_document` with auto-management capability

#### Phase 5: Command Sync & Review Improvement
- Add "Execution Context" to `/01_confirm` Plan Structure
- Add Plan Type detection to `/90_review` Step 2
- Conditional Test File requirement based on plan type

#### Phase 6: CLI Distribution Sync
- Add AGENTS.md to DEPRECATED_FILES (auto-delete on update)
- Remove AGENTS.md from USER_FILES
- Add rules/ files to MANAGED_FILES
- Add guides/ files to MANAGED_FILES
- Create templates in `src/claude_pilot/templates/`

### Success Criteria

```
SC-1: AGENTS.md Removed
- Verify: ls -la AGENTS.md returns "No such file"
- Expected: File deleted, no CLI errors

SC-2: Rules Directory Created
- Verify: ls .claude/rules/
- Expected: core/ and documentation/ subdirectories exist

SC-3: 3-Tier Integration in /03_close
- Verify: grep "Documentation Checklist" .claude/commands/03_close.md
- Expected: Documentation checklist section present

SC-4: Document Auto-Management
- Verify: grep "auto-compress\|auto-split" .claude/guides/3tier-documentation.md
- Expected: Auto-management rules documented

SC-5: CLI Config Updated
- Verify: grep -v "AGENTS.md" src/claude_pilot/config.py
- Expected: AGENTS.md removed from USER_FILES

SC-6: Execution Context in /01_confirm
- Verify: grep "Execution Context" .claude/commands/01_confirm.md
- Expected: Section present in Plan Structure

SC-7: Plan Type Detection in /90_review
- Verify: grep "Plan Type\|Config\|Documentation" .claude/commands/90_review.md
- Expected: Type detection logic with conditional Test File requirement

SC-8: AGENTS.md in DEPRECATED_FILES
- Verify: grep "AGENTS.md" src/claude_pilot/config.py | grep DEPRECATED
- Expected: AGENTS.md in DEPRECATED_FILES list

SC-9: Rules in MANAGED_FILES
- Verify: grep "rules/" src/claude_pilot/config.py
- Expected: rules/core/workflow.md and rules/documentation/tier-rules.md present

SC-10: Guides in MANAGED_FILES
- Verify: grep "guides/" src/claude_pilot/config.py
- Expected: guides/*.md files present in MANAGED_FILES
```

### Constraints

| Type | Constraint |
|------|------------|
| **Technical** | Must use Claude Code official patterns only |
| **Compatibility** | Preserve existing workflow (/00_plan → /03_close) |
| **Token** | Document size limits per Claude best practices |

---

## Scope

### In Scope

- [x] Delete AGENTS.md
- [x] Create `.claude/rules/` structure
- [x] Modify `/03_close` with 3-Tier checklist
- [x] Add document size management to 3-Tier guide
- [x] Update CLI config (config.py)
- [x] Update `/91_document` with auto-management

### Out of Scope

- [ ] Subagent templates (deferred to future iteration)
- [ ] Path-specific rules for agents/ (commands already handle this)
- [ ] Full rewrite of existing commands

---

## Test Environment

| Aspect | Detection |
|--------|-----------|
| Language | Python (pytest) |
| Test Command | `pytest` |
| Type Check | `mypy .` or skip |
| Lint | `ruff check .` or skip |

---

## Architecture

### File Changes

```
DELETE:
  - AGENTS.md (root)

CREATE:
  - .claude/rules/core/workflow.md
  - .claude/rules/documentation/tier-rules.md

MODIFY:
  - src/claude_pilot/config.py:
    - Remove AGENTS.md from USER_FILES
    - Add AGENTS.md to DEPRECATED_FILES
    - Add rules/*.md to MANAGED_FILES
    - Add guides/*.md to MANAGED_FILES
  - .claude/commands/03_close.md (add documentation checklist)
  - .claude/guides/3tier-documentation.md (add auto-management section)
  - .claude/commands/91_document.md (add auto-management logic)
  - .claude/commands/01_confirm.md (add Execution Context to Plan Structure)
  - .claude/commands/90_review.md (add Plan Type detection, conditional Test File)

SYNC TO TEMPLATES:
  - src/claude_pilot/templates/.claude/rules/core/workflow.md
  - src/claude_pilot/templates/.claude/rules/documentation/tier-rules.md
  - src/claude_pilot/templates/.claude/guides/*.md (all guide files)
  - src/claude_pilot/templates/.claude/commands/*.md (modified commands)
```

### Document Size Thresholds

Based on Claude Code best practices and Vibe Coding principles:

| Tier | File | Max Lines | Max Tokens (Est.) | Action When Exceeded |
|------|------|-----------|-------------------|---------------------|
| **Tier 1** | CLAUDE.md | 300 lines | ~3000 tokens | Split to docs/ai-context/ |
| **Tier 2** | CONTEXT.md | 200 lines | ~2000 tokens | Archive old sections |
| **Tier 3** | CONTEXT.md | 150 lines | ~1500 tokens | Compress or split by feature |

### Auto-Management Rules

```markdown
## Document Size Management

### Detection
- Count lines: `wc -l < file.md`
- Estimate tokens: lines × 10 (rough estimate)

### Actions by Tier

**Tier 1 (CLAUDE.md > 300 lines)**:
1. Move detailed sections to docs/ai-context/
2. Keep only quick-reference in CLAUDE.md
3. Use @imports for details

**Tier 2 (CONTEXT.md > 200 lines)**:
1. Archive historical decisions to {component}/HISTORY.md
2. Keep only current architecture
3. Compress implementation details

**Tier 3 (CONTEXT.md > 150 lines)**:
1. Split by feature area
2. Create sub-CONTEXT.md files
3. Link from parent CONTEXT.md
```

### Dependencies

```
[/03_close] --reads--> [.claude/rules/documentation/]
     |
     └──includes──> [Documentation Checklist]
                         |
                         └──triggers──> [/91_document auto-management]
```

---

## Vibe Coding Compliance

| Target | Limit | Status |
|--------|-------|--------|
| Function | ≤50 lines | N/A (mostly markdown) |
| File | ≤200 lines | ✅ Each file under limit |
| Nesting | ≤3 levels | ✅ Flat structure |

---

## Execution Plan

### Step 1: Delete AGENTS.md
```bash
rm AGENTS.md
git add -A && git status
```

### Step 2: Update CLI Config
```python
# src/claude_pilot/config.py
# Remove "AGENTS.md" from USER_FILES list
USER_FILES: list[str] = [
    "CLAUDE.md",
    # "AGENTS.md",  # REMOVED - not Claude Code official
    ".pilot",
    ".claude/settings.json",
]
```

### Step 3: Create Rules Directory
```bash
mkdir -p .claude/rules/core
mkdir -p .claude/rules/documentation
```

### Step 4: Create Core Workflow Rule
```markdown
# .claude/rules/core/workflow.md
(no paths = always loaded)

# claude-pilot Core Workflow

## SPEC-First TDD
- What → Why → How → Success Criteria
- Test scenarios before implementation

## Ralph Loop
- Enter immediately after code change
- Max 7 iterations
- Coverage 80%+ (core 90%+)
```

### Step 5: Create Documentation Rules
```markdown
# .claude/rules/documentation/tier-rules.md
---
paths:
  - "CLAUDE.md"
  - "**/CONTEXT.md"
  - "docs/**"
---

# 3-Tier Documentation Rules

## Size Limits
- Tier 1 (CLAUDE.md): ≤300 lines
- Tier 2 (Component CONTEXT.md): ≤200 lines
- Tier 3 (Feature CONTEXT.md): ≤150 lines

## Auto-Management Triggers
When limit exceeded:
1. Notify user
2. Suggest compression/split strategy
3. Execute with confirmation
```

### Step 6: Modify /03_close
Add documentation checklist section (see Architecture section)

### Step 7: Update 3-Tier Guide
Add auto-management section (see Architecture section)

### Step 8: Update /91_document
Add auto-management logic for size detection and handling

### Step 9: Update Template Files
Sync changes to `src/claude_pilot/templates/.claude/` for CLI distribution

### Step 10: Update GETTING_STARTED.md
Remove AGENTS.md references from documentation

### Step 11: Sync Execution Context to /01_confirm
Add "Execution Context (Planner Handoff)" to Plan Structure in Step 3.1:
```markdown
## User Requirements
## PRP Analysis
## Scope
## Test Environment (Detected)
## Execution Context (Planner Handoff)  ← ADD THIS
## External Service Integration [if applicable]
## Architecture
...
```

### Step 12: Add Plan Type Detection to /90_review
Add to Step 2 (Type Detection):
```markdown
### Plan Type Categories
| Type | Keywords | Test File Requirement |
|------|----------|----------------------|
| **Code** | function, component, API, src/, lib/, tests/ | Required |
| **Config** | .claude/, settings, rules, template | Optional (N/A allowed) |
| **Documentation** | CLAUDE.md, README, guide, docs/ | Optional (N/A allowed) |

### Auto-Detection Logic
IF plan modifies ONLY files matching Config/Documentation patterns:
  → Test File requirement = Optional
  → Allow "N/A" in Test File column
ELSE:
  → Test File requirement = Required
```

### Step 13: Update config.py for CLI Distribution
```python
# src/claude_pilot/config.py

# 1. Move AGENTS.md from USER_FILES to DEPRECATED_FILES
USER_FILES: list[str] = [
    "CLAUDE.md",
    # "AGENTS.md",  # REMOVED - moved to DEPRECATED_FILES
    ".pilot",
    ".claude/settings.json",
    ".claude/local",
]

DEPRECATED_FILES: list[str] = [
    ".claude/templates/PRP.md.template",
    "AGENTS.md",  # ADDED - will be auto-deleted on update
]

# 2. Add rules/ and guides/ to MANAGED_FILES
MANAGED_FILES: list[tuple[str, str]] = [
    # ... existing commands ...
    # Rules (new)
    (".claude/rules/core/workflow.md", ".claude/rules/core/workflow.md"),
    (".claude/rules/documentation/tier-rules.md", ".claude/rules/documentation/tier-rules.md"),
    # Guides (new)
    (".claude/guides/tdd-methodology.md", ".claude/guides/tdd-methodology.md"),
    (".claude/guides/ralph-loop.md", ".claude/guides/ralph-loop.md"),
    (".claude/guides/vibe-coding.md", ".claude/guides/vibe-coding.md"),
    (".claude/guides/prp-framework.md", ".claude/guides/prp-framework.md"),
    (".claude/guides/review-checklist.md", ".claude/guides/review-checklist.md"),
    (".claude/guides/gap-detection.md", ".claude/guides/gap-detection.md"),
    (".claude/guides/3tier-documentation.md", ".claude/guides/3tier-documentation.md"),
    (".claude/guides/test-environment.md", ".claude/guides/test-environment.md"),
    # ... existing templates, hooks ...
]
```

### Step 14: Sync to Templates Directory
```bash
# Create rules directory in templates
mkdir -p src/claude_pilot/templates/.claude/rules/core
mkdir -p src/claude_pilot/templates/.claude/rules/documentation

# Copy rules files
cp .claude/rules/core/workflow.md src/claude_pilot/templates/.claude/rules/core/
cp .claude/rules/documentation/tier-rules.md src/claude_pilot/templates/.claude/rules/documentation/

# Create guides directory in templates (if not exists)
mkdir -p src/claude_pilot/templates/.claude/guides

# Copy all guides
cp .claude/guides/*.md src/claude_pilot/templates/.claude/guides/

# Copy modified commands
cp .claude/commands/*.md src/claude_pilot/templates/.claude/commands/
```

---

## Acceptance Criteria

| ID | Criteria | Verification |
|----|----------|--------------|
| AC-1 | AGENTS.md deleted | `[ ! -f AGENTS.md ]` |
| AC-2 | CLI config updated | `grep -v AGENTS.md config.py` |
| AC-3 | Rules directory exists | `ls .claude/rules/` |
| AC-4 | /03_close has doc checklist | Manual review |
| AC-5 | 3-Tier guide has auto-management | Manual review |
| AC-6 | /91_document has size handling | Manual review |
| AC-7 | /01_confirm has Execution Context | `grep "Execution Context" 01_confirm.md` |
| AC-8 | /90_review has Plan Type detection | `grep "Plan Type" 90_review.md` |
| AC-9 | AGENTS.md in DEPRECATED_FILES | `grep "AGENTS.md" config.py \| grep DEPRECATED` |
| AC-10 | Rules/guides in MANAGED_FILES | `grep "rules/\|guides/" config.py` |

---

## Test Plan

> **Note**: This plan involves configuration/documentation changes. Manual verification is appropriate.

| ID | Scenario | Input | Expected | Type | Test File |
|----|----------|-------|----------|------|-----------|
| TS-1 | CLI init without AGENTS.md | `claude-pilot init .` | Success, no AGENTS.md created | Manual | N/A |
| TS-2 | CLI update preserves no AGENTS.md | `claude-pilot update` | AGENTS.md not recreated | Manual | N/A |
| TS-3 | Rules loaded by Claude Code | Start session | `/memory` shows rules | Manual | N/A |
| TS-4 | Doc checklist in /03_close | Run `/03_close` | Checklist prompt appears | Manual | N/A |
| TS-5 | Template files synced | Compare `.claude/` with `src/claude_pilot/templates/.claude/` | Files match | Manual | N/A |
| TS-6 | Execution Context in plan file | Run `/00_plan` + `/01_confirm` | Plan file includes Execution Context section | Manual | N/A |
| TS-7 | Config plan review passes | Create config-only plan, run `/90_review` | No BLOCKING for Test File (N/A allowed) | Manual | N/A |
| TS-8 | CLI update deletes AGENTS.md | Create AGENTS.md, run `claude-pilot update` | AGENTS.md deleted (DEPRECATED_FILES) | Manual | N/A |
| TS-9 | CLI init creates rules/guides | Run `claude-pilot init .` in new dir | .claude/rules/ and .claude/guides/ created | Manual | N/A |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Breaking existing workflows | Low | High | Preserve all commands, only add |
| Rules not loading | Medium | Medium | Test with `/memory` command |
| Document compression loses info | Medium | Medium | Archive before compress |

---

## Open Questions

1. **Q**: Should we add subagent templates now or defer?
   **A**: Deferred - focus on core 3-Tier integration first

2. **Q**: What's the exact token threshold per tier?
   **A**: Line-based (300/200/150) as proxy, easier to measure

3. **Q**: Should auto-management be automatic or prompt-based?
   **A**: Prompt-based with suggestion (safer, user control)

---

## References

- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Claude Code Memory Docs](https://code.claude.com/docs/en/memory)
- [Vibe Coding Guide](https://www.index.dev/blog/vibe-coding-ai-development)

---

## Review History

### Review #1 (2026-01-14)
**Findings Applied**: BLOCKING: 1 (resolved), Critical: 0, Warning: 2 (addressed), Suggestion: 2

**Changes Made**:
1. Added Test File column with N/A for manual tests (BLOCKING resolved)
2. Added Step 9: Update Template Files (Warning #1 addressed)
3. Added Step 10: Update GETTING_STARTED.md (Warning #2 addressed)
4. Added TS-5 for template sync verification

### Review #2 (2026-01-14) - Scope Expansion
**User Feedback**: Include handoff sync and review improvement in current plan

**Findings**:
- `/01_confirm` missing "Execution Context" in Plan Structure (handoff can be lost)
- `/90_review` should auto-detect plan type for conditional Test File requirement

**Changes Made**:
1. Added User Requirement #5: Handoff Section Sync
2. Added User Requirement #6: Review Command Improvement
3. Added Phase 5: Command Sync & Review Improvement
4. Added SC-6, SC-7 for new features
5. Added Step 11, 12 for implementation details
6. Added AC-7, AC-8 for acceptance criteria
7. Added TS-6, TS-7 for test scenarios
8. Updated File Changes list to include 01_confirm.md, 90_review.md

### Review #3 (2026-01-14) - CLI Distribution Completeness
**User Feedback**: Ensure CLI distribution handles file additions/deletions properly

**Findings**:
- Phase 6 added for CLI distribution sync (Step 13-14)
- SC-8/9/10 added for CLI verification
- Missing AC and Test scenarios for CLI distribution

**Changes Made**:
1. Added AC-9: AGENTS.md in DEPRECATED_FILES verification
2. Added AC-10: Rules/guides in MANAGED_FILES verification
3. Added TS-8: CLI update DEPRECATED_FILES behavior test
4. Added TS-9: CLI init rules/guides creation test

**Final Assessment**: ✅ Pass - Ready for execution

## Execution Summary

### Changes Made

**Deleted:**
- `AGENTS.md` from root directory

**Created:**
- `.claude/rules/core/workflow.md` - Claude Code official pattern for workflow rules
- `.claude/rules/documentation/tier-rules.md` - 3-Tier documentation rules with path-specific loading
- `src/claude_pilot/templates/.claude/rules/core/workflow.md` - Template sync
- `src/claude_pilot/templates/.claude/rules/documentation/tier-rules.md` - Template sync
- `src/claude_pilot/templates/.claude/guides/*.md` - All 8 guides synced to templates

**Modified:**
- `src/claude_pilot/config.py`:
  - Removed AGENTS.md from USER_FILES
  - Added AGENTS.md to DEPRECATED_FILES (auto-delete on update)
  - Added rules/ files to MANAGED_FILES (2 entries)
  - Added guides/ files to MANAGED_FILES (8 entries)
- `.claude/commands/03_close.md`: Added Step 5 - Documentation Checklist (3-Tier)
- `.claude/guides/3tier-documentation.md`: Added Document Size Management section
- `.claude/commands/91_document.md`: Added Section 2.4 - Document Size Management
- `.claude/commands/01_confirm.md`: Added Execution Context to Plan Structure
- `.claude/commands/90_review.md`: Added Plan Type detection with conditional Test File requirement
- `GETTING_STARTED.md`: Removed AGENTS.md references (3 locations)
- `src/claude_pilot/templates/.claude/commands/`: Synced modified command files

### Verification Results

All 10 Success Criteria verified:
- ✅ SC-1: AGENTS.md Removed
- ✅ SC-2: Rules Directory Created
- ✅ SC-3: 3-Tier Integration in /03_close
- ✅ SC-4: Document Auto-Management
- ✅ SC-5: CLI Config Updated
- ✅ SC-6: Execution Context in /01_confirm
- ✅ SC-7: Plan Type Detection in /90_review
- ✅ SC-8: AGENTS.md in DEPRECATED_FILES
- ✅ SC-9: Rules in MANAGED_FILES
- ✅ SC-10: Guides in MANAGED_FILES

### Follow-ups

1. Test `claude-pilot update` to verify AGENTS.md is auto-deleted
2. Test `claude-pilot init` in new directory to verify rules/guides are created
3. Run `/00_plan` + `/01_confirm` to verify Execution Context appears in plan file
4. Create a Config-only plan and run `/90_review` to verify N/A is allowed for Test File

---
**Execution completed**: 2026-01-14 20:57

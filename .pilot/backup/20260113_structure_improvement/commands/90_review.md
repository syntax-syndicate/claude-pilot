---
description: Review plans with multi-angle analysis (mandatory + extended + autonomous)
argument-hint: "[focus] - optional focus areas (security, performance, accessibility, etc.)"
allowed-tools: Read, Glob, Grep, Bash(git:*), Write
---

# /90_review

_Review plans before implementation with comprehensive multi-angle analysis._

## Core Philosophy

- **Type-based review**: Customized for code/docs/scenario/infra/DB/AI plans
- **Mandatory + Extended + Autonomous**: Fixed items + type-specific + self-judgment
- **Proactive investigation**: Resolve "needs investigation" items upfront
- **Efficient progression**: Severity-based conditional checks

---

## Extended Thinking Mode

> **Conditional**: If LLM model is GLM, proceed with maximum extended thinking throughout all phases.

---

## Step 0: Load Plan

```bash
PLAN_PATH="$(ls -1tr .pilot/plan/in_progress/*/*.md .pilot/plan/pending/*.md 2>/dev/null | head -1)"
[ -z "$PLAN_PATH" ] && { echo "No plan found to review" >&2; exit 1; }
echo "Reviewing: $PLAN_PATH"
```

Read and extract: User requirements, Execution plan, Acceptance criteria, Test scenarios, Constraints, Risks

---

## Step 1: Proactive Investigation

> **Principle**: Investigate all "needs investigation/confirmation/review" items upfront

**Keywords**: "need to investigate", "confirm", "TODO", "check", "verify"

| Target | Method | Tools |
|--------|--------|-------|
| Existing code/patterns | Search similar impl | Glob, Grep, Read |
| API docs | Check official docs | WebSearch |
| Dependencies | npm/PyPI registry | Bash(npm/pip info) |

**Output**: `🔍 Investigation Complete: [Item] → Result: ✅/❌ Finding → Plan update: Applied`

---

## Step 2: Type Detection

| Type | Keywords | Extended Reviews |
|------|----------|------------------|
| **Code** | function, component, API, bug fix | A, B, D |
| **Docs** | CLAUDE.md, README, guide | C |
| **Scenario** | test, validation, edge cases | H |
| **Infra** | Vercel, env, deploy, CI/CD | F |
| **DB** | migration, table, schema | E |
| **AI** | LLM, prompts, AI | G |

**Output**: `📋 Type: [Primary] / Extended: [A, B, D]`

---

## Step 3: Mandatory Reviews (8 items)

Execute all 8 reviews for every plan

### Review 1: Development Principles
☐ **SOLID**: Single responsibility violations?
☐ **DRY**: Duplicate logic potential?
☐ **KISS**: Unnecessary complexity?
☐ **YAGNI**: Features not currently needed?

### Review 2: Project Structure
☐ New files in correct locations?
☐ Follows naming conventions?
☐ Uses same patterns as existing code?

### Review 3: Requirement Completeness
☐ All explicit requirements reflected?
☐ Implicit requirements considered? (error handling, loading states)

### Review 4: Logic Errors
☐ Implementation order correct?
☐ Dependencies ready at point of use?
☐ Edge cases considered? (null, empty, failure)
☐ Async handling correct?

### Review 5: Existing Code Reuse
☐ Search utils/, hooks/, common/ folders
☐ Check domain-related files
☐ Format: `🔍 New: [name] → Found: [file]` or `→ Write new`

### Review 6: Better Alternatives
☐ Simpler implementation?
☐ More scalable design?
☐ More testable structure?
☐ Industry best practices?

### Review 7: Project Alignment
☐ Type check possible?
☐ External API docs checked?
☐ All affected areas identified?

### Review 8: Long-term Impact
☐ Secondary consequences predicted?
☐ Technical debt potential assessed?
☐ Scalability constraints identified?
☐ Rollback cost considered?

---

## Step 4: Vibe Coding Compliance

> **NEW: Check Vibe Coding Guidelines enforcement**

| Target | Limit | Check |
|--------|-------|-------|
| Function | ≤50 lines | Plan mentions splitting large functions? |
| File | ≤200 lines | Plan respects module boundaries? |
| Nesting | ≤3 levels | Early return pattern specified? |

☐ **SRP**: One function = one responsibility?
☐ **DRY**: No duplicate code blocks planned?
☐ **KISS**: Simplest solution that works?
☐ **Early Return**: Reduced nesting planned?

---

## Step 5: Extended Reviews (By Type)

| Type | Activated | Focus |
|------|-----------|-------|
| A: API Compatibility | ☐ Code mod | Signature/call site impact |
| B: Type Safety | ☐ Code mod | Avoid any, null checks |
| C: Doc Consistency | ☐ Docs | Cross-refs, code sync |
| D: Test Impact | ☐ Code mod | Breaking tests |
| E: Migration Safety | ☐ DB | Rollback, integrity |
| F: Deployment Impact | ☐ Infra | Env vars, duration |
| G: Prompt Quality | ☐ AI | Positive expression |
| H: Scenario Review | ☐ Test | Coverage, reproducibility |

---

## Step 6: Autonomous Review

> **Self-judge beyond mandatory/extended items**

**Perspectives**: Security (auth, validation), Performance (bottlenecks, caching), UX (loading, errors), Maintainability (readability), Concurrency (race conditions), Error Recovery (partial failure)

**Output**: `🧠 Autonomous Discoveries: [1: Perspective] Issue → Recommendation`

---

## Step 7: User-Requested Focus

If `"$ARGUMENTS"` contains focus areas, deep-dive:

| Focus | Areas |
|-------|-------|
| `security` | Auth, injection, XSS, sensitive data |
| `performance` | Queries, loops, caching, bundle size |
| `accessibility` | ARIA, keyboard, contrast, screen readers |
| `api` | Backward compatibility, versioning |
| `testing` | Coverage, edge cases, integration |

---

## Step 8: Results Summary

```markdown
# Plan Review Results

## Summary
- **Assessment**: [Pass/Needs Revision]
- **Type**: [Primary / Extended: A,B,D]
- **Findings**: Critical: N / Warning: N / Suggestion: N

## Mandatory Review (8 items)
| # | Item | Status |
|---|------|--------|
| 1 | Dev Principles | ✅/⚠️/❌ |
| 2 | Project Structure | ✅/⚠️/❌ |
| 3 | Requirements | ✅/⚠️/❌ |
| 4 | Logic Errors | ✅/⚠️/❌ |
| 5 | Code Reuse | ✅/⚠️/❌ |
| 6 | Alternatives | ✅/⚠️/❌ |
| 7 | Project Alignment | ✅/⚠️/❌ |
| 8 | Long-term Impact | ✅/⚠️/❌ |

## Vibe Coding Compliance
| Target | Status |
|--------|--------|
| Functions ≤50 lines | ✅/⚠️/❌ |
| Files ≤200 lines | ✅/⚠️/❌ |
| Nesting ≤3 levels | ✅/⚠️/❌ |

## Extended Review [Activated items only]
## Autonomous Discoveries
## Issues
### 🚨 Critical (Must fix)
### ⚠️ Warning (Should fix)
### 💡 Suggestion
## Reusable Code Found
```

---

## Step 9: Apply Findings to Plan

> **Principle**: Review completion = Plan file improved with findings applied

### 9.1 Map Findings to Sections

| Issue Type | Target Section | Method |
|------------|----------------|--------|
| Missing step | Execution Plan | Add checkbox |
| Unclear requirement | User Requirements / Success Criteria | Clarify wording |
| Test gap | Test Plan | Add scenario |
| Risk identified | Risks & Mitigations | Add item |
| Alternative approach | How (Approach) | Add/modify |
| Scope issue | Scope (In/Out) | Adjust scope |

### 9.2 Apply & Update History

1. Read plan file
2. For each finding: Identify target section, Apply modification, Track change
3. Write updated plan

**Error Handling**: If error, keep original intact, log to History

**Append to Review History**:
```markdown
## Review History

### Review #N (YYYY-MM-DD HH:MM)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | N | N |
| Warning | N | N |
| Suggestion | N | N |

**Changes Made**:
1. **[Type] Section - Item**
   - Issue: [Description]
   - Applied: [Change made]
```

---

## Success Criteria

| Criteria | Threshold |
|----------|-----------|
| Auto-proceed | Critical 0 + Warning ≤1 |
| User confirmation | Critical ≥1 OR Warning ≥2 |

---

## References
- `.claude/guides/review-extensions.md`
- [Claude-Code-Development-Kit](https://github.com/peterkrueck/Claude-Code-Development-Kit)
- **Branch**: !`git rev-parse --abbrev-ref HEAD`

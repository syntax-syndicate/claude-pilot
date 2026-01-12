# Extended Review Guide for /90_review

> Detailed criteria for extended reviews activated by plan type detection

## Activation Matrix

| Type | Keywords | Activated Reviews |
|------|----------|-------------------|
| **Code Modification** | function, component, API, bug fix, refactor | A, B, D |
| **Documentation** | CLAUDE.md, README, guide | C |
| **Scenario Validation** | test, validation, scenario, edge cases | H |
| **Infrastructure** | Docker, env, deploy, CI/CD | F |
| **DB Schema** | migration, table, column | E |
| **AI/Prompts** | GPT, Claude, prompts, LLM | G |

---

## Extended A: API Compatibility Review

**When**: Code modification plans

| Item | Question |
|------|----------|
| **Function Signature** | Do param changes break existing callers? |
| **Return Type** | Does return value change affect logic? |
| **Required vs Optional** | If new params are required, do callers need modification? |
| **Backward Compat** | Can existing behavior be maintained with defaults? |

**Process**:
1. List functions/APIs being changed
2. Search call sites using Grep
3. Verify each call site works after change

**Result Format**:
```
[Changed: functionName()]
- Original: (param1: Type1) => ReturnType
- Changed: (param1: Type1, param2?: Type2) => ReturnType
- Backward compatible: Yes/No
- Call site impact: N files
```

---

## Extended B: Type Safety Review

**When**: Code modification plans

| Item | Question |
|------|----------|
| **Type Location** | Are new types in `types/` directory? |
| **Generic Complexity** | Are generics unnecessarily complex? |
| **any Usage** | Are concrete types used instead of `any`? |
| **null Check** | Are `?.` and `??` properly used? |
| **Type Guards** | Are type guards present where needed? |

---

## Extended C: Document Consistency Review

**When**: Documentation plans

| Item | Question |
|------|----------|
| **Cross-refs** | Are other docs referencing this? Are links valid? |
| **Code-Doc Sync** | Does content match actual code? |
| **Version Info** | Is last-updated date updated? |
| **Example Code** | Do examples match current API? |

---

## Extended D: Test Impact Review

**When**: Code modification plans

| Item | Question |
|------|----------|
| **Existing Tests** | Will any tests break from changes? |
| **Test Coverage** | Are tests for new code in the plan? |
| **Mocking** | Is mocking needed for new deps? |

---

## Extended E: Migration Safety

**When**: DB schema plans

| Item | Question |
|------|----------|
| **Rollback** | Can we rollback if migration fails? |
| **Data Integrity** | Is existing data preserved? |
| **Downtime** | Is service interruption required? |
| **Type Gen** | Is type generation included? |

---

## Extended F: Deployment Impact Review

**When**: Infrastructure/deployment plans

| Item | Question |
|------|----------|
| **Env Separation** | Are dev/staging/prod properly separated? |
| **Env Vars** | Are new env vars set in deployment platform? |
| **Rollback Plan** | Is there a rollback procedure? |
| **Timeout** | Is timeout set for long-running API calls? |

---

## Extended G: Prompt Quality Review

**When**: AI/prompt plans

| Item | Question |
|------|----------|
| **Positive Expression** | Using positive instead of DO NOT, NEVER? |
| **Context Balance** | Is info balanced across prompt sections? |
| **Examples** | Are success/failure examples included? |
| **Cost** | Is token usage appropriate? |

---

## Extended H: Test Scenario Review

**When**: Scenario validation plans

| Item | Question |
|------|----------|
| **Coverage** | Normal/edge/error cases all included? |
| **Reproducibility** | Can scenarios be consistently reproduced? |
| **Independence** | No dependency on other scenarios? |
| **Priority** | Critical scenarios verified first? |
| **Input/Output** | Are inputs and expected outputs clear? |

**Result Format**:
```
[Scenario: Name]
- Coverage: Normal/Edge/Error
- Reproducible: Yes/No
- Independent: Yes/No
```

---

## Quick Reference

```
Code Mod → A (API compat) + B (Types) + D (Tests)
Docs     → C (Consistency)
Scenario → H (Coverage)
Infra    → F (Deployment)
DB       → E (Migration)
AI       → G (Prompts)
```

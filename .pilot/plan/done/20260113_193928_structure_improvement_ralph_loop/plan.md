# Structure Improvement & Ralph Loop Enhancement

- Generated at: 2026-01-13 19:39:28
- Work name: structure_improvement_ralph_loop
- Location: .pilot/plan/pending/20260113_193928_structure_improvement_ralph_loop.md

---

## User Requirements

1. 가이드/커맨드 분리 제거 → 자기완결적 커맨드로 통합
2. 깨진 참조 수정 (ralph-loop-tdd.md, guides/ 등)
3. `02_execute.md`의 Ralph Loop TDD 패턴 강화 (moai-adk 참조)
4. `check-todos.sh` 경로 버그 수정 (`.cgcode/` → `.pilot/`)

---

## PRP Analysis

### What (Functionality)

**Objective**: Claude-pilot을 공식 Claude Code 패턴에 맞게 구조 정리 + Ralph Loop TDD 강제 메커니즘 구현

**Files to modify**:
- `.claude/scripts/hooks/check-todos.sh` - 경로 버그 수정
- `.claude/commands/90_review.md` - Extended Review 통합
- `.claude/commands/02_execute.md` - Ralph Loop 강화
- `.claude/commands/00_plan.md` - guides 참조 제거
- `.claude/commands/01_confirm.md` - guides 참조 제거
- `.claude/commands/03_close.md` - ralph-loop-tdd.md 참조 제거
- `.claude/commands/91_document.md` - guides 참조 제거
- `README.md` - 구조 다이어그램 수정
- `GETTING_STARTED.md` - guides 언급 제거
- `.claude/guides/` - 폴더 삭제

### Why (Context)

**Current State**:
- `check-todos.sh`가 `.cgcode/` 경로 사용 (버그 - 실제는 `.pilot/`)
- Ralph Loop가 설명만 있고 실제 강제 메커니즘 없음 (coverage, iteration 체크 없음)
- `guides/` 폴더에 `review-extensions.md`가 별도로 존재
- `03_close.md`가 존재하지 않는 `ralph-loop-tdd.md` 참조

**Desired State**:
- 모든 경로가 `.pilot/`로 통일
- Ralph Loop가 실제로 coverage + todo 달성까지 반복 강제
- 자기완결적 커맨드 (외부 가이드 참조 없음)

**Business Value**:
- TDD 품질 보장 (80% coverage 강제)
- 불완전한 작업 방지 (todo 완료까지 반복)
- VIBE 코딩 경험 개선
- 토큰 효율성 향상

### How (Approach)

**Phase 1: 백업**
- [ ] `.pilot/backup/` 에 현재 상태 백업

**Phase 2: check-todos.sh 버그 수정**
- [ ] Line 17: `.cgcode/plan/in_progress` → `.pilot/plan/in_progress`
- [ ] Line 27: `.cgcode/plan/active` → `.pilot/plan/active`
- [ ] Line 35-36: 전체 파일 경로 패턴 검토 (RUN_DIR, PLAN_FILE 등)

**Phase 3: 90_review.md에 Extended Review 통합**
- [ ] `review-extensions.md` 내용을 Step 5에 상세 추가
- [ ] Extended A~H 테이블 및 체크리스트 포함
- [ ] guides 참조 제거 (자기완결적으로)

**Phase 4: 02_execute.md Ralph Loop 강화**
- [ ] Coverage 임계값 강제 로직 추가 (COVERAGE_THRESHOLD=80, CORE_THRESHOLD=90)
- [ ] Iteration 카운터 추가 (MAX_ITERATIONS=7)
- [ ] Completion Promise 패턴 추가 (`<RALPH_COMPLETE>`)
- [ ] TodoWrite 연동 강화 (반복 체크)

**Phase 5: 참조 정리**
- [ ] `00_plan.md`: guides 참조 제거
- [ ] `01_confirm.md`: guides 참조 제거
- [ ] `03_close.md`: ralph-loop-tdd.md 참조 제거
- [ ] `91_document.md`: guides 참조 제거

**Phase 6: 프로젝트 문서 업데이트**
- [ ] `README.md`: 구조 다이어그램에서 `guides/` 제거 (Line 66-67)
- [ ] `README.md`: "Guides" 섹션에서 guides 참조 제거 (Line 371-375)
- [ ] `GETTING_STARTED.md`: guides 언급 제거 (Line 22)

**Phase 7: 가이드 폴더 삭제**
- [ ] `rm -rf .claude/guides/`

**Phase 8: 검증**
- [ ] 모든 SC 확인
- [ ] 워크플로우 테스트

### Success Criteria

```
SC-1: check-todos.sh 경로 수정
- Verify: grep -c "\.pilot" .claude/scripts/hooks/check-todos.sh
- Expected: 2+ matches (was .cgcode)

SC-2: guides 폴더 제거
- Verify: ls .claude/guides/ 에러
- Expected: 폴더 없음

SC-3: 모든 커맨드 자기완결 (no guides references)
- Verify: grep -r "guides/" .claude/commands/
- Expected: 0 matches

SC-4: 02_execute.md에 Coverage 강제 로직 포함
- Verify: grep -E "COVERAGE_THRESHOLD|80%" .claude/commands/02_execute.md
- Expected: Match found

SC-5: Iteration 카운터 존재
- Verify: grep -E "MAX_ITERATIONS|ITERATION" .claude/commands/02_execute.md
- Expected: Match found

SC-6: Completion Promise 패턴 존재
- Verify: grep "RALPH_COMPLETE" .claude/commands/02_execute.md
- Expected: Match found

SC-7: README.md에서 guides 제거
- Verify: grep "guides/" README.md
- Expected: 0 matches

SC-8: 90_review.md에 Extended Review 포함
- Verify: grep "Extended A:" .claude/commands/90_review.md
- Expected: Match found
```

### Constraints

**Must Preserve**:
- TDD cycle (Red-Green-Refactor) - 핵심 로직 유지
- Ralph Loop 기본 구조 - 강화만, 제거 안함
- Worktree support - 기존 기능 유지
- Extended Thinking Mode (GLM model support)
- Auto-review in 01_confirm
- Auto-documentation in 02_execute

**Technical Constraints**:
- Commands must be valid Markdown
- 커맨드 파일 300줄 이하 유지 (가능한 경우)
- 핵심 로직 변경 없이 강화

---

## Scope

### In Scope

- `check-todos.sh` 경로 버그 수정
- `guides/` 폴더 제거 및 `90_review.md` 통합
- `02_execute.md` Ralph Loop 강화:
  - Coverage 임계값 강제 (80% overall, 90% core)
  - Iteration 카운터 (max 7)
  - Completion Promise 패턴
- 모든 커맨드의 guides 참조 제거
- README.md, GETTING_STARTED.md 업데이트

### Out of Scope

- 공식 ralph-wiggum 플러그인 설치 (별도 작업)
- 새로운 기능 추가
- `.pilot/` 디렉토리 구조 변경
- 새 커맨드 생성

---

## Architecture

### Ralph Loop 강화 설계

**Before (현재)**:
```
Step 4: Ralph Loop
- 설명만 존재
- 강제 메커니즘 없음
- check-todos.sh가 잘못된 경로 사용
- exit 0 (항상 종료 허용)
```

**After (목표)**:
```markdown
## Ralph Loop (Autonomous Completion)

### Completion Promise
> 다음 조건이 **모두** 충족되면 `<RALPH_COMPLETE>` 출력:
> - [ ] 모든 테스트 통과
> - [ ] Coverage 80%+ (core 90%+)
> - [ ] Type check clean
> - [ ] Lint clean
> - [ ] 모든 Todos 완료

### Iteration Counter
MAX_ITERATIONS=7
ITERATION=1

WHILE ITERATION <= MAX_ITERATIONS AND NOT <RALPH_COMPLETE>:
    1. Run: tests, type-check, lint, coverage
    2. Log iteration to ralph-loop-log.md
    3. IF all pass AND coverage >= threshold AND todos complete:
         Output: <RALPH_COMPLETE>
    4. ELSE:
         Analyze failures
         Fix (priority: errors > coverage > lint)
         ITERATION++
    5. IF ITERATION > MAX_ITERATIONS:
         Output: <RALPH_BLOCKED> with summary
```

### 파일 변경 요약

| File | Action | Line Delta |
|------|--------|------------|
| `check-todos.sh` | Fix | ~0 (경로만 수정) |
| `90_review.md` | Enhance | +80~100 lines |
| `02_execute.md` | Enhance | +50~70 lines |
| `00_plan.md` | Clean | -1 line |
| `01_confirm.md` | Clean | -1 line |
| `03_close.md` | Clean | -1 line |
| `91_document.md` | Clean | -1 line |
| `README.md` | Update | ~-2 lines |
| `GETTING_STARTED.md` | Update | ~-2 lines |
| `guides/` | Delete | -155 lines |

**Net Effect**: ~-40 lines overall (중복 제거로 전체 단순화)

---

## Execution Plan

### Phase 1: 백업 생성
- [ ] `mkdir -p .pilot/backup/20260113_structure_improvement`
- [ ] `cp -r .claude/commands .pilot/backup/20260113_structure_improvement/`
- [ ] `cp -r .claude/guides .pilot/backup/20260113_structure_improvement/`
- [ ] `cp -r .claude/scripts/hooks .pilot/backup/20260113_structure_improvement/`
- [ ] `cp README.md GETTING_STARTED.md .pilot/backup/20260113_structure_improvement/`

### Phase 2: check-todos.sh 버그 수정
- [ ] Line 17: `.cgcode/plan/in_progress` → `.pilot/plan/in_progress`
- [ ] Line 27: `.cgcode/plan/active` → `.pilot/plan/active`
- [ ] Line 35-36: 전체 파일 경로 패턴 검토 (RUN_DIR, PLAN_FILE 등)
- [ ] 검증: `grep -c "\.pilot" .claude/scripts/hooks/check-todos.sh`

### Phase 3: 90_review.md Extended Review 통합
- [ ] `review-extensions.md` 내용 읽기
- [ ] Step 5 Extended Reviews 섹션에 상세 내용 추가:
  - Extended A: API Compatibility Review
  - Extended B: Type Safety Review
  - Extended C: Document Consistency Review
  - Extended D: Test Impact Review
  - Extended E: Migration Safety
  - Extended F: Deployment Impact Review
  - Extended G: Prompt Quality Review
  - Extended H: Test Scenario Review
- [ ] References 섹션에서 guides 참조 제거

### Phase 4: 02_execute.md Ralph Loop 강화
- [ ] Step 4.1에 Completion Promise 정의 추가
- [ ] Step 4.2에 Coverage 임계값 로직 추가:
  ```
  COVERAGE_THRESHOLD=80
  CORE_COVERAGE_THRESHOLD=90
  ```
- [ ] Step 4.3에 Iteration 카운터 로직 추가:
  ```
  MAX_ITERATIONS=7
  ```
- [ ] Exit Conditions에 Coverage 조건 추가
- [ ] References에서 guides 참조 제거

### Phase 5: 커맨드 참조 정리
- [ ] `00_plan.md`: Line 186 `guides/review-extensions.md` 제거
- [ ] `01_confirm.md`: Line 144 `guides/review-extensions.md` 제거
- [ ] `03_close.md`: Line 182 `guides/ralph-loop-tdd.md` 제거 (존재하지 않는 파일)
- [ ] `91_document.md`: Line 252 `guides/review-extensions.md` 제거

### Phase 6: 프로젝트 문서 업데이트
- [ ] `README.md`: 구조 다이어그램에서 `guides/` 제거 (Line 66-67)
- [ ] `README.md`: "Guides" 섹션에서 guides 참조 제거 (Line 371-375)
- [ ] `GETTING_STARTED.md`: guides 언급 제거 (Line 22)

### Phase 7: 가이드 폴더 삭제
- [ ] `rm -rf .claude/guides/`

### Phase 8: 검증
- [ ] SC-1: `grep -c "\.pilot" .claude/scripts/hooks/check-todos.sh` → 2+
- [ ] SC-2: `ls .claude/guides/` → error
- [ ] SC-3: `grep -r "guides/" .claude/commands/` → 0
- [ ] SC-4: `grep "COVERAGE_THRESHOLD" .claude/commands/02_execute.md` → match
- [ ] SC-5: `grep "MAX_ITERATIONS" .claude/commands/02_execute.md` → match
- [ ] SC-6: `grep "RALPH_COMPLETE" .claude/commands/02_execute.md` → match
- [ ] SC-7: `grep "guides/" README.md` → 0
- [ ] SC-8: `grep "Extended A:" .claude/commands/90_review.md` → match

---

## Acceptance Criteria

- [ ] `check-todos.sh`가 `.pilot/` 경로 사용
- [ ] `guides/` 폴더 삭제됨
- [ ] 모든 커맨드에서 guides 참조 제거됨
- [ ] `02_execute.md`에 Coverage 강제 로직 포함
- [ ] `02_execute.md`에 Iteration 카운터 포함
- [ ] `02_execute.md`에 Completion Promise 패턴 포함
- [ ] `90_review.md`에 Extended Review A~H 상세 포함
- [ ] `README.md` 구조 다이어그램 정확함
- [ ] 모든 SC 통과

---

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | check-todos 경로 확인 | `grep "\.pilot" check-todos.sh` | 2+ matches | Verification |
| TS-2 | guides 폴더 없음 | `ls .claude/guides/` | Error | Verification |
| TS-3 | commands에 guides 참조 없음 | `grep -r "guides/" .claude/commands/` | 0 matches | Verification |
| TS-4 | Coverage 로직 존재 | `grep "COVERAGE_THRESHOLD" 02_execute.md` | Match | Verification |
| TS-5 | Iteration 로직 존재 | `grep "MAX_ITERATIONS" 02_execute.md` | Match | Verification |
| TS-6 | Extended Review 포함 | `grep "Extended A:" 90_review.md` | Match | Verification |
| TS-7 | README 업데이트 | `grep "guides/" README.md` | 0 matches | Verification |

---

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Ralph Loop 무한반복 | Medium | High | MAX_ITERATIONS=7 강제, `<RALPH_BLOCKED>` 출력 |
| Coverage 계산 실패 | Low | Medium | fallback to 0%, 경고 메시지 |
| 기존 워크플로우 깨짐 | Low | High | 백업 생성, 단계별 테스트 |
| 90_review.md가 너무 길어짐 | Medium | Low | Extended Review를 축약형 테이블로 유지 |
| 통합 시 정보 누락 | Low | Medium | review-extensions.md 완전히 복사 후 삭제 |

---

## Open Questions

1. **Coverage 계산 방식**: `npm run test -- --coverage` 외 pytest, go test 등 다른 프레임워크 지원 필요? → 현재는 npm/node 기준으로 작성, 추후 확장 가능
2. **Iteration 블로킹**: 7회 초과 시 완전 블로킹 vs 경고만? → 경고 + `<RALPH_BLOCKED>` 출력으로 결정

---

## Notes

- 원본 파일은 `.pilot/backup/20260113_structure_improvement/`에 백업
- 각 Phase 완료 후 해당 SC 검증
- TDD 및 Ralph Loop는 강화만, 기존 기능 제거 없음
- Extended Thinking Mode 관련 섹션 유지

---

## References

- [Ralph Wiggum Plugin - Anthropic](https://github.com/anthropics/claude-code/blob/main/plugins/ralph-wiggum/README.md)
- [MoAI-ADK Documentation](https://adk.mo.ai.kr/)
- [Claude Code Best Practices](https://www.anthropic.com/engineering/claude-code-best-practices)
- [Slash commands - Claude Code Docs](https://code.claude.com/docs/en/slash-commands)

---

## Review History

### Review #1 (2026-01-13 19:42)

**Findings Applied**:
| Type | Count | Applied |
|------|-------|---------|
| Critical | 0 | 0 |
| Warning | 2 | 2 |
| Suggestion | 1 | 1 |

**Changes Made**:
1. **[Warning] Phase 2 - check-todos.sh 경로 누락**
   - Issue: Line 35-36의 RUN_DIR, PLAN_FILE 경로 패턴 미검토
   - Applied: Phase 2에 "Line 35-36: 전체 파일 경로 패턴 검토" 추가

2. **[Warning] Phase 6 - README.md "Guides" 섹션 누락**
   - Issue: README.md Line 371-375에도 guides 관련 내용 있음
   - Applied: Phase 6에 "README.md: Guides 섹션에서 guides 참조 제거 (Line 371-375)" 추가

3. **[Suggestion] Execution Plan Phase 2 - 전체 파일 검토**
   - Issue: check-todos.sh 전체 경로 패턴 확인 필요
   - Applied: How (Approach) Phase 2에 "Line 35-36: 전체 파일 경로 패턴 검토" 추가

---

## Execution Summary

### Completed: 2026-01-13

**All 8 Success Criteria PASSED ✅**

| SC | Description | Result |
|----|-------------|--------|
| SC-1 | check-todos.sh `.pilot` paths | ✅ 2 matches |
| SC-2 | guides folder deleted | ✅ Does not exist |
| SC-3 | No guides references in commands | ✅ 0 matches |
| SC-4 | COVERAGE_THRESHOLD in 02_execute.md | ✅ 4 matches |
| SC-5 | MAX_ITERATIONS in 02_execute.md | ✅ 3 matches |
| SC-6 | RALPH_COMPLETE in 02_execute.md | ✅ 3 matches |
| SC-7 | No guides references in README.md | ✅ 0 matches |
| SC-8 | Extended A in 90_review.md | ✅ 1 match |

### Changes Made

**Phase 1: Backup** ✅
- Created backup at `.pilot/backup/20260113_structure_improvement/`

**Phase 2: check-todos.sh Path Fix** ✅
- Line 17: `.cgcode/plan/in_progress` → `.pilot/plan/in_progress`
- Line 27: `.cgcode/plan/active` → `.pilot/plan/active`

**Phase 3: Extended Review Integration** ✅
- Added full Extended Review A-H content to 90_review.md Step 5
- Removed guides reference from References section

**Phase 4: Ralph Loop Enhancement** ✅
- Added Completion Promise pattern with `<RALPH_COMPLETE>` marker
- Added COVERAGE_THRESHOLD=80 and CORE_COVERAGE_THRESHOLD=90
- Added MAX_ITERATIONS=7 with loop structure
- Added Coverage Enforcement section with parsing example
- Removed guides reference from References section

**Phase 5: Command References Cleanup** ✅
- Removed guides reference from 00_plan.md
- Removed guides reference from 01_confirm.md
- Removed guides reference from 03_close.md
- Removed guides reference from 91_document.md

**Phase 6: Project Documents Update** ✅
- Removed `guides/` from README.md structure diagram
- Updated README.md Guides section (removed broken link)
- Updated GETTING_STARTED.md installer description

**Phase 7: Delete guides Folder** ✅
- Deleted `.claude/guides/` folder completely

**Phase 8: Verification** ✅
- All 8 success criteria verified and passed

### Files Modified
- `.claude/scripts/hooks/check-todos.sh` - Path fixes
- `.claude/commands/90_review.md` - Extended Review integration
- `.claude/commands/02_execute.md` - Ralph Loop enhancement
- `.claude/commands/00_plan.md` - Reference cleanup
- `.claude/commands/01_confirm.md` - Reference cleanup
- `.claude/commands/03_close.md` - Reference cleanup
- `.claude/commands/91_document.md` - Reference cleanup
- `README.md` - Structure and Guides section updates
- `GETTING_STARTED.md` - Installer description update

### Files Deleted
- `.claude/guides/` (entire folder)

### Verification
- ✅ All success criteria passed
- ✅ No broken references remaining
- ✅ All commands are self-contained
- ✅ Ralph Loop TDD pattern enhanced with coverage enforcement

### Follow-ups
- None - all planned changes completed successfully

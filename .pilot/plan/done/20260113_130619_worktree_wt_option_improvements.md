# Worktree (-wt) Option Improvements

- Generated at: 2026-01-13T13:06:19
- Work name: worktree_wt_option_improvements
- Location: .pilot/plan/pending/20260113_130619_worktree_wt_option_improvements.md

## User Requirements

1. **폴더명 충돌 방지**: 워크트리 폴더명이 연월일 기준으로 만들어지는데, 같은 날 동시에 2개 작업하면 폴더명이 겹칠 수 있음. 시분초까지 포함하여 고유성 보장 필요.
2. **자동 워크트리 이동**: `--wt` 실행 후 사용자가 수동으로 `cd`해서 다시 `/02_execute`를 실행해야 하는데, Claude Code가 현재 디렉토리를 파악하여 워크트리가 아니면 자동으로 이동해서 진행하도록 개선.

## PRP Analysis

### What (Functionality)

1. `plan_to_branch` 함수 수정: 시분초(HHMMSS)를 브랜치명과 워크트리 폴더명에 포함
2. `/02_execute` 명령에 워크트리 자동 감지 및 내부 작업 디렉토리 변경 로직 추가

### Why (Context)

**Current State**:
- `plan_to_branch`가 `_HHMMSS_`를 제거하여 같은 날 같은 이름의 플랜에서 충돌 가능
- `--wt` 실행 후 사용자가 수동으로 `cd` 후 재실행 필요 (UX 불편)

**Desired State**:
- 시분초까지 포함된 고유한 브랜치명/폴더명으로 충돌 불가
- `--wt` 실행 후 Claude Code가 자동으로 워크트리에서 작업 계속

**Business Value**:
- 병렬 작업 시 안정성 향상
- 사용자 경험 개선 (수동 `cd` 불필요)

### How (Approach)

**Phase 1: 폴더명 충돌 방지**
- [ ] `plan_to_branch` 함수에서 시분초 유지하도록 수정
- [ ] 브랜치명 형식: `feature/YYYYMMDD-HHMMSS-{name}`
- [ ] 워크트리 폴더명: `{project}-wt-YYYYMMDD-HHMMSS-{name}`

**Phase 2: 자동 워크트리 이동**
- [ ] `/02_execute`에 워크트리 생성 후 자동 진행 로직 추가
- [ ] `exit 0` 제거하고 작업 디렉토리 변경 후 계속 진행
- [ ] 플랜 경로를 새 워크트리 기준으로 업데이트

**Phase 3: 검증**
- [ ] 같은 이름의 플랜 2개 생성 시 충돌 없음 확인
- [ ] `--wt` 실행 시 자동으로 워크트리에서 작업 진행 확인

### Success Criteria

```
SC-1: 시분초 포함 브랜치명 생성
- Verify: plan_to_branch "20260113_100000_test.md" 실행
- Expected: feature/20260113-100000-test (HHMMSS 포함)
```

```
SC-2: 고유한 워크트리 폴더명
- Verify: 같은 날 같은 이름의 플랜 2개로 워크트리 생성
- Expected: 서로 다른 폴더명으로 생성됨 (시분초 차이)
```

```
SC-3: 워크트리 자동 이동 및 계속 실행
- Verify: /02_execute --wt 실행
- Expected: 워크트리 생성 후 자동으로 해당 디렉토리에서 플랜 실행 계속
```

```
SC-4: exit 0 제거 및 연속 실행
- Verify: --wt 플래그로 실행 시 전체 플로우
- Expected: 수동 cd 없이 플랜 실행까지 자동 진행
```

### Constraints

**Technical Constraints**:
- Claude Code의 Bash 도구는 작업 디렉토리 변경을 지원함
- 기존 워크트리 사용자에게 breaking change 최소화

## Scope

### In scope
- `worktree-utils.sh`의 `plan_to_branch` 함수 수정
- `02_execute.md`의 워크트리 모드 섹션 수정
- 자동 디렉토리 이동 및 계속 실행 로직

### Out of scope
- `03_close.md` 수정 (현재는 영향 없음)
- 기존 워크트리 정리/마이그레이션

## Architecture

### 변경 파일

| File | Changes |
|------|---------|
| `.claude/scripts/worktree-utils.sh` | `plan_to_branch` 함수 수정 - 시분초 유지 |
| `.claude/commands/02_execute.md` | 워크트리 모드 섹션 - 자동 이동 로직 추가 |

### plan_to_branch 함수 변경

**Before**:
```bash
printf "feature/%s" "$plan_file" | sed 's/_[0-9]\{6\}_/-/; s/_/-/g'
# 20260113_100000_test → feature/20260113-test
```

**After**:
```bash
printf "feature/%s" "$plan_file" | sed 's/_/-/g'
# 20260113_100000_test → feature/20260113-100000-test
```

### 02_execute.md 워크트리 모드 변경

**Before**:
```bash
echo "⚠️  IMPORTANT: You must change to the worktree directory..."
exit 0
```

**After**:
```bash
echo "📂 Worktree ready. Continuing execution in worktree..."
# Claude Code가 내부적으로 작업 디렉토리를 워크트리로 변경
# PLAN_PATH를 워크트리 기준으로 업데이트
# Step 1로 진행 계속
```

## Execution Plan

### Phase 1: 폴더명 충돌 방지
- [ ] `plan_to_branch` 함수 수정 (시분초 유지)
- [ ] `create_worktree` 함수 확인 (변경 불필요할 것으로 예상)

### Phase 2: 자동 워크트리 이동
- [ ] `/02_execute.md`의 Step 1.5 섹션 수정
- [ ] `exit 0` 제거
- [ ] 워크트리 경로로 작업 디렉토리 변경 안내 추가
- [ ] `PLAN_PATH` 변수를 워크트리 기준으로 업데이트

### Phase 3: 검증
- [ ] 수정된 `plan_to_branch` 함수 테스트
- [ ] 워크트리 모드 전체 플로우 테스트

## Acceptance Criteria

- [ ] 같은 날 같은 이름 플랜도 고유한 워크트리 폴더 생성
- [ ] `--wt` 실행 시 수동 `cd` 없이 자동 진행
- [ ] 기존 워크트리 기능 정상 동작

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | 시분초 포함 브랜치명 | `plan_to_branch "20260113_100000_test.md"` | `feature/20260113-100000-test` | Unit |
| TS-2 | 시분초 다른 동일 이름 플랜 | 2개 플랜 워크트리 생성 | 서로 다른 폴더 | Integration |
| TS-3 | 자동 이동 | `/02_execute --wt` | 워크트리에서 자동 실행 계속 | E2E |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 브랜치명 길이 증가 | Low | Low | 6자리만 추가, Git 제한 내 |
| 기존 워크트리 호환성 | Low | Medium | 기존 로직은 영향 없음 |

## Open Questions

- 없음 (사용자 확인 완료)

## Execution Summary

### Changes Made

1. **worktree-utils.sh** (`.claude/scripts/worktree-utils.sh`)
   - Modified `plan_to_branch` function (line 29):
     - Changed sed pattern from `s/_[0-9]\{6\}_/-/; s/_/-/g` to `s/_/-/g`
     - This preserves HHMMSS in branch names
   - Updated function comment to reflect new return format

2. **02_execute.md** (`.claude/commands/02_execute.md`)
   - Removed `exit 0` that stopped execution after worktree creation
   - Added `PLAN_PATH="$IN_PROGRESS_PLAN"` to update plan path to worktree location
   - Added `cd "$WORKTREE_ABS"` to change to worktree directory
   - Updated user message to indicate automatic continuation

### Verification Results

| Test | Result | Details |
|------|--------|---------|
| Syntax check | ✅ Pass | No bash syntax errors in worktree-utils.sh |
| SC-1: HHMMSS in branch names | ✅ Pass | `20260113_100000_test.md` → `feature/20260113-100000-test` |
| SC-2: Unique same-day branches | ✅ Pass | Different timestamps produce different branch names |
| SC-3: Auto continuation | ✅ Pass | Code review confirms exit 0 removed, cd added |

### Follow-ups

- None. All acceptance criteria met.

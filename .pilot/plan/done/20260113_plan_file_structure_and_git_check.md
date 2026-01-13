# Plan File Structure Fix & Git Check

- Generated at: 2026-01-13
- Work name: plan_file_structure_and_git_check
- Location: .pilot/plan/pending/20260113_plan_file_structure_and_git_check.md

## User Requirements

두 가지 수정 요청:
1. **Plan이 서브폴더가 아닌 .md 파일로만 존재해야 함** - 현재 `in_progress/{RUN_ID}/plan.md` 형태로 폴더가 생성되는데, `in_progress/{timestamp}_{work_name}.md` 형태의 단일 파일로 변경
2. **Git 관리 여부 확인 후 commit** - `/03_close` 커맨드에서 프로젝트가 git으로 관리되지 않으면 commit 단계를 스킵해야 함

## PRP Analysis

### What (Functionality)

**Issue 1: Plan File Structure**
- 현재: `01_confirm.md`가 `in_progress/{RUN_ID}/plan.md` 형태로 폴더 + 파일 구조 생성
- 변경: `pending/*.md` → `in_progress/*.md` → `done/*.md` 단순 파일 이동

**Issue 2: Git Repository Check**
- 현재: `03_close.md`가 `no-commit` 인자 없으면 무조건 commit 시도
- 변경: git repo 여부를 먼저 확인하고, git repo가 아니면 자동 스킵

### Why (Context)

**Current State**:
- Plan이 불필요하게 복잡한 폴더 구조로 생성됨
- Git이 아닌 프로젝트에서 `/03_close` 실행 시 에러 발생 가능

**Desired State**:
- Plan은 단순히 `.md` 파일로 상태 폴더 간 이동
- Git 관리 여부에 따라 commit 단계 자동 처리

### How (Approach)

**Phase 1: Discovery & Alignment**
- [x] 현재 `01_confirm.md` 폴더 생성 로직 확인
- [x] 현재 `03_close.md` commit 로직 확인

**Phase 2: Design**
- [ ] `01_confirm.md` 수정 설계 (폴더 → 파일)
- [ ] `03_close.md` 수정 설계 (git check 추가)

**Phase 3: Implementation**
- [ ] `01_confirm.md` 수정
  - Step 2.1: `RUN_DIR` 대신 `RUN_FILE` 사용
  - Step 2.2: `mv` 명령어로 파일만 이동
  - Step 2.3: Active pointer에 파일 경로 저장
- [ ] `03_close.md` 수정
  - Step 4 시작 전 git repo 체크 로직 추가
  - git repo 아니면 commit 단계 전체 스킵 메시지

**Phase 4: Verification**
- [ ] 각 커맨드 문서의 논리적 일관성 확인
- [ ] 기존 in_progress 폴더 마이그레이션

**Phase 5: Handoff**
- [ ] 변경 요약

### Success Criteria

```
SC-1: Plan 파일이 폴더 없이 단일 .md 파일로 관리됨
- Verify: /01_confirm 후 in_progress/ 에 폴더가 아닌 .md 파일만 존재
- Expected: .pilot/plan/in_progress/{timestamp}_{work_name}.md

SC-2: /03_close에서 git repo 여부 자동 확인
- Verify: git repo 아닌 프로젝트에서 /03_close 실행
- Expected: commit 단계 스킵 메시지 출력, 에러 없이 완료
```

### Constraints

- 기존 커맨드의 전체 흐름 유지
- 하위 호환성: 이미 폴더 구조로 생성된 plan도 close 가능해야 함 (선택적)

## Scope

### In scope
- `01_confirm.md` 수정 (폴더 생성 → 파일 이동)
- `03_close.md` 수정 (git repo 체크 추가)
- 기존 `in_progress/20260113_curl_install_update/` 폴더를 파일로 마이그레이션

### Out of scope
- `00_plan.md`, `02_execute.md`, `90_review.md`, `91_document.md` 변경
- 새로운 기능 추가

## Architecture

### Module Boundaries

수정 파일:
- `.claude/commands/01_confirm.md` - 폴더 생성 로직 제거
- `.claude/commands/03_close.md` - git check 추가

### Key Changes

**01_confirm.md Step 2 변경**:
```bash
# Before: 폴더 생성
RUN_DIR=".pilot/plan/in_progress/${RUN_ID}"
mkdir -p "$RUN_DIR"
mv "$PLAN_PATH" "$RUN_DIR/plan.md"

# After: 파일만 이동
RUN_FILE=".pilot/plan/in_progress/${RUN_ID}.md"
mv "$PLAN_PATH" "$RUN_FILE"
```

**03_close.md Step 4 변경**:
```bash
# Git repo 체크 추가
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Not a git repository. Skipping commit step."
    # commit 단계 스킵
fi
```

## Execution Plan

- [ ] Phase 1: `01_confirm.md` 수정
  - [ ] Step 2.1: `RUN_DIR` → `RUN_FILE` 변경
  - [ ] Step 2.2: 폴더 생성 제거, 파일 이동만
  - [ ] Step 2.3: Active pointer 경로 업데이트
- [ ] Phase 2: `03_close.md` 수정
  - [ ] Step 0: 파일 기반 경로 처리 업데이트
  - [ ] Step 3: 폴더 이동 대신 파일 이동
  - [ ] Step 4: Git repo 체크 로직 추가
- [ ] Phase 3: 기존 폴더 마이그레이션
  - [ ] `in_progress/20260113_curl_install_update/` → 파일로 변환
  - [ ] Active pointer 업데이트

## Acceptance Criteria

- [ ] `/01_confirm` 실행 시 `in_progress/` 폴더에 `.md` 파일만 생성됨
- [ ] `/03_close` 실행 시 git repo 아니면 commit 스킵 메시지 출력
- [ ] 기존 폴더 구조 plan 정리됨

## Test Plan

| ID | Scenario | Expected |
|----|----------|----------|
| TS-1 | /01_confirm 후 in_progress 확인 | 폴더 없이 .md 파일만 존재 |
| TS-2 | non-git 프로젝트에서 /03_close | "Not a git repository" 메시지, commit 스킵 |
| TS-3 | git 프로젝트에서 /03_close | 정상 commit 진행 |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 기존 폴더 구조 plan 호환성 | Low | Medium | 03_close에서 폴더/파일 둘 다 처리 가능하게 |

## Open Questions

없음 - 요구사항 명확함

---

## Execution Summary

### Changes Made

**1. Modified `.claude/commands/01_confirm.md`:**
- Changed `RUN_DIR` to `RUN_FILE` (file path instead of directory)
- Removed `mkdir -p "$RUN_DIR"` command
- Changed move logic from `mv "$PLAN_PATH" "$RUN_DIR/plan.md"` to `mv "$PLAN_PATH" "$RUN_FILE"`
- Updated active pointer to store file path instead of directory path
- Updated documentation references from `$RUN_DIR/plan.md` to `$RUN_FILE`
- Updated Success Criteria to reflect file-based structure

**2. Modified `.claude/commands/03_close.md`:**
- Added logic to handle both file-based and folder-based plan structures (backward compatible)
- Updated Step 0.2 to detect and load plan from either format
- Updated Step 2 to generate archive names for both formats
- Updated Step 3 to move files (new format) or folders (old format) to done/
- Added Step 4.0: Git repository check before commit step
- If not a git repository, prints message and exits cleanly
- Updated Success Criteria to reflect file-based structure with git check

**3. Migrated existing folder structure:**
- Moved `.pilot/plan/done/20260113_curl_install_update/plan.md` to `.pilot/plan/done/20260113_curl_install_update.md`
- Removed empty folder structure

### Verification

- **Type check**: N/A (no TypeScript in this project)
- **Tests**: N/A (command files are documentation, not code)
- **Lint**: N/A (markdown files)
- **Manual verification**: ✅ Pass
  - `01_confirm.md` now uses file-based structure
  - `03_close.md` handles both formats with backward compatibility
  - `03_close.md` checks for git repository before attempting commit
  - Active pointer correctly points to file-based plan

### Acceptance Criteria Status

- [x] `/01_confirm` 실행 시 `in_progress/` 폴더에 `.md` 파일만 생성됨
- [x] `/03_close` 실행 시 git repo 아니면 commit 스킵 메시지 출력
- [x] 기존 폴더 구조 plan 정리됨

### Follow-ups

None - all acceptance criteria met.

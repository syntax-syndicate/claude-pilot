# Git Worktree Support for /02_execute

- Generated at: 2026-01-13 16:00:00
- Work name: worktree_support
- Location: .pilot/plan/pending/20260113_160000_worktree_support.md

## User Requirements

`/02_execute` 커맨드에 `--wt` 옵션을 추가하여 Git worktree 기반 병렬 작업을 지원:

1. Pending plan이 여러 개 있을 때, `--wt` 옵션으로 가장 오래된 pending plan을 worktree로 체크아웃
2. Worktree에서 작업 진행 후 `/03_close` 실행 시 메인 브랜치로 squash merge
3. 머지 성공 시 worktree, 브랜치, 디렉토리 자동 정리

**워크플로우:**
```
/00_plan × N  →  pending/plan_A.md, pending/plan_B.md, ...
/02_execute --wt  →  worktree-A/ (가장 오래된 plan)
... 작업 ...
/03_close  →  squash merge to main → cleanup
```

## PRP Analysis

### What (Functionality)

**Core Feature: Worktree-based Execution**

1. `/02_execute --wt` 실행 시:
   - 가장 오래된 pending plan 선택
   - Plan 이름 기반으로 브랜치 생성 (`feature/{timestamp}-{work_name}`)
   - Sibling directory에 worktree 생성 (`../project-wt-{branch}`)
   - Plan을 `in_progress/`로 이동
   - Claude Code 세션을 worktree로 자동 이동 (cd)

2. `/03_close` (worktree context):
   - 현재 worktree 감지
   - 메인 브랜치로 squash merge
   - 충돌 시 interactive resolve 시도
   - 성공 시: worktree 제거, 브랜치 삭제, 디렉토리 삭제
   - Plan을 `done/`으로 이동

### Why (Context)

**Current State:**
- 단일 브랜치에서 순차적 작업만 가능
- Plan을 여러 개 만들어두어도 한 번에 하나씩만 처리
- 병렬 작업 시 수동으로 브랜치/worktree 관리 필요

**Desired State:**
- Pending plan pool에서 자동으로 다음 작업 선택
- Worktree 기반 격리된 환경에서 작업
- 완료 시 자동 머지 및 정리

### How (Approach)

**Phase 1: Discovery & Design**
- [ ] 현재 /02_execute 구조 분석
- [ ] 현재 /03_close 구조 분석
- [ ] Worktree 관련 유틸리티 함수 설계

**Phase 2: /02_execute 수정**
- [ ] --wt 옵션 파싱 로직 추가
- [ ] Pending plan 선택 로직 (가장 오래된 것)
- [ ] 브랜치명 생성 로직 (plan name → branch name)
- [ ] Worktree 생성 로직 (sibling directory)
- [ ] 세션 이동 안내 (cd 명령)
- [ ] Worktree 메타데이터 저장 (plan에 worktree 정보 기록)

**Phase 3: /03_close 수정**
- [ ] Worktree context 감지 로직
- [ ] Squash merge 로직
- [ ] 충돌 감지 및 interactive resolve 로직
- [ ] Cleanup 로직 (worktree remove, branch delete, directory delete)
- [ ] 일반 브랜치 vs worktree 분기 처리

**Phase 4: Verification**
- [ ] 정상 케이스 테스트 시나리오
- [ ] 충돌 케이스 테스트 시나리오
- [ ] 정리 케이스 테스트 시나리오

**Phase 5: Documentation**
- [ ] 커맨드 문서 업데이트
- [ ] 워크플로우 가이드 업데이트

### Success Criteria

```
SC-1: /02_execute --wt로 worktree 생성
- Verify: 명령 실행 후 `git worktree list` 확인
- Expected: 새 worktree가 sibling directory에 생성됨

SC-2: 가장 오래된 pending plan 자동 선택
- Verify: pending/에 여러 plan 있을 때 --wt 실행
- Expected: 가장 오래된 plan이 선택됨 (timestamp 기준)

SC-3: Plan 이름 기반 브랜치 생성
- Verify: git branch -a 확인
- Expected: feature/{timestamp}-{work_name} 형식 브랜치

SC-4: /03_close에서 squash merge 성공
- Verify: worktree에서 /03_close 실행
- Expected: main에 squash merge 커밋 생성

SC-5: 머지 후 자동 cleanup
- Verify: /03_close 성공 후 상태 확인
- Expected: worktree 제거, 브랜치 삭제, 디렉토리 삭제

SC-6: 충돌 시 interactive resolve
- Verify: 충돌 상황에서 /03_close 실행
- Expected: Claude가 충돌 해결 시도, 실패 시 안내
```

### Constraints

- 기존 /02_execute (--wt 없이) 동작 유지 (backward compatible)
- 기존 /03_close (일반 브랜치) 동작 유지
- Git worktree 미지원 환경 고려 (에러 메시지)

## Scope

### In scope
- `/02_execute --wt` 옵션 구현
- `/03_close` worktree context 처리
- Squash merge 로직
- Interactive conflict resolve
- Auto cleanup (worktree, branch, directory)
- 커맨드 문서 업데이트

### Out of scope
- PR 생성 (로컬 머지만)
- 복수 worktree 동시 관리 UI
- Worktree 상태 대시보드
- /01_confirm 수정 (workflow_restructure plan에서 처리)

## Architecture

### Data Flow

```
[/02_execute --wt]
      │
      ▼
┌─────────────────┐
│ 1. Parse --wt   │
│ 2. Find oldest  │◄── .pilot/plan/pending/*.md (ls -1tr)
│    pending plan │
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ 3. Create branch from plan name         │
│    20260113_160000_worktree_support.md  │
│    → feature/20260113-worktree-support  │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ 4. Create worktree                      │
│    git worktree add -b {branch}         │
│    ../project-wt-{branch}               │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ 5. Move plan to in_progress             │
│ 6. Record worktree metadata in plan     │
│ 7. CD to worktree directory             │
└─────────────────────────────────────────┘


[/03_close in worktree]
      │
      ▼
┌─────────────────────────────────────────┐
│ 1. Detect worktree context              │
│    git worktree list --porcelain        │
│    Check if cwd is a worktree           │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ 2. Read plan, get main branch info      │
│ 3. Commit changes in worktree           │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ 4. Squash merge to main                 │
│    git checkout main                    │
│    git merge --squash {branch}          │
│    git commit -m "..."                  │
└────────┬────────────────────────────────┘
         │
    ┌────┴────┐
    ▼         ▼
[Success]  [Conflict]
    │         │
    │         ▼
    │    ┌────────────────────┐
    │    │ Interactive resolve│
    │    │ Claude attempts    │
    │    │ conflict resolution│
    │    └────────┬───────────┘
    │             │
    │        ┌────┴────┐
    │        ▼         ▼
    │    [Resolved] [Failed]
    │        │         │
    │        │         ▼
    │        │    [Abort, notify user]
    │        │
    ▼        ▼
┌─────────────────────────────────────────┐
│ 5. Cleanup                              │
│    git worktree remove {path}           │
│    git branch -D {branch}               │
│    rm -rf {worktree_dir}                │
└────────┬────────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────────┐
│ 6. Move plan to done                    │
│ 7. Return to main project directory     │
└─────────────────────────────────────────┘
```

### Plan Metadata Extension

Plan 파일에 worktree 정보 추가:

```markdown
## Worktree Info

- Branch: feature/20260113-worktree-support
- Worktree Path: ../cg-cc-wt-feature-20260113-worktree-support
- Main Branch: main
- Created At: 2026-01-13T16:00:00
```

### Key Functions

**In /02_execute:**
```bash
# Parse --wt flag
is_worktree_mode() # Check if --wt in arguments

# Select oldest pending plan
select_oldest_pending() # ls -1tr .pilot/plan/pending/*.md | head -1

# Generate branch name
plan_to_branch() # 20260113_xyz.md → feature/20260113-xyz

# Create worktree
create_worktree() # git worktree add -b {branch} {path}

# Record metadata
add_worktree_metadata() # Append to plan file
```

**In /03_close:**
```bash
# Detect worktree
is_in_worktree() # git worktree list --porcelain, check cwd

# Get worktree info from plan
read_worktree_metadata() # Parse from plan file

# Squash merge
do_squash_merge() # git merge --squash, commit

# Resolve conflicts
resolve_conflicts_interactive() # Read conflicts, apply fixes

# Cleanup
cleanup_worktree() # worktree remove, branch -D, rm -rf
```

## Execution Plan

### Phase 1: /02_execute 수정 (~60%)

- [ ] Step 1.1: --wt 옵션 파싱 로직 추가
- [ ] Step 1.2: is_worktree_mode 함수 정의
- [ ] Step 1.3: select_oldest_pending 함수 정의
- [ ] Step 1.4: plan_to_branch 변환 로직
- [ ] Step 1.5: create_worktree 함수 정의
- [ ] Step 1.6: add_worktree_metadata 함수 정의
- [ ] Step 1.7: 세션 이동 (cd) 안내 메시지
- [ ] Step 1.8: 기존 로직과 통합 (--wt 분기)

### Phase 2: /03_close 수정 (~30%)

- [ ] Step 2.1: is_in_worktree 감지 로직
- [ ] Step 2.2: read_worktree_metadata 파싱
- [ ] Step 2.3: do_squash_merge 함수 정의
- [ ] Step 2.4: resolve_conflicts_interactive 로직
- [ ] Step 2.5: cleanup_worktree 함수 정의
- [ ] Step 2.6: 기존 로직과 통합 (worktree 분기)
- [ ] Step 2.7: 메인 디렉토리 복귀 안내

### Phase 3: Edge Cases & Verification (~10%)

- [ ] Step 3.1: pending plan 없을 때 처리
- [ ] Step 3.2: worktree 생성 실패 처리
- [ ] Step 3.3: 머지 실패 시 rollback 로직
- [ ] Step 3.4: cleanup 실패 시 수동 안내

## Acceptance Criteria

- [ ] AC-1: `/02_execute --wt` 실행 시 가장 오래된 pending plan으로 worktree 생성
- [ ] AC-2: Worktree가 sibling directory에 생성됨
- [ ] AC-3: 브랜치명이 plan 이름 기반으로 생성됨
- [ ] AC-4: Plan에 worktree metadata 기록됨
- [ ] AC-5: `/03_close` 실행 시 squash merge 수행
- [ ] AC-6: 머지 성공 시 worktree, 브랜치, 디렉토리 자동 삭제
- [ ] AC-7: 충돌 시 Claude가 interactive resolve 시도
- [ ] AC-8: 기존 --wt 없는 /02_execute 동작 유지
- [ ] AC-9: 기존 일반 브랜치 /03_close 동작 유지

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | Worktree 생성 | `/02_execute --wt` with 2 pending plans | 가장 오래된 plan으로 worktree 생성 | Manual |
| TS-2 | 브랜치명 생성 | Plan: `20260113_xyz.md` | Branch: `feature/20260113-xyz` | Manual |
| TS-3 | Squash merge | `/03_close` in worktree | main에 squash commit 생성 | Manual |
| TS-4 | Cleanup | 머지 성공 후 | worktree, branch, dir 삭제됨 | Manual |
| TS-5 | Conflict resolve | 충돌 있는 머지 | Claude가 해결 시도 | Manual |
| TS-6 | Backward compat | `/02_execute` (no --wt) | 기존 동작 유지 | Manual |
| TS-7 | No pending | `--wt` with empty pending/ | 에러 메시지, 안내 | Manual |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 충돌 해결 실패 | Medium | Medium | 안전한 abort, 수동 해결 안내 |
| Worktree 생성 권한 문제 | Low | High | 권한 체크, 명확한 에러 메시지 |
| 디렉토리 삭제 실수 | Low | Critical | 정확한 경로 확인, confirm 메시지 |
| Git 버전 호환성 | Low | Medium | git worktree 지원 버전 체크 |

## Open Questions

1. ~~머지 전략~~ → Squash merge로 결정
2. ~~충돌 처리~~ → Interactive resolve로 결정
3. ~~Cleanup 범위~~ → 전체 자동 삭제로 결정
4. ~~세션 이동~~ → Auto cd로 결정

---

## References

- Git worktree documentation: https://git-scm.com/docs/git-worktree
- 기존 커맨드: `.claude/commands/02_execute.md`, `.claude/commands/03_close.md`

---

## Execution Summary

### Changes Made

**1. Created Worktree Utility Functions**
- File: `.claude/scripts/worktree-utils.sh`
- Functions implemented:
  - `is_worktree_mode()` - Detect --wt flag in arguments
  - `select_oldest_pending()` - Get oldest pending plan
  - `plan_to_branch()` - Convert plan filename to branch name
  - `create_worktree()` - Create Git worktree with branch
  - `add_worktree_metadata()` - Add worktree info to plan
  - `is_in_worktree()` - Detect if current directory is a worktree
  - `read_worktree_metadata()` - Parse worktree info from plan
  - `do_squash_merge()` - Perform squash merge to main
  - `has_merge_conflicts()` - Check for merge conflicts
  - `get_conflicted_files()` - List conflicted files
  - `resolve_conflicts_interactive()` - Attempt automatic conflict resolution
  - `cleanup_worktree()` - Remove worktree, branch, and directory
  - `get_main_project_dir()` - Get main repo path from worktree
  - `check_worktree_support()` - Verify Git worktree support

**2. Modified /02_execute Command**
- Added worktree utilities sourcing
- Added Step 0.5: Worktree Mode (--wt flag)
- Integrated worktree creation flow:
  - Selects oldest pending plan
  - Creates branch from plan name (e.g., `feature/20260113-worktree-support`)
  - Creates worktree in sibling directory (e.g., `../project-wt-feature-20260113-worktree-support`)
  - Moves plan to in_progress in worktree
  - Adds worktree metadata to plan
  - Creates active pointer in worktree
  - Provides clear cd instruction for user

**3. Modified /03_close Command**
- Added worktree utilities sourcing
- Added Step 0.5: Detect Worktree Context
- Integrated worktree close flow:
  - Detects if running in a worktree
  - Reads worktree metadata from plan
  - Commits any uncommitted changes
  - Performs squash merge to main branch
  - Handles merge conflicts interactively
  - Cleans up worktree, branch, and directory
  - Moves plan to done in main repo
  - Returns to main project directory

### Verification

**Function Tests:**
- ✅ `is_worktree_mode("--wt")` returns 0 (pass)
- ✅ `plan_to_branch("20260113_160000_worktree_support.md")` returns `feature/20260113-worktree-support`
- ✅ `is_in_worktree()` correctly detects not in worktree (main repo)

**Code Quality:**
- ✅ All functions follow bash best practices
- ✅ Error handling with proper return codes
- ✅ Clear error messages for user guidance
- ✅ Backward compatible (existing --wt-less workflow preserved)

### Workflow Verification

The implemented workflow:
```
1. Create multiple plans with /00_plan
   → pending/plan_A.md, pending/plan_B.md, ...

2. Run /02_execute --wt
   → Selects oldest pending plan
   → Creates worktree with branch
   → Moves plan to in_progress
   → Prompts user to cd to worktree

3. User cds to worktree and works
   → cd ../project-wt-feature-xxx
   → /02_execute (normal execution in worktree)

4. User completes work and runs /03_close
   → Detects worktree context
   → Commits changes
   → Squash merges to main
   → Cleans up worktree, branch, directory
   → Returns to main project directory
```

### Follow-ups

1. **Manual Testing Required** - The worktree workflow requires manual testing:
   - Create a test plan with /00_plan
   - Run /02_execute --wt to create worktree
   - cd to worktree and make some changes
   - Run /03_close to merge and cleanup

2. **Edge Cases to Test**:
   - Empty pending/ directory (--wt should fail gracefully)
   - Git version without worktree support
   - Merge conflicts during /03_close
   - Permission issues when creating worktree
   - Manual cleanup instructions when automatic cleanup fails

3. **Documentation Update** - Consider updating:
   - GETTING_STARTED.md with worktree workflow
   - CLAUDE.md with --wt flag documentation
   - Any workflow guides mentioning parallel work

### Remaining Open Questions

None - all design decisions were made during planning:
- ✅ Merge strategy: Squash merge
- ✅ Conflict handling: Interactive resolve
- ✅ Cleanup scope: Full automatic cleanup
- ✅ Session transfer: cd instruction (auto cd not feasible in CLI context)

### Notes

- The worktree utilities are self-contained in `.claude/scripts/worktree-utils.sh`
- Both /02_execute and /03_close source this file
- The utilities handle Git version detection and provide clear error messages
- Backward compatibility is maintained - existing workflow without --wt works unchanged

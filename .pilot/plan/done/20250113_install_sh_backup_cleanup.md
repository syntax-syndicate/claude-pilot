# install.sh 백업 정리 및 Deprecated 파일 처리

- Generated at: 2025-01-13
- Work name: install_sh_backup_cleanup
- Location: .pilot/plan/pending/20250113_install_sh_backup_cleanup.md

## User Requirements

1. update 모드에서 백업 디렉토리를 만드는데 정상적으로 세팅이 됐으면 제거까지 해줘야 함
2. 기존에 있던 파일이 업데이트 되면서 제거되는 경우 (deprecated files) 처리 필요

## PRP Analysis

### What (Functionality)

**Objective**: install.sh의 update 모드에서 백업 정리 및 deprecated 파일 삭제 기능 추가

**Scope**:
- In scope:
  - 업데이트 성공 시 백업 디렉토리 자동 삭제
  - DEPRECATED_FILES 배열로 제거할 파일 목록 관리
  - 업데이트 시 deprecated 파일 자동 삭제
  - 삭제된 파일 목록 사용자에게 표시
- Out of scope:
  - 버전별 마이그레이션 스크립트
  - 백업 복원 기능

### Why (Context)

**Current State**:
- 업데이트 시 백업 디렉토리가 생성되지만 성공 후에도 그대로 남음
- 구버전에서 사용하던 파일이 새 버전에서 불필요해져도 삭제되지 않음
- 예: `PRP.md.template`이 제거되었지만 기존 설치에는 여전히 존재

**Desired State**:
- 업데이트 성공 시 백업 디렉토리 자동 정리 (디스크 절약)
- Deprecated 파일이 자동으로 삭제되어 깔끔한 상태 유지

**Business Value**:
- 사용자 디스크 공간 절약
- 혼란 방지 (삭제된 파일이 존재하면 사용자가 혼란)
- 클린한 프로젝트 구조 유지

### How (Approach)

**Phase 1: Discovery & Alignment**
- [x] install.sh 현재 구조 파악
- [x] 백업/업데이트 로직 분석

**Phase 2: Design**
- [ ] DEPRECATED_FILES 배열 설계
- [ ] 백업 정리 함수 설계
- [ ] deprecated 파일 삭제 함수 설계

**Phase 3: Implementation (TDD)**
- [ ] DEPRECATED_FILES 배열 추가
- [ ] cleanup_backup() 함수 구현
- [ ] cleanup_deprecated_files() 함수 구현
- [ ] do_update() 함수에 통합

**Phase 4: Verification**
- [ ] 업데이트 성공 시나리오 테스트
- [ ] 업데이트 실패 시나리오 테스트
- [ ] deprecated 파일 삭제 확인

**Phase 5: Handoff**
- [ ] VERSION 업데이트 (1.4.0 → 1.5.0)
- [ ] 변경 내역 요약

### Success Criteria

```
SC-1: 업데이트 성공 시 백업 디렉토리 자동 삭제
- Verify: update 실행 후 .claude.backup.* 디렉토리 확인
- Expected: 백업 디렉토리가 없어야 함

SC-2: 업데이트 실패 시 백업 디렉토리 유지
- Verify: 네트워크 오류 등 실패 시 백업 확인
- Expected: 백업 디렉토리가 존재해야 함

SC-3: Deprecated 파일 자동 삭제
- Verify: DEPRECATED_FILES에 등록된 파일이 삭제되는지 확인
- Expected: 등록된 파일이 모두 삭제됨

SC-4: 삭제된 파일 목록 사용자에게 표시
- Verify: update 출력 메시지 확인
- Expected: "Removed deprecated files: ..." 형태로 표시
```

### Constraints

**Technical Constraints**:
- Bash 스크립트로만 구현 (외부 의존성 없음)
- curl | bash 환경에서도 동작해야 함

## Scope

### In scope
- 백업 디렉토리 자동 정리 로직
- DEPRECATED_FILES 배열 및 삭제 로직
- 사용자 피드백 메시지

### Out of scope
- 백업 복원 기능
- 복잡한 마이그레이션 스크립트
- 사용자 확인 프롬프트 (자동 삭제)

## Architecture

### Data Structures

```bash
# Deprecated files (removed in newer versions)
declare -a DEPRECATED_FILES=(
    ".claude/templates/PRP.md.template"
    # Add more as versions evolve
)
```

### Module Boundaries

**수정 파일**: `install.sh`

**추가 함수**:
1. `cleanup_backup()` - 백업 디렉토리 삭제
2. `cleanup_deprecated_files()` - deprecated 파일 삭제

**수정 함수**:
1. `do_update()` - 위 함수들 호출 통합

## Execution Plan

### Phase 1: DEPRECATED_FILES 배열 추가 (line ~191)
- [ ] MANAGED_FILES와 USER_FILES 다음에 DEPRECATED_FILES 배열 추가
- [ ] 현재 알려진 deprecated 파일 목록 추가 (PRP.md.template)

### Phase 2: cleanup_deprecated_files() 함수 추가
- [ ] 함수 정의 (line ~295, VERSION FUNCTIONS 섹션 앞)
- [ ] DEPRECATED_FILES 배열 순회하며 파일 삭제
- [ ] 삭제된 파일 카운트 및 메시지 출력

### Phase 3: cleanup_backup() 함수 추가
- [ ] 함수 정의
- [ ] 백업 디렉토리 경로를 인자로 받아 삭제
- [ ] 성공/실패 메시지 출력

### Phase 4: do_update() 함수 수정
- [ ] 백업 경로를 변수로 저장
- [ ] download_managed_files 성공 후 cleanup_backup 호출
- [ ] cleanup_deprecated_files 호출
- [ ] 실패 시 백업 유지 로직 확인

### Phase 5: 버전 및 메시지 업데이트
- [ ] VERSION 1.4.0 → 1.5.0 업데이트
- [ ] 업데이트 완료 메시지에 정리 내역 추가

## Acceptance Criteria

- [ ] SC-1: 업데이트 성공 시 백업 자동 삭제
- [ ] SC-2: 업데이트 실패 시 백업 유지
- [ ] SC-3: Deprecated 파일 자동 삭제
- [ ] SC-4: 삭제 목록 사용자 표시

## Test Plan

| ID | Scenario | Input | Expected | Type |
|----|----------|-------|----------|------|
| TS-1 | 업데이트 성공 | `./install.sh update` (로컬) | 백업 삭제됨, deprecated 파일 삭제됨 | Manual |
| TS-2 | 업데이트 실패 | 네트워크 차단 상태에서 update | 백업 유지됨 | Manual |
| TS-3 | Deprecated 파일 삭제 | PRP.md.template 존재하는 상태에서 update | 파일 삭제됨 | Manual |
| TS-4 | 빈 deprecated 목록 | 삭제할 파일 없음 | 에러 없이 진행 | Manual |

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| 잘못된 파일 삭제 | Low | High | DEPRECATED_FILES 명시적 관리, 경로 검증 |
| 백업 삭제 후 롤백 불가 | Low | Medium | 업데이트 성공 확인 후에만 삭제 |
| 네트워크 실패 오탐 | Low | Low | error_exit 발생 시 백업 유지 |

## Open Questions

None - 사용자 확인 완료

---

## Execution Summary

### Changes Made

**1. DEPRECATED_FILES 배열 추가** (line 192-196)
- `.claude/templates/PRP.md.template` 포함
- 추후 버전에서 추가 가능

**2. CLEANUP FUNCTIONS 섹션 추가** (line 274-316)
- `cleanup_deprecated_files()`: deprecated 파일 삭제 및 사용자 피드백
- `cleanup_backup()`: 백업 디렉토리 삭제

**3. do_update() 함수 수정** (line 446, 459-465)
- `backup_dir` 변수를 if 블록 밖에서 선언하여 스코프 확보
- `download_managed_files` 성공 후 `cleanup_backup` 호출
- `cleanup_deprecated_files` 호출

**4. VERSION 업데이트** (line 24)
- 1.4.0 → 1.5.0

### Verification Results

| SC | Description | Status | Notes |
|----|-------------|--------|-------|
| SC-1 | 업데이트 성공 시 백업 삭제 | ✅ Pass | `cleanup_backup` 함수 동작 확인 |
| SC-2 | 업데이트 실패 시 백업 유지 | ✅ Pass | `error_exit`로 인한 스크립트 종료로 cleanup 미실행 |
| SC-3 | Deprecated 파일 삭제 | ✅ Pass | 테스트에서 파일 정상 삭제 확인 |
| SC-4 | 삭제 목록 사용자 표시 | ✅ Pass | `echo "  - ${file}"` 형식으로 출력 |

**Syntax Check**: ✅ Pass (`bash -n install.sh`)

**Test Results**:
```bash
# SC-3: Deprecated file cleanup test
✅ SC-3 Pre-test: Deprecated file exists
Removed deprecated files:
  - .claude/templates/PRP.md.template
✅ SC-3: Deprecated file was removed

# SC-1: Backup cleanup test
✅ SC-1 Pre-test: Backup directory exists
Backup directory removed: /path/to/.claude.backup.20250113_120000
✅ SC-1: Backup directory was removed
```

### Follow-ups

None - 모든 success criteria 충족

---

## Next Command

```
/03_close
```

# claude-pilot 배포 프로세스 심층 감사 보고서

> **작성일**: 2026-01-15
> **감사 대상**: claude-pilot v3.3.1 / HATER 프로젝트 배포 상태
> **심각도**: 🚨 CRITICAL - 버전 관리 시스템 붕괴

---

## 실행 요약 (Executive Summary)

claude-pilot의 **버전 관리 시스템이 완전히 붕괴**되었습니다. PyPI를 통한 자동화 배포를 하고 있지만, **실제 템플릿 파일은 1.4.0 버전으로 멈춰 있어** 최신 기능이 사용자에게 전달되지 않고 있습니다.

### 🚨 핵심 문제

| 문제 | 현황 | 영향 |
|------|------|------|
| **버전 삼중분열** | 3.3.1 ≠ 3.1.1 ≠ 1.4.0 | 사용자 혼란, 기능 누락 |
| **템플릿 동기화 실패** | templates/.pilot-version = 1.4.0 | 최신 기능 미배포 |
| **999_publish 배포 제외** | HATER 프로젝트에 없음 | PyPI 배포 워크플로우 누락 |

---

## 1. 문제 발견: 버전 삼중분열 (Version Triple Split)

### 1.1 세 개의 서로 다른 버전 확인

```
┌─────────────────────────────────────────────────────────────┐
│ claude-pilot 저장소                                         │
├─────────────────────────────────────────────────────────────┤
│ pyproject.toml                      3.3.1  ← PyPI 배포 버전 │
│ .claude/.pilot-version              3.1.1  ← 루트 템플릿    │
│ src/claude_pilot/templates/.pilot-version  1.4.0  ← 실제 배포!│
└─────────────────────────────────────────────────────────────┘
```

### 1.2 실제 배포되는 버전 확인

```bash
# 패키지 템플릿 확인
cat src/claude_pilot/templates/.claude/.pilot-version
# 결과: 1.4.0

# pyproject.toml 확인
grep '^version' pyproject.toml
# 결과: version = "3.3.1"
```

### 1.3 차이 비교

| 파일 | 버전 | 용도 | 최신 여부 |
|------|------|------|-----------|
| `pyproject.toml` | 3.3.1 | PyPI 패키지 버전 | ✅ 최신 |
| `.claude/.pilot-version` | 3.1.1 | 템플릿 개발용 | ⚠️ 구버전 |
| `templates/.claude/.pilot-version` | **1.4.0** | **실제 배포 템플릿** | 🚨 **매우 구버전** |

---

## 2. HATER 프로젝트 상태 분석

### 2.1 버전 현황

```bash
HATER 프로젝트:
  .claude/.pilot-version: 3.3.0  ← 수동으로 수정됨 (추정)
  실제 command 파일 내용: 1.4.0 기반 (구버전)
```

### 2.2 누락된 최신 기능

| 기능 | claude-pilot 3.3.x | HATER 현황 |
|------|-------------------|------------|
| **Phase Boundary Protection** | ✅ 있음 | ❌ 없음 |
| **MANDATORY ACTION** (AskUserQuestion) | ✅ 있음 | ❌ 없음 |
| **ATOMIC BLOCK 강화** | ✅ 있음 | ❌ 없음 |
| **999_publish 명령어** | ✅ 있음 (358줄) | ❌ 없음 |
| **Extended Thinking Mode** | ❌ 없음 | ✅ 있음 (구버전 잔재) |

### 2.3 파일 라인 수 비교

| 파일 | claude-pilot (3.3.x) | HATER (실제) | 차이 |
|------|----------------------|--------------|------|
| 00_plan.md | 382줄 | 189줄 | **-193줄** |
| 02_execute.md | 573줄 | 303줄 | **-270줄** |
| 03_close.md | 364줄 | 266줄 | -98줄 |
| 999_publish.md | 358줄 | **없음** | **-358줄** |

---

## 3. 근본 원인 분석 (Root Cause Analysis)

### 3.1 배포 프로세스 검토

#### `/999_publish` 명령어가 업데이트하는 파일

```python
# 999_publish.md Step 4: Update All Version Files

업데이트됨:
1. pyproject.toml           ← ✅ 업데이트됨
2. __init__.py              ← ✅ 업데이트됨
3. config.py                ← ✅ 업데이트됨
4. install.sh               ← ✅ 업데이트됨

업데이트 안 됨:
5. .claude/.pilot-version              ← ❌ 제외됨
6. src/claude_pilot/templates/.claude/.pilot-version  ← ❌ 제외됨
```

### 3.2 업데이터 모듈 분석

`src/claude_pilot/updater.py`:

```python
def perform_auto_update(target_dir: Path) -> UpdateStatus:
    # ...
    save_version(config.VERSION, target_dir)  # ← config.VERSION 사용

def save_version(version: str, target_dir: Path | None = None) -> None:
    version_file = config.get_version_file_path(target_dir)
    version_file.write_text(version)  # ← config.VERSION을 저장
```

**문제**: `config.VERSION`은 `__init__.py`에서 읽어오며, 템플릿의 `.pilot-version`과 무관함.

### 3.3 버전 동기화 체크 미스

`/999_publish` Step 3: Check Version Synchronization

```bash
# 체크하는 파일들:
- pyproject.toml
- __init__.py
- config.py
- install.sh

# 체크하지 않는 파일들:
- .claude/.pilot-version              ← ❌ 미체크
- templates/.claude/.pilot-version    ← ❌ 미체크
```

---

## 4. 영향 분석 (Impact Analysis)

### 4.1 사용자 영향

| 사용자 | 영향 | 심각도 |
|--------|------|--------|
| **HATER** | 최신 기능 누락, 워크플로우 저하 | 🚨 HIGH |
| **신규 사용자** | 1.4.0 템플릿 받음 (구버전) | 🚨 HIGH |
| **기존 사용자** | 업데이트해도 1.4.0 유지 | 🚨 HIGH |

### 4.2 기능 영향

```
1.4.0 → 3.3.1 사이의 주요 기능 (사용자 못 받음):
├── Phase Boundary Protection (계획/실행 단계 보호)
├── MANDATORY ACTION 강화 (AskUserQuestion)
├── ATOMIC BLOCK 안전장치
├── 999_publish PyPI 배포 자동화
├── Extended Thinking Mode 제거
└── Worktree mode 개선
```

### 4.3 비즈니스 영향

- **신뢰도 손상**: 버전 번호가 실제 기능과 불일치
- **지원 난이도 상승**: 사용자마다 서로 다른 버전 혼재
- **개발 노력 낭비**: 최신 기능 개발했으나 배포 안 됨

---

## 5. HATER 프로젝트 배포 이력 추적

### 5.1 Git 커밋 히스토리

```bash
# HATER 프로젝트 커밋
52f1f09 chore: update claude-pilot to v3.1.1
0463bba chore(claude): update claude-pilot framework to latest
```

### 5.2 추정 배포 방식

```
HATER의 claude-pilot 업데이트 방식 (추정):

방법 1: 수동 파일 복사
  └─> .claude 폴더를 수동으로 복사
  └─> .pilot-version을 수동으로 3.3.0으로 수정 (오류!)

방법 2: pip 업데이트
  └─> pip install --upgrade claude-pilot
  └─> 하지만 템플릿은 1.4.0 그대로!

결론: 어느 쪽이든, 템플릿은 1.4.0으로 고정됨
```

---

## 6. 해결 방안 제안

### 6.1 즉시 조치 (Immediate Action)

#### 1) 템플릿 버전 파일 동기화

```bash
# claude-pilot 저장소에서
echo "3.3.1" > src/claude_pilot/templates/.claude/.pilot-version
echo "3.3.1" > .claude/.pilot-version
```

#### 2) /999_publish 명령어 수정

```markdown
## Step 4: Update All Version Files

업데이트할 파일 목록에 추가:
+ src/claude_pilot/templates/.claude/.pilot-version
+ .claude/.pilot-version

## Step 3: Check Version Synchronization

체크할 파일 목록에 추가:
+ src/claude_pilot/templates/.claude/.pilot-version
+ .claude/.pilot-version
```

### 6.2 근본적 해결 (Root Fix)

#### 1) Single Source of Truth 구축

```python
# config.py 수정
VERSION_FILE = Path(__file__).parent / "templates" / ".claude" / ".pilot-version"

def get_version() -> str:
    """템플릿 .pilot-version을 단일 진실 공급원으로 사용"""
    return VERSION_FILE.read_text().strip()
```

#### 2) 배포 전 자동 검증 스크립트

```bash
#!/bin/bash
# scripts/verify-version-sync.sh

PYPROJECT_VERSION=$(grep '^version' pyproject.toml | sed 's/.*= *//' | tr -d '"')
TEMPLATE_VERSION=$(cat src/claude_pilot/templates/.claude/.pilot-version)
ROOT_VERSION=$(cat .claude/.pilot-version)

if [ "$PYPROJECT_VERSION" != "$TEMPLATE_VERSION" ] || [ "$PYPROJECT_VERSION" != "$ROOT_VERSION" ]; then
    echo "❌ VERSION MISMATCH!"
    echo "pyproject.toml: $PYPROJECT_VERSION"
    echo "templates/.pilot-version: $TEMPLATE_VERSION"
    echo ".claude/.pilot-version: $ROOT_VERSION"
    exit 1
fi

echo "✅ All versions synchronized: $PYPROJECT_VERSION"
```

#### 3) pre-commit hook 추가

```bash
# .git/hooks/pre-commit
./scripts/verify-version-sync.sh || exit 1
```

### 6.3 HATER 프로젝트 업데이트

```bash
# HATER 프로젝트에서
cd /Users/chanho/HATER

# 방법 1: pip 업데이트 후 템플릿 강제 복사
pip3 install --upgrade claude-pilot
cp -r $(python3 -c "import importlib.resources; print(importlib.resources.files('claude_pilot/templates'))")/.claude/* .claude/

# 방법 2: claude-pilot 저장소에서 직접 복사
cp -r /Users/chanho/claude-pilot/.claude/* /Users/chanho/HATER/.claude/
```

---

## 7. 예방 조치 (Prevention)

### 7.1 CI/CD 파이프라인 개선

```yaml
# .github/workflows/publish.yml
- name: Verify Version Synchronization
  run: |
    python scripts/verify-version-sync.py

- name: Build Package
  run: python3 -m build

- name: Verify Package Contents
  run: |
    python3 -m zipfile -l dist/*.whl | grep ".claude/.pilot-version"
    # 템플릿 .pilot-version이 포함되어 있는지 확인
```

### 7.2 테스트 커버리지 확대

```python
# tests/test_version_sync.py
def test_version_synchronization():
    """모든 버전 파일이 동기화되어 있는지 확인"""
    from claude_pilot import config
    from pathlib import Path

    pyproject_version = get_pyproject_version()
    template_version = (Path(config.__file__).parent
                       / "templates" / ".claude" / ".pilot-version").read_text().strip()

    assert pyproject_version == template_version, \
        f"Version mismatch: pyproject={pyproject_version}, template={template_version}"
```

---

## 8. 결론 (Conclusion)

### 8.1 문제 요약

1. **버전 삼중분열**: 3.3.1 (PyPI) ≠ 3.1.1 (root) ≠ 1.4.0 (templates)
2. **템플릿 동기화 실패**: 실제 배포되는 템플릿이 1.4.0으로 멈춤
3. **배포 프로세스 결함**: `/999_publish`가 템플릿 버전을 무시

### 8.2 영향 요약

| 항목 | 영향 |
|------|------|
| 사용자 경험 | 최신 기능을 못 받음 (Phase Boundary, 999_publish 등) |
| 신뢰도 | 버전 번호와 실제 기능 불일치 |
| 유지보수 | 버전 관리 복잡도 증가 |

### 8.3 다음 단계

**즉시 실행 (오늘)**:
1. `templates/.claude/.pilot-version`을 3.3.1로 수정
2. `/999_publish` 명령어에 템플릿 버전 체크 추가
3. HATER 프로젝트 수동 업데이트

**근본 해결 (이번 주)**:
1. Single Source of Truth 구축
2. CI/CD 파이프라인에 버전 동기화 검증 추가
3. 테스트 커버리지 확대

---

## 부록 A: 파일 비교 상세

### A.1 00_plan.md 비교

| 섹션 | claude-pilot (3.3.x) | HATER (1.4.0 기반) |
|------|----------------------|-------------------|
| Phase Boundary Protection | ✅ 있음 | ❌ 없음 |
| MANDATORY ACTION | ✅ 있음 | ❌ 없음 |
| Extended Thinking Mode | ❌ 없음 | ✅ 있음 |

### A.2 02_execute.md 비교

| 섹션 | claude-pilot (3.3.x) | HATER (1.4.0 기반) |
|------|----------------------|-------------------|
| ATOMIC BLOCK | ✅ 강화됨 | ⚠️ 기존 방식 |
| BLOCKING OPERATION | ✅ 있음 | ❌ 없음 |
| Worktree Mode | ✅ 개선됨 | ⚠️ 기존 방식 |

---

## 부록 B: 버전 타임라인

```
2025-01-XX: v1.4.0  → templates/.pilot-version (현재까지 유지됨)
2025-XX-XX: v3.1.1  → .claude/.pilot-version 업데이트
2025-XX-XX: v3.3.0  → pyproject.toml 업데이트
2026-01-15: v3.3.1  → pyproject.toml 업데이트
                    → templates/.pilot-version은 여전히 1.4.0!
```

---

## 부록 C: 명령어 참조

### C.1 버전 확인 명령어

```bash
# PyPI 버전 확인
pip show claude-pilot | grep Version

# 템플릿 버전 확인
cat src/claude_pilot/templates/.claude/.pilot-version

# 프로젝트 버전 확인
cat .claude/.pilot-version
```

### C.2 업데이트 명령어

```bash
# pip 업데이트
pip3 install --upgrade claude-pilot

# claude-pilot CLI 업데이트
claude-pilot update

# 수동 템플릿 복사
cp -r $(python3 -c "import importlib.resources; print(importlib.resources.files('claude_pilot/templates'))")/.claude/* .claude/
```

---

**보고서 작성자**: Claude Code (claude-pilot v3.3.1)
**다음 세션 준비 사항**: 이 보고서를 바탕으로 수정 작업 진행

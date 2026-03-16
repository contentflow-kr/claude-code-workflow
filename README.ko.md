# claude-code-workflow

> Claude Code를 위한 세션 기억, 에러 학습, 프로젝트 스캐폴딩, Git 통합 프레임워크.

[English](README.md) | **한국어** | [日本語](README.ja.md) | [中文](README.zh.md) | [Français](README.fr.md)

---

## 문제

`/clear`를 치거나 새로운 Claude Code 세션을 시작할 때마다 **모든 컨텍스트가 사라집니다**. 이전에 뭘 했는지, 어떤 실수가 있었는지, 프로젝트가 어떤 규칙을 따르는지 전부 잊어버립니다. 여러 프로젝트를 동시에 관리하면 상황은 더 나빠집니다.

## 해결책

**5개의 slash command**로 Claude에게 영구 기억, 에러 학습, 멀티 프로젝트 내비게이션을 부여합니다:

```
/init-worklog      →  기록 인프라 설정 (프로젝트당 1회)
/init-project-v1   →  빈 템플릿으로 빠른 프로젝트 스캐폴딩
/init-project-v2   →  실제 문서를 작성하는 상세 설정
/session-start     →  이전 컨텍스트 복구
/session-end       →  모든 내용 저장 + 작업일지 + Git 커밋
```

---

## 빠른 시작

### 설치

```bash
git clone https://github.com/contentflow-kr/claude-code-workflow.git
cd claude-code-workflow
chmod +x install.sh
./install.sh
```

설치 스크립트가 실행하는 작업:
1. 5개의 slash command를 `~/.claude/commands/`에 복사
2. `~/work-tree.md` 생성 (프로젝트 내비게이션 맵)
3. (선택) `~/work_logs/` 생성 (글로벌 대시보드)
4. (선택) Obsidian 동기화 설정

### 처음 사용하기

```
cd your-project
/init-worklog          # work_logs/ 설정 (30초)
# 평소처럼 작업...
/session-end           # 모든 내용 기록
# 다음 세션:
/session-start         # 이전 작업 이어가기
```

### 새 프로젝트 시작

```
cd empty-folder
/init-project-v1       # 빠른 스캐폴딩 (5분)
# 또는
/init-project-v2       # 실제 문서 포함 상세 설정 (30분)
```

---

## 작동 방식

### 세션 라이프사이클

```
┌─────────────────────────────────────────────────┐
│                 /session-start v3                │
│                                                  │
│  0. work-tree.md 읽기  → 프로젝트 내비게이션 맵  │
│  1. remind.md 읽기     → 프로젝트 규칙           │
│  2. error-rules.md 읽기 → 에러 방지 규칙         │
│  3. chatlog.md 읽기    → 미완료 작업             │
│  4. CHANGELOG.md 읽기  → 최근 변경사항           │
│  5. ~/work_logs/error-rules.md 읽기              │
│     → 글로벌 공유 규칙 (프로젝트 간)             │
│                                                  │
│  출력: 컨텍스트 요약 + 다음 작업 제안            │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│              일반 작업 세션                      │
│                                                  │
│  - 코드 작성, 버그 수정, 기능 추가               │
│  - 에러 발생 시 ERR-### 항목으로 추적            │
│  - 방지 규칙 RUL-### 도출                        │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│                /session-end v4                   │
│                                                  │
│  1. 세션 분석 → 작업, 결정사항 추출              │
│  2. chatlog.md에 세션 블록 추가                  │
│  3. 글로벌 대시보드에 1행 요약 추가              │
│  4. 에러 기록 (ERR-###) + 규칙 도출 (RUL-###)   │
│  5. remind.md + CHANGELOG.md 업데이트            │
│  6. 날짜별 작업일지 파일 생성                    │
│  7. [선택] Obsidian + CLI 동기화                 │
│  8. Git 커밋 (자동 생성 메시지)                  │
│  9. 출력: 최종 보고서 + 다음 세션 작업           │
└─────────────────────────────────────────────────┘
```

---

## 5가지 명령어

### `/init-worklog` (v2)

기존 프로젝트에 기록 시스템을 추가합니다.

**생성되는 파일:**

| 파일 | 용도 |
|------|------|
| `work_logs/chatlog.md` | 세션 기억 |
| `work_logs/remind.md` | 프로젝트 규칙 |
| `work_logs/error_logs.md` | 에러 기록 (ERR-###) |
| `work_logs/error-rules.md` | 방지 규칙 (RUL-###) |
| `work_logs/CHANGELOG.md` | 변경 이력 |

**v2 추가 기능**: 프로젝트 간 내비게이션을 위해 `work-tree.md`에 자동으로 프로젝트를 등록합니다.

### `/init-project-v1`

빠른 프로젝트 스캐폴딩 — 4가지 질문에 답하면 빈 템플릿 문서를 생성합니다.

**생성 항목**: `CLAUDE.md` + `docs/` (빈 템플릿) + `work_logs/` + `.gitignore`

적합한 상황: 해커톤, 실험, 기획이 확정되지 않은 프로젝트.

### `/init-project-v2`

상세 프로젝트 설정 — 3단계 질문을 통해 실제 문서 내용을 작성합니다.

**생성 항목**: `CLAUDE.md` + `docs/` (실제 내용) + `work_logs/` + `.gitignore`

적합한 상황: 본격적인 프로젝트, 장기 개발, 문서 중심 개발.

### `/session-start` (v3)

이전 세션의 컨텍스트를 복구합니다.

**로딩 순서:**
1. `work-tree.md` — 프로젝트 내비게이션 맵
2. `remind.md` — 프로젝트 규칙
3. `error-rules.md` — 에러 방지 규칙 (프로젝트 + 글로벌)
4. `chatlog.md` — 이전 세션 및 미완료 작업
5. `CHANGELOG.md` — 최근 변경사항

**글로벌 모드**: `~/`에서 실행하면 모든 프로젝트를 스캔하여 전체 미완료 작업을 한눈에 확인할 수 있습니다.

### `/session-end` (v4)

현재 세션을 기록하고 다음 세션을 준비합니다.

| 단계 | 동작 |
|------|------|
| 1-2 | 세션 분석, 작업/결정사항 추출 |
| 3 | chatlog.md에 세션 블록 추가 |
| 3.5 | 글로벌 대시보드에 1행 추가 |
| 3.7 | 에러 기록 (ERR-###) + 규칙 도출 (RUL-###) |
| 4-5 | remind.md + CHANGELOG.md 업데이트 |
| 6 | 날짜별 작업일지 생성 |
| 6.5 | [선택] Obsidian CLI 동기화 |
| 7 | Git 커밋 (사용자 확인 후) |
| 8 | 최종 보고서 출력 |

---

## 핵심 기능

### 세션 기억
모든 세션이 `chatlog.md`에 구조화된 블록으로 기록됩니다. 다음번 `/session-start` 실행 시 정확히 이전 작업을 이어갑니다.

### 에러 학습
에러는 `ERR-###`으로 추적되고, 방지 규칙은 `RUL-###`으로 도출됩니다. 글로벌 `~/work_logs/error-rules.md`를 통해 프로젝트 A에서 발생한 에러가 프로젝트 B에서 같은 실수를 방지합니다.

### 멀티 프로젝트 내비게이션
`work-tree.md`가 모든 프로젝트를 맵핑합니다. `/init-worklog` 실행 시 새 프로젝트가 자동 등록됩니다. `~/`에서 `/session-start`를 실행하면 전체 미완료 작업을 한 번에 볼 수 있습니다.

### 2계층 로깅
- **프로젝트 레벨**: `chatlog.md`에 상세 세션 블록
- **글로벌 레벨**: `~/work_logs/chatlog.md`에 1행=1세션 대시보드

### Git 통합
세션 요약을 기반으로 커밋 메시지를 자동 생성합니다. 민감한 파일(.env, credentials)은 자동으로 제외됩니다.

### Obsidian 동기화 (선택)
작업일지가 Obsidian vault에 자동으로 복사됩니다. Daily Notes 및 태스크 수 연동을 위한 CLI 통합도 지원합니다.

---

## 파일 구조

```
~/                                    # 글로벌
├── work-tree.md                      # 프로젝트 내비게이션 맵
├── work_logs/
│   ├── chatlog.md                    # 전체 세션 대시보드
│   ├── error_logs.md                 # 프로젝트 간 에러 기록
│   ├── error-rules.md               # 공유 방지 규칙
│   └── remind.md                     # 글로벌 규칙
└── .claude/commands/                 # Skill 파일 (5개)

{project}/                            # 프로젝트별
├── work_logs/
│   ├── chatlog.md                    # 세션 기록
│   ├── remind.md                     # 프로젝트 규칙
│   ├── error_logs.md                 # 에러 (ERR-###)
│   ├── error-rules.md               # 규칙 (RUL-###)
│   ├── CHANGELOG.md                  # 변경 이력
│   └── YYYY_MM_DD_*_worklog.md       # 날짜별 작업일지
└── CLAUDE.md                         # 프로젝트 컨텍스트
```

---

## Claude Code `/memory`와의 비교

| | `/memory` (내장) | claude-code-workflow |
|---|:---:|:---:|
| **세션 기록** | 없음 | 있음 |
| **미완료 작업 추적** | 없음 | 있음 |
| **에러 학습** | 없음 | 있음 (ERR → RUL) |
| **프로젝트 간 에러 공유** | 없음 | 있음 |
| **멀티 프로젝트 내비게이션** | 없음 | 있음 (work-tree.md) |
| **프로젝트 스캐폴딩** | 없음 | 있음 (v1 + v2) |
| **Git 커밋 통합** | 없음 | 있음 |
| **Obsidian 동기화** | 없음 | 있음 (선택) |

**서로 경쟁하는 게 아니라 보완 관계입니다.** `/memory`는 정적 선호사항 저장에, claude-code-workflow는 세션 라이프사이클 관리에 사용하세요.

---

## 요구사항

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) 설치
- macOS 또는 Linux
- Git (커밋 통합용)

## 라이선스

[CC BY-NC 4.0](https://creativecommons.org/licenses/by-nc/4.0/) — 자유롭게 사용/수정 가능, 상업적 판매 금지.

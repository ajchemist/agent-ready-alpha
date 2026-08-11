# core 스캐폴드

`core` 브랜치는 에이전트 무관(agent-agnostic) 프로젝트 스캐폴드입니다.
`degit` 한 번 + 에이전트 호출 한 번으로 프로젝트 셋업이 끝납니다.

## 사용법

```bash
bunx degit ajchemist/agent-ready-alpha#core my-new-project
cd my-new-project
bash ./setup-wizard.sh
```

Claude Code가 아니어도 됩니다 — 파일을 읽고 셸을 실행할 수 있는 에이전트라면
`.scaffold/AGENT-SETUP.md`를 가리키기만 하면 됩니다.

## 요구사항 (스캐폴드를 쓰는 쪽)

- `git`, `bash`, `python3`
- [beads](https://github.com/steveyegge/beads) (`bd`) CLI
- 코딩 에이전트 (Claude Code, Codex, …)

## 브랜치 구성

```
AGENTS.md                        단일 지침 파일 (CLAUDE.md는 "@AGENTS.md" 한 줄)
CLAUDE.md
README.md                        온보딩 안내 — 부트스트랩이 실제 프로젝트 README로 교체
setup-wizard.sh                  대화형 부트스트랩 위저드 (기계적 단계 전부 수행)
.gitignore
docs/agents/issue-tracker.md     beads 워크플로 명세
docs/agents/triage-labels.md     기본 5종 트리아지 라벨
docs/agents/domain.md            single-context + ADR은 beads decision 비드
.scaffold/AGENT-SETUP.md         에이전트 몫 작업만 (README 재작성 등)
.scaffold/manifest.json          전체 파일 sha256 해시
.scaffold/verify.sh              manifest 자체 검증
```

## 설계 결정

전부 이 저장소의 beads decision 비드로 기록되어 있습니다 (`bd list -t decision`).

- **스킬은 벤더링이 아니라 플러그인 설치.** mattpocock/skills는 공식 Claude
  plugin marketplace에 등록되어 있어 표준 설치가 가능합니다. 부트스트랩이
  `claude plugin install … --scope project`로 `mattpocock-skills`와 `ponytail`을
  프로젝트 스코프에 설치합니다. (`agent-ready-alpha-y1h`)
- **부트스트랩이 끝나면 `.scaffold/`를 삭제.** 셋업이 끝난 프로젝트에는
  스캐폴드 잔재가 남지 않습니다. (`agent-ready-alpha-bn7`)
- **출처 정보 없음.** 생성된 트리에는 이 저장소에 대한 참조가 남지 않으며,
  생성 스크립트가 grep으로 강제합니다. (`agent-ready-alpha-o32`)
- **README 라이프사이클.** 스캐폴드의 README는 온보딩 안내서이고, 부트스트랩
  에이전트가 실제 프로젝트 README로 교체합니다. (`agent-ready-alpha-zli`)
- **CLAUDE.md는 `@AGENTS.md` 한 줄.** 지침 파일은 `AGENTS.md` 하나입니다.
  `bd init`은 `--skip-agents`로 실행해 CLAUDE.md 오염을 막고, beads 지침은
  `bd setup codex`가 AGENTS.md에 fenced 블록으로 멱등 삽입합니다.
- **ADR은 `docs/adr/`가 아니라 beads.** `bd create -t decision`으로 기록하고
  `bd supersede <old> --with <new>`로 뒤집습니다. 비드 ID가 곧 ADR 번호입니다.

## 검증

```bash
bash verify_scaffold.sh <project-dir>   # .scaffold/verify.sh로 위임
```

부트스트랩이 만들어내는 것들(`.beads/`, `.codex/`, `.claude/` 등)은 manifest
검증 대상이 아니며, `verify.sh`는 이를 무시합니다.

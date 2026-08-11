# agent-ready-alpha

에이전트 무관(agent-agnostic) 프로젝트 스캐폴드를 관리하는 저장소입니다.
`core` 브랜치가 스캐폴드 본체이고, `main`은 그것을 생성·검증하는
페이로드(`scaffold/`)와 워크플로를 담습니다.

## core 스캐폴드로 새 프로젝트 시작하기

```bash
bunx degit ajchemist/agent-ready-alpha#core my-new-project
cd my-new-project
bash ./setup-wizard.sh
```

degit 한 번 + 에이전트 호출 한 번으로 셋업이 끝납니다. 부트스트랩은:

- manifest 기준으로 스캐폴드 무결성을 검증하고
- 에이전트 스킬(`mattpocock-skills`, `ponytail`)을 프로젝트 스코프 Claude
  플러그인으로 설치하고
- beads(`bd`) 이슈 트래커를 초기화하고
- 부트스트랩 결정을 ADR 비드로 기록하고
- README를 실제 프로젝트 README로 교체하고
- `.scaffold/`를 삭제합니다.

자세한 설명은 [docs/core-scaffold.md](docs/core-scaffold.md),
워크플로 운영은 [docs/core-workflow-guidance.md](docs/core-workflow-guidance.md)를
참고하세요.

## 검증

```bash
bash verify_scaffold.sh <project-dir>
```

스캐폴드가 자체적으로 들고 있는 `.scaffold/verify.sh`로 위임합니다.

## 레거시 브랜치

`cc`(Claude Code 전용 최소 스캐폴드)와 `kimi`(Kimi CLI용 skill 벤더링
스캐폴드) 브랜치는 core가 안정화될 때까지 유지됩니다. core가 세 에이전트를
모두 커버하므로 이후 정리 예정입니다. 문서:
[docs/cc-scaffold.md](docs/cc-scaffold.md)

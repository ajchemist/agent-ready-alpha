# core 워크플로 가이드

`core` 브랜치를 생성·검증하는 GitHub Actions 구성에 대한 운영 문서입니다.

## 구성 요소

- `.github/scripts/create-core-branch.sh` — 생성기. `scaffold/`(main의 정적
  페이로드)에서 트리를 조립하고, manifest를 만들고, 검증한 뒤 `core` 브랜치로
  force-push 합니다.
- `.github/workflows/core-maintenance.yml` — daily cron(07:00 UTC) +
  `workflow_dispatch`. 생성기를 실행합니다. `contents: write` 권한 필요.
- `.github/workflows/core-validate.yml` — `core` 브랜치 push/PR에서 manifest
  해시와 트리 구성을 검증합니다.

## 생성기의 가드

빌드는 다음 조건에서 실패합니다(의도된 동작).

1. `scaffold/CLAUDE.md`가 정확히 `@AGENTS.md` 한 줄이 아닐 때.
2. `scaffold/` 안에 `.gitignore`라는 이름의 파일이 있을 때 — main 저장소에
   영향을 주므로 반드시 `dot.gitignore`로 두고, 생성기가 복사하며 이름을
   바꿉니다.
3. 생성된 트리에 소스 저장소에 대한 참조(provenance)가 남아 있을 때.

## 로컬 드라이런

```bash
bash .github/scripts/create-core-branch.sh
```

`GITHUB_TOKEN`과 `GITHUB_REPOSITORY`가 둘 다 없으면 빌드·검증·커밋까지만
수행하고 push 없이 exit 0 합니다.

## Verdict 게이트

`OMNIROUTE_URL` repository variable이 설정되어 있으면 생성기가 manifest를
POST 하고 응답의 `verdict`가 `approve`일 때만 push 합니다. 설정되어 있지
않으면 자동으로 `approve`입니다.

## 운영 노트

- `core-maintenance`는 매 실행마다 audit 이슈를 만듭니다(`if: always()`,
  기존 cc 워크플로 동작을 따름). 매일 이슈가 쌓이는 게 싫으면
  `if: failure()`로 바꾸세요. 동작상 문제는 아닙니다.
- 스킬 설치는 CI가 아니라 **부트스트랩 시점**에 일어납니다. CI 러너에 필요한
  것은 `git`, `python3`, `bash`뿐입니다.
- `cc`, `kimi` 브랜치와 워크플로는 core가 안정화될 때까지 그대로 둡니다.
  core가 세 에이전트를 모두 커버하므로, 안정화 후 별도 PR로 정리를
  권장합니다.

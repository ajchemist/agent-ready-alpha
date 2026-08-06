# CC scaffold

## 무엇을 위한 브랜치인가

`cc` 브랜치는 저장소의 개발용 파일을 담지 않고, 외부 프로젝트가 바로 가져다 쓸 수 있는 최소 스캐폴드만 포함하도록 설계된 브랜치입니다.

이 브랜치의 목적은 다음과 같습니다.

- 온보딩 경로를 간단하게 제공한다.
- 불필요한 저장소 전용 파일(예: README, `.github`, `scripts/`)이 섞이지 않게 한다.
- `degit`으로 클론하더라도 안전하게 검증 가능한 최소 구조를 유지한다.

## 포함되는 파일

현재 `cc` 스캐폴드는 다음 파일만 포함합니다.

- `.claude/installed.json`
- `.gitignore`
- `.scaffold/manifest.json`

## 어떻게 사용하나

로컬에서 바로 가져오려면 다음처럼 사용하면 됩니다.

```bash
bunx degit ajchemist/agent-ready-alpha#cc my-new-project
cd my-new-project
```

## 검증 방법

받아온 디렉터리에서 아래 스크립트를 실행하면 manifest와 실제 파일 해시가 일치하는지 검증할 수 있습니다.

```bash
bash verify_scaffold.sh .
```

## 주의 사항

`cc` 브랜치에는 다음과 같은 파일이 들어가면 안 됩니다.

- README.md
- scripts/
- .github/
- 저장소 운영용 개발 문서

이 브랜치는 오직 스캐폴드와 검증 기준을 제공하는 용도입니다.

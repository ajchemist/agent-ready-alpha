# agent-ready-alpha

이 저장소는 두 가지를 관리합니다.

1. 프로젝트 범위로 Claude 플러그인을 설치하는 로컬 스크립트
2. `cc` 브랜치의 최소 스캐폴드로, 새 프로젝트를 빠르게 시작할 수 있는 온보딩 경로

## 로컬 설치(개발용)

사용자 환경에서 프로젝트 스코프의 Claude 플러그인을 설치하려면 아래 스크립트를 실행하세요.

주의: `claude` CLI가 설치되어 있고 인증(로그인/토큰)이 필요할 수 있습니다. Codespace나 로컬에서 실행하세요.

```bash
# 실행 권한을 추가하고 스크립트 실행
chmod +x scripts/install-claude-plugins.sh
./scripts/install-claude-plugins.sh
```

## cc 스캐폴드로 새 프로젝트 시작하기

`cc` 브랜치는 개발용 파일이나 저장소 전용 문서 없이, 최소한의 스캐폴드만 제공하도록 설계되었습니다. 그래서 `degit`으로 아주 깔끔하게 가져와서 바로 시작할 수 있습니다.

```bash
bunx degit ajchemist/agent-ready-alpha#cc my-new-project
cd my-new-project
ls -la
```

이 명령으로 받게 되는 기본 파일은 다음과 같습니다.

- `.claude/installed.json`
- `.gitignore`
- `.scaffold/manifest.json`

이 브랜치는 온보딩과 검증을 위한 최소한의 기준이며, README나 `.github`, `scripts/` 같은 저장소 전용 개발 파일은 포함하지 않습니다.

자세한 설명은 [docs/cc-scaffold.md](docs/cc-scaffold.md)를 참고하세요.

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

## kimi 스캐폴드로 새 프로젝트 시작하기

`kimi` 브랜치는 Kimi CLI용 스캐폴드입니다. Kimi CLI는 마켓플레이스가 없어서, 플러그인 참조 대신 skill 파일 자체를 `.agents/skills/`에 vendoring해 둡니다(Kimi CLI가 읽는 프로젝트 스코프 경로).

```bash
bunx degit ajchemist/agent-ready-alpha#kimi my-new-project
cd my-new-project
```

이 명령으로 받게 되는 기본 파일은 다음과 같습니다.

- `.agents/skills/` — [mattpocock/skills](https://github.com/mattpocock/skills)(Claude 플러그인이 설치하는 skill 목록과 동일), [ponytail](https://github.com/DietrichGebert/ponytail), [caveman](https://github.com/JuliusBrussee/caveman)에서 가져온 skill 전체
- `.kimi/installed.json` — 설치 마커와 세 저장소의 pinned commit SHA
- `.gitignore`
- `.scaffold/manifest.json`

브랜치는 `kimi-maintenance` 워크플로우(daily cron + 수동 실행)가 upstream 최신 기준으로 재생성합니다. 검증은 cc와 동일하게 `bash verify_scaffold.sh .` 를 사용합니다.

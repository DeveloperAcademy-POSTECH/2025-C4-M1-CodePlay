# 🚀 SHOONG - 슝 : 페스티벌 라인업 예습 플레이리스트

![배너 이미지 또는 로고](링크)

> 간단한 한 줄 소개 – 프로젝트의 핵심 가치 또는 기능

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-15.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---

## 🗂 목차
- [소개](#소개)
- [프로젝트 기간](#프로젝트-기간)
- [기술 스택](#기술-스택)
- [기능](#기능)
- [시연](#시연)
- [폴더 구조](#폴더-구조)
- [팀 소개](#팀-소개)
- [Git 컨벤션](#git-컨벤션)
- [테스트 방법](#테스트-방법)
- [프로젝트 문서](#프로젝트-문서)
- [라이선스](#lock_with_ink_pen-license)

---

## 📱 소개

> MusicKit과 Vision으로 음악 페스티벌의 정보를 분석한 후 공연 예습 플레이리스트를 만들어서, 사용자가 모르는 노래없이 온전히 음악 페스티벌을 즐기게 하자.

[🔗 앱스토어/웹 링크](https://example.com)


## 📆 프로젝트 기간
- 전체 기간: `2025.06.23 - 2025.08.01`
- 개발 기간: `2025.07.04 - 2025.07.28`


## 🛠 기술 스택

- iOS: Swift / SwiftUI / UIKit / Vision / MusicKit 등
- Backend: On-premise: MeiliSearch, BeautifulSoup / Severless : Lambda, ApiGateway, S3, DynamoDB
- 아키텍처: MVVM + Clean Architecture 등
- 기타 도구: Figma, AfterEffects, Notion, GitHub Projects / JIRA / Confluence 등


## 🌟 주요 기능

- ✅ AVFoundation으로 페스티벌 라인업을 인식한다
- ✅ 인식된 포스터를 vision으로 텍스트를 추출한다.
- ✅ 추출된 텍스트를 가지고 페스티벌 라인업에 포함된 가수들을 모아 플레이리스트를 생성한다.
- ✅ MusicKit으로 30초 미리듣기 및 생성된 플레이리스트를 내보낼 수 있다.

> 필요시 이미지, GIF, 혹은 링크 삽입


## 🖼 화면 구성 및 시연

| 기능 | 설명 | 이미지 |
|------|------|--------|
| 예시1 | 기능 요약 | ![gif](링크) |
| 예시2 | 기능 요약 | ![gif](링크) |


## 🧱 폴더 구조

```
📦CodePlay
┣ 📂Presentation
┃ ┣ 📂Factory
┃ ┣ 📂Scene
┃ ┃ ┣ 📂ExportPlaylist
┃ ┃ ┣ 📂LicenseCheck
┃ ┃ ┣ 📂MainPosterView
┃ ┃ ┗ 📂Root
┃ ┗ 📂Utils
┣ 📂Domain
┃ ┣ 📂Interfaces
┃ ┣ 📂Models
┃ ┣ 📂Services
┃ ┗ 📂Usecases
┣ 📂Data
┃ ┣ 📂Network
┃ ┗ 📂SceneB
┣ 📂Application
┣ ┗ 📂DIContainer
┗ 📂Resources
```


## 🧑‍💻 팀 소개

| 이름 | 역할 | GitHub |
|------|------|--------|
| Elian | PM, Back-End | [@dangdang1ing15](https://github.com/dangdang1ing15) |
| Yan | iOS Lead | [@yanni13](https://github.com/yanni13) |
| Cherry | iOS Developer | [@zz6cherry](https://github.com/zz6cherry) |
| Kwangro | iOS Developer | [@hkwangro](https://github.com/hkwangro) |
| Three | Designer | [@iamseulee](https://github.com/iamseulee) |


[🔗 팀 블로그 / 미디엄 링크](https://medium.com/example)

## 🔖 브랜치 전략
`(예시)`
- `main`: 배포 가능한 안정 버전
- `dev`: 통합 개발 브랜치
- `feat/*`: 기능 개발 브랜치
- `fix/*`: 버그 수정 브랜치
- `setting/*`: 프로젝트 설정 브랜치
- `chore/*`: Feat 이외에 코드 수정, 내부 파일 수정, 애매한 것들이나 잡일
- `refactor/*`: 리펙토링 및 전면 수정


## 🌀 커밋 메시지 컨벤션
`(예시)`  
[Gitmoji](https://gitmoji.dev) + [Conventional Commits](https://www.conventionalcommits.org)

### 예시
- ✨ feat: 로그인 화면 추가
- 🐛 fix: 홈 진입 시 크래시 수정
- ♻️ refactor: 데이터 모델 구조 정리


## ✅ 테스트 방법

1. 이 저장소를 클론합니다.
```bash
git clone https://github.com/yourteam/project.git
```
2. `Xcode`로 `.xcodeproj` 또는 `.xcworkspace` 열기
3. 시뮬레이터 환경 설정: iPhone 15 / iOS 17
4. `Cmd + R`로 실행 / `Cmd + U`로 테스트 실행


## 📎 프로젝트 문서

- [기획 히스토리](링크)
- [디자인 히스토리](링크)
- [기술 문서 (아키텍처 등)](링크)


## 📝 License

This project is licensed under the ~~[CHOOSE A LICENSE](https://choosealicense.com). and update this line~~

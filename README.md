# 🚀 SHOONG - 슝 : 페스티벌 라인업 예습 플레이리스트

<img width="2560" height="1440" alt="codeplay" src="https://github.com/user-attachments/assets/5a617034-5fa1-4c74-b936-d7dab34fa91a" />


> iPhone으로 포스터 라인업을 스캔하고, 모든 아티스트의 음악을 미리 만나보세요.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)]()
[![Xcode](https://img.shields.io/badge/Xcode-15.0-blue.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

---
## 📱 소개

> MusicKit과 Vision으로 음악 페스티벌의 정보를 분석한 후 공연 예습 플레이리스트를 만들어서, 사용자가 모르는 노래없이 온전히 음악 페스티벌을 즐기게 하자.

[🔗 앱스토어 다운받기](https://apps.apple.com/kr/app/shoong/id6749286563)


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
| PM, Back-End <br> <img width="150" height="150" alt="엘리안 이모지" src="" /> <br> Elian <br> [@dangdang1ing15](https://github.com/dangdang1ing15) | iOS Developer <br> <img width="150" height="150" alt="얀 미모지" src="" /> <br> Yan <br> [@yanni13](https://github.com/yanni13) | iOS Developer <br> <img width="150" height="150" alt="체리 미모지" src="" /> <br> Cherry <br> [@zz6cherry](https://github.com/zz6cherry) | iOS Developer <br> <img width="150" height="150" alt="광로 미모지" src=""> <br> Kwangro <br> [@hkwangro](https://github.com/hkwangro) | Designer <br> <img width="150" height="150" alt="쓰리 미모지" src="" /> <br> Three <br> [@iamseulee](https://github.com/iamseulee) |
| --- | --- | --- | --- | --- |


## 🔖 브랜치 전략
`(예시)`
- `main`: 배포 가능한 안정 버전
- `dev`: 통합 개발 브랜치
- `feat/*`: 기능 개발 브랜치
- `fix/*`: 버그 수정 브랜치
- `setting/*`: 프로젝트 설정 브랜치
- `chore/*`: Feat 이외에 코드 수정, 내부 파일 수정, 애매한 것들이나 잡일
- `refactor/*`: 리펙토링 및 전면 수정


## 📝 License

This project is licensed under the ~~[CHOOSE A LICENSE](https://choosealicense.com). and update this line~~

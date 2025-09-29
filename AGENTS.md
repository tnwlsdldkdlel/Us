# Repository Guidelines

## 프로젝트 구조 및 모듈 구성
`lib/main.dart`가 앱의 진입점이며 UI와 라우팅 로직을 포함합니다. `test/widget_test.dart`는 기본 위젯 테스트 예제를 제공하므로, 새 테스트는 동일한 디렉터리 구조를 따라 `*_test.dart` 형태로 추가합니다. 각 플랫폼 전용 코드는 `android/`, `ios/`, `web/`, `macos/`, `linux/`, `windows/`에서 관리하고, 런타임 빌드는 `build/`에 생성됩니다.

## 빌드 · 테스트 · 개발 명령어
`flutter pub get`으로 의존성을 동기화하십시오. 로컬 개발 중에는 `flutter run`으로 시뮬레이터나 디바이스에서 앱을 실행합니다. 정적 분석은 `flutter analyze`, 포맷팅은 `dart format lib test`로 수행합니다. 단위 및 위젯 테스트는 `flutter test`로 실행하며, 릴리스 빌드는 `flutter build apk` 또는 `flutter build ios` 등 타깃 플랫폼에 맞는 명령을 선택합니다.

## 코딩 스타일 및 네이밍 규칙
Dart 기본 규약과 `analysis_options.yaml`에서 활성화한 `flutter_lints`를 준수합니다. 들여쓰기는 2칸 공백을 사용하고, 클래스와 위젯은 UpperCamelCase, 함수·변수는 lowerCamelCase로 명명합니다. 파일 이름은 소문자 스네이크 케이스(예: `appointment_detail_view.dart`)를 유지하고, 불필요한 `print` 대신 로깅 또는 디버그 도구를 활용하십시오. 포맷은 커밋 전에 `dart format`으로 정리합니다.

## 테스트 가이드라인
새 기능에는 최소 한 개 이상의 단위 혹은 위젯 테스트를 추가합니다. 테스트 파일은 기능과 동일한 패키지 경로를 반영해 `test/feature_name/` 하위에 배치하고, 명칭은 `whenExpectedOutcome` 패턴의 그룹이나 설명을 사용해 동작을 명확히 합니다. CI가 구성되기 전까지는 로컬에서 `flutter test --coverage`를 실행해 회귀를 방지하고, 주요 위젯 변경 시 스크린샷 테스트를 고려하십시오.

## 커밋 및 PR 지침
Git 로그는 `feat:` 접두사 등 Conventional Commits 패턴을 따릅니다. 커밋 메시지는 한글 또는 영어 모두 가능하지만, 유형(`feat`, `fix`, `refactor`, `test`)과 핵심 변경 사항을 한 문장으로 요약하십시오. PR에는 변경 의도, 테스트 결과(`flutter analyze`, `flutter test`)를 체크리스트로 명시하고 UI 변경 시 전·후 비교 스크린샷을 포함합니다. 관련 이슈가 있다면 `Closes #번호` 형식으로 링크해 추적 가능성을 높이십시오.

## 커뮤니케이션 원칙
모든 이슈, PR, 리뷰 코멘트는 한국어로 작성해 팀 합의를 빠르게 공유합니다. 변경 사항을 설명할 때는 요약-세부-다음 단계 순으로 정리하고, 필요한 경우 `flutter analyze` 결과나 테스트 로그를 코드 블록으로 첨부해 재현성을 확보하십시오.

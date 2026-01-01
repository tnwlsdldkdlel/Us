# Us – Appointment Planner

일정을 한눈에 정리하고 약속 참석자와 빠르게 소통할 수 있는 Flutter 기반 약속 관리 애플리케이션입니다. 홈 대시보드에서 오늘의 일정과 진행 상황을 확인하고, 달력을 통해 월간 약속을 탐색하며, 친구 관리 화면에서 초대 및 요청을 처리할 수 있습니다.

## 주요 기능

- 홈 대시보드에서 당일·다가오는 약속과 지표 위젯을 요약 제공
- 달력 화면에서 월간 일정과 상세 정보를 필터링 및 탐색
- 친구 탭에서 친구 요청, 검색, 즐겨찾기 관리 지원
- 약속 상세/편집 화면에서 장소·시간·참석자 정보를 손쉽게 수정
- Mock 저장소 기반 데이터로 빠르게 프로토타이핑하고, 서비스 계층을 통해 실제 API 연동을 확장 가능

## 기술 스택

- Flutter 3.x + Dart: 단일 코드 베이스로 iOS/Android/Web을 대상으로 개발
- `flutter_riverpod`: 상태 관리와 의존성 주입
- `intl`: 날짜·시간 포맷 유틸리티
- `table_calendar`: 달력 UI 컴포넌트
- Mock Repository 패턴: 개발 초기 단계에서의 빠른 화면 검증

## 구조 개요

- `lib/app.dart`: `MaterialApp` 진입점. 전역 테마 및 기본 라우트를 구성합니다.
- `lib/main.dart`: `runApp` 호출만 담당하는 엔트리 포인트입니다.
- `lib/data/`
  - `appointments/appointment_repository.dart`: 약속 관련 데이터를 제공하는 `AppointmentRepository` 추상 타입과 `MockAppointmentRepository` 구현체를 포함합니다.
  - `friends/friend_repository.dart`: 친구 목록과 요청 데이터를 제공하는 `FriendRepository` 및 모의 구현을 담습니다.
- `lib/models/`: `Appointment`, `Friend` 등 도메인 모델 정의.
- `lib/screens/`
  - `home/`
    - `screens/home_screen.dart`: 홈 탭 UI와 탭 전환 로직을 담당합니다.
    - `models/home_view_model.dart`: 약속 데이터를 로딩·가공하는 프레젠테이션 모델입니다.
    - `widgets/`: 홈 전용 카드, 헤더 등 서브 컴포넌트.
  - `calendar/`
    - `screens/calendar_screen.dart`: 달력 UI를 렌더링하고 상호작용을 처리합니다.
    - `models/calendar_view_model.dart`: 달력 상태(포커스 월, 선택 날짜 등)를 관리합니다.
  - `friends/`
    - `screens/friends_screen.dart`: 친구/요청 탭 UI와 검색 입력을 포함합니다.
    - `models/friends_view_model.dart`: 친구 목록 필터링과 로딩 상태를 관리합니다.
  - `appointment_detail/`
    - `screens/appointment_detail_screen.dart`, `screens/appointment_edit_screen.dart`: 상세 보기/편집 화면.
    - `widgets/`: 정보 섹션, 참가자 카드 등 UI 조각.
- `lib/services/`: 카카오 장소 검색 등 외부 API 호출 래퍼.
- `lib/widgets/`: 여러 화면에서 공유하는 UI 컴포넌트.

## 테스트

- `test/screens/home/home_view_model_test.dart`: 홈 뷰모델이 레포지토리 데이터를 올바르게 가져오는지 검증합니다.
- `test/screens/friends/friends_view_model_test.dart`: 친구 뷰모델의 검색 및 상태 동작을 확인합니다.
- `test/widget_test.dart`: 홈 화면 주요 섹션과 하단 내비게이션 렌더링을 위젯 테스트로 보장합니다.

테스트 실행: `flutter test`

## 개발 워크플로

1. 의존성 설치: `flutter pub get`
2. 코드 포맷팅: `dart format lib test`
3. 정적 분석: `flutter analyze`
4. 로컬 실행: `flutter run`

## 환경 변수 설정

### Kakao REST API Key

약속 만들기 화면에서 장소를 검색하려면 카카오 로컬 API 키가 필요합니다. 앱은 빌드 타임 상수
`KAKAO_REST_API_KEY`를 읽어오도록 되어 있으므로, 실행 시 아래와 같이 `--dart-define` 값을 전달하세요.

```bash
flutter run \
  --dart-define=KAKAO_REST_API_KEY=여기에_카카오_REST_API_KEY_값
```

테스트나 다른 실행 스크립트에도 동일하게 `--dart-define` 인수를 추가하면 됩니다. VS Code를 사용하는
경우 `.vscode/launch.json` 의 `toolArgs` 항목에 위 인수를 넣어두면 편리합니다.

### Supabase 스키마 동기화

약속 생성 시 장소의 주소·위도·경도를 저장하려면 Supabase `appointments` 테이블에 해당 컬럼이 존재해야
합니다. 레포지토리에는 다음 SQL이 포함되어 있으니, 프로젝트 루트에서 아래 명령으로 반영하세요.

```bash
supabase db push
```

또는 원격 DB에 직접 적용하려면:

```bash
supabase db remote commit --message "Add appointment location columns"
```

적용되는 SQL은 `supabase/migrations/20241014_add_appointment_location_columns.sql`에 기록되어 있습니다.

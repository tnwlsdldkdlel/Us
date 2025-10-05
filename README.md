# Us – Appointment Planner

Flutter 기반 약속 관리 앱으로 홈 대시보드, 캘린더, 친구 관리 기능을 제공합니다.

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

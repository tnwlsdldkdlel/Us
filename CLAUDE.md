# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

"Us"는 Flutter 3.x 기반의 소셜 캘린더 애플리케이션으로, Supabase를 백엔드로 사용하여 친구 간 약속 생성, 공유, 관리를 지원합니다. 인증, 친구 관리, 약속 생성/조회, RSVP 관리 등의 핵심 기능을 제공합니다.

## 주요 명령어

### 의존성 및 환경 설정
```bash
# 의존성 동기화
flutter pub get

# Supabase 마이그레이션 적용
supabase db push
```

### 개발 및 테스트
```bash
# 정적 분석
flutter analyze

# 코드 포맷팅
dart format lib test

# 전체 테스트 실행
flutter test

# 커버리지 포함 테스트
flutter test --coverage

# 특정 테스트 파일 실행
flutter test test/screens/home/home_view_model_test.dart

# 앱 실행 (환경 변수 포함)
flutter run --dart-define=KAKAO_REST_API_KEY=your_api_key_here
```

### 빌드
```bash
# Android APK 빌드
flutter build apk

# iOS 빌드
flutter build ios
```

## 아키텍처 개요

### 진입점 및 라우팅
- `lib/main.dart`: Supabase 초기화 후 `UsApp` 실행
- `lib/app.dart`: MaterialApp 진입점, 로컬라이제이션·테마·기본 라우트 구성
- `lib/app/auth_gate.dart`: 인증 상태 구독 및 라우팅 (LoginScreen ↔ HomeScreen)
  - Supabase auth state 변경을 실시간으로 감지
  - 로그인 시 사용자 프로필 자동 생성/동기화
  - 인증 세션 부트스트랩 처리

### Feature-First 디렉토리 구조
```
lib/
├── app/              # 앱 셸 및 인증 게이트
├── config/           # 환경 설정 (Supabase, Kakao API 등)
├── data/             # 데이터 레이어 (Repository 패턴)
│   ├── auth/         # 인증 관련 repository
│   ├── user/         # 사용자 프로필 repository
│   ├── friends/      # 친구 관리 repository
│   └── appointments/ # 약속 관리 repository
├── models/           # 도메인 모델 (Appointment, Friend, User 등)
├── screens/          # 화면별 UI 및 ViewModel
│   ├── auth/         # 로그인 화면
│   ├── home/         # 홈 대시보드 (오늘의 약속, 통계)
│   ├── calendar/     # 월간 캘린더 뷰
│   ├── friends/      # 친구 목록 및 요청 관리
│   ├── appointment_detail/ # 약속 상세/편집
│   └── settings/     # 설정 화면
├── services/         # 외부 API 래퍼 (Kakao 장소 검색 등)
├── theme/            # 디자인 시스템 (색상, 타이포그래피)
└── widgets/          # 공유 UI 컴포넌트
```

### 데이터 레이어 패턴
- **Repository 인터페이스**: 각 도메인별로 추상 클래스 정의 (예: `FriendRepository`, `AppointmentRepository`)
- **Supabase 구현체**: 실제 Supabase API 호출 구현 (예: `SupabaseFriendRepository`, `SupabaseAppointmentRepository`)
- **상태 관리**: Repository를 통해 데이터를 가져와 ViewModel에서 UI 상태로 변환
- **에러 처리**: Repository 레이어에서 Failure 타입 반환 (예: `FriendFailure`)

### 인증 플로우
1. `AuthGate`가 Supabase auth state 구독
2. 로그인 시 `AuthRepository`가 사용자 프로필 확인/생성
3. 세션 확보 후 `HomeScreen`으로 라우팅
4. 미인증 시 `LoginScreen` 표시 (Google/Apple 소셜 로그인)

### 친구 관리 시스템
- **친구 요청**: `friendships` 테이블에서 `REQUESTED` → `ACCEPTED` / `REJECTED` 상태 전환
- **친구 초대**: 미가입자에게는 `friend_invites` 테이블에 초대 기록 후 이메일 발송 (Supabase Functions)
- **상태 흐름**:
  - 가입자: `REQUESTED` → `ACCEPTED` (친구 목록 추가) / `REJECTED` (이력만 유지)
  - 미가입자: `INVITED` → 가입 시 자동으로 `REQUESTED` 전환 → 수락 가능
  - 거절 후 재요청 시 기존 레코드 재사용하여 `status` 갱신

### 약속 관리 시스템
- **약속 생성**: 생성자가 제목, 시간, 장소(Kakao 장소 검색), 참여자 지정
- **장소 정보**: `location_name`, `address`, `latitude`, `longitude` 저장하여 지도 표시
- **참여자 관리**: `appointment_participants` 테이블로 다대다 관계 구현
- **RSVP 상태**: `PENDING` (기본) → `ATTENDING` / `DECLINED`
- **권한**: 생성자만 약속 수정/삭제 가능, 참여자는 RSVP 변경 및 댓글만 가능

## 데이터베이스 스키마 핵심 사항

ERD는 `__prompts/_docs/erd.md`에 상세히 정의되어 있습니다.

- **Users**: 소셜 로그인 기반 사용자 정보
- **Friendships**: 친구 관계 상태 (`REQUESTED`, `ACCEPTED`, `REJECTED`)
- **FriendInvites**: 미가입자 초대 추적 (14일 만료, 하루 20건 제한)
- **Appointments**: 약속 정보 (장소 좌표 포함)
- **Appointment_Participants**: 약속-사용자 매핑 및 RSVP 상태
- **Comments**: 약속별 댓글 (Priority 2 기능)

**중요**: 논리적 외래키 사용 원칙 - 물리적 FK 제약 없이 애플리케이션 레벨에서 관계 관리

## 환경 변수 설정

### Kakao REST API Key
장소 검색 기능 사용 시 필수:
```bash
flutter run --dart-define=KAKAO_REST_API_KEY=your_key_here
```

VS Code 사용자는 `.vscode/launch.json`의 `toolArgs`에 추가 권장

### Supabase 연결
- `lib/config/` 디렉토리에 Supabase URL/Anon Key 설정
- 마이그레이션 파일: `supabase/migrations/`
- 원격 DB 적용: `supabase db remote commit`

## 테스트 가이드라인

### 테스트 구조
- 단위 테스트: Repository 및 ViewModel 로직 검증
- 위젯 테스트: UI 렌더링 및 사용자 인터랙션 검증
- 테스트 파일은 기능과 동일한 패키지 경로를 `test/` 하위에 배치

### 주요 테스트 파일
- `test/screens/home/home_view_model_test.dart`: 홈 화면 데이터 로딩 검증
- `test/screens/friends/friends_view_model_test.dart`: 친구 검색 및 필터링 검증
- `test/widget_test.dart`: 홈 화면 하단 내비게이션 렌더링 검증

### 테스트 작성 시 고려사항
- 새 기능에는 최소 하나 이상의 테스트 추가
- 그룹 명칭은 `whenExpectedOutcome` 패턴 권장
- Supabase 의존성은 Mock Repository로 격리

## 코딩 규칙

### Dart/Flutter 컨벤션
- `flutter_lints` 규칙 준수 (`analysis_options.yaml`)
- 들여쓰기: 2칸 공백
- 네이밍:
  - 클래스/위젯: `UpperCamelCase`
  - 함수/변수: `lowerCamelCase`
  - 파일: `snake_case` (예: `appointment_detail_screen.dart`)
- `print` 대신 디버거 또는 로깅 유틸리티 사용
- 커밋 전 `dart format` 실행 필수

### 로컬라이제이션
- 한국어·영어 지원 (`flutter_localizations`)
- 신규 UI 텍스트는 로컬라이제이션 파일에 추가

### 디자인 시스템
- `__prompts/_docs/design.md` 문서의 색상, 타이포그래피, 레이아웃 원칙 준수
- 새 디자인 자산 추가 시 해당 문서 먼저 검토

## 커밋 규칙

### Conventional Commits 패턴
- 유형: `feat`, `fix`, `refactor`, `test`, `doc`, `chore`
- 예시: `feat: 친구 초대 이메일 발송 기능 구현`
- 커밋 메시지는 한글 또는 영어 가능

### PR 체크리스트
- [ ] `flutter analyze` 통과
- [ ] `flutter test` 통과
- [ ] UI 변경 시 전후 스크린샷 첨부
- [ ] 관련 이슈가 있다면 `Closes #번호` 명시

## 에이전트 작업 프로세스

AGENTS.md에 정의된 프로세스를 준수:

### 작업 전
- 불명확한 지시는 착수 전 질문으로 명확화
- `__prompts/_task/YYYY-MM-DD-HH-MM_작업제목.md` 형식으로 로그 작성
- `__prompts/_plan/YYYY-MM-DD-HH-MM_작업제목.md`에 Todo/Plan/Working/Result 문서화

### 작업 중
- 응답 말미에 불확실성 및 추가 정보 필요 사항 명시
- 변경 전 관련 파일을 재확인하여 최신 상태 동기화
- 과거 맥락은 `__prompts/` 내부 문서로 추적

### 작업 후
- 결과 보고 전 파일 재읽기로 동기화 확인
- PRD는 `__prompts/_docs/prd.md`에 업데이트

## 참고 문서

- **PRD**: `__prompts/_docs/prd.md` - 제품 요구사항 및 우선순위
- **ERD**: `__prompts/_docs/erd.md` - 데이터베이스 스키마 설계
- **Design**: `__prompts/_docs/design.md` - 디자인 시스템 가이드
- **Plan**: `__prompts/_docs/plan.md` - 전체 개발 계획
- **README**: `README.md` - 프로젝트 개요 및 빠른 시작 가이드

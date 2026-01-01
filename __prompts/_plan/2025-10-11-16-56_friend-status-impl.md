# Todo
- [x] 친구 상태 관련 코드/화면 구조 확인
- [x] 상태 enum 및 저장소 로직을 `REQUESTED/ACCEPTED/REJECTED` 흐름에 맞게 정비
- [x] UI 배지 노출, 뷰모델 테스트 추가, 실행 결과 기록

# Plan
1. 기존 `FriendshipStatus` 사용 지점을 검토하고 `DELETED` 의존성을 식별한다.
2. Supabase 리포지토리와 모델을 `REJECTED` 상태 및 재요청 플로우에 맞춰 수정하고, UI 배지를 추가한다.
3. 뷰모델 테스트를 확장하고 `flutter test` 로 검증한 뒤, 로그를 남긴다.

# Working
- 16:52 `friendship_status.dart`, `supabase_friend_repository.dart`, 친구 화면 구조 검토.
- 16:54 상태 enum, 저장소 업데이트, UI 배지 위젯 추가, 테스트 케이스 확장.
- 16:56 `flutter test` 실행 시 macOS sandbox 권한 부족으로 실패(엔진 캐시 쓰기 권한 거부).

# Result
- 친구 상태가 `REQUESTED/ACCEPTED/REJECTED` 로 통일되고, UI에서 상태 배지가 노출되며, 뷰모델 테스트가 추가됨. 테스트 실행은 권한 문제로 미완.

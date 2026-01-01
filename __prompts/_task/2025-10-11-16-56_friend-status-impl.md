# 친구 요청 상태 구현 (2025-10-11 16:56)
- `FriendshipStatus` 를 `requested/accepted/rejected` 로 재정의하고 상태 라벨 헬퍼를 추가했다.
- Supabase 친구 리포지토리에서 REJECTED 행을 제외하고, 수락/거절/취소/삭제 시 상태 및 `updated_at` 을 갱신하도록 수정했다.
- 친구/요청 화면에 상태 배지 위젯을 추가하고, 뷰모델 테스트에 상태 분리 검증 케이스를 포함했다.
- `flutter test` 실행은 macOS sandbox 권한 부족(`engine.stamp` 쓰기 실패)으로 진행하지 못했다.

# 미가입자 친구 초대 처리 개선 (2025-10-11 18:33)
- ERD/PRD/Day2 계획서에 `friend_invites` 테이블, 초대 만료(14일)·트랜잭션·일일 20회 제한·가입 시 자동 전환 정책을 기록했다.
- `FriendshipStatus` 에 `invited` 를 추가하고, `SupabaseFriendRepository` 에 초대 생성/재전송/취소/만료/레이트 리밋 로직 및 보낸 요청 조회를 구현했다.
- `UserRepository.ensureUserProfile` 에 초대 자동 전환 로직을 추가하고, UI 배지·메시지·뷰모델·위젯 테스트를 `초대됨` 상태에 맞게 갱신했다.
- `flutter test` 와 `dart format` 은 macOS sandbox 권한(`engine.stamp` 쓰기) 문제로 실행 실패했으며, 수동 검토 후 결과를 보고했다.

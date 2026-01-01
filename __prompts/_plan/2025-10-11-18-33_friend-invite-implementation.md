# Todo
- [x] 문서에서 friend_invites 구조 및 플로우 정의
- [x] Supabase 친구 저장소/유저 저장소에 초대 처리 로직 구현
- [x] UI/테스트 갱신 및 상태 배지/메시지 반영

# Plan
1. ERD/PRD/Day2 계획서에 friend_invites 테이블, 만료/전환/제한 정책을 추가한다.
2. `SupabaseFriendRepository`와 `UserRepository` 에 초대 생성·조회·전환·취소 흐름을 구현하고, UI/뷰모델/테스트에서 `INVITED` 상태를 노출한다.
3. 테스트를 실행하고(불가 시 사유 기록) 로그를 남긴다.

# Working
- 18:06 문서 요구사항 업데이트 및 Day2 WBS 확장.
- 18:14 `FriendshipStatus`/`Friend` 확장, Supabase 저장소 초대 처리·레이트리밋 로직 작성, UI 배지 추가.
- 18:28 `UserRepository` 초대 전환 로직, 뷰모델 메시지 조정, 테스트 확장 및 초대 케이스 추가.
- 18:32 `flutter test`/`dart format` 실행 시 macOS sandbox 권한 부족으로 실패 확인.

# Result
- 문서와 코드가 friend_invites 기반 초대 저장/만료/전환/제한을 지원하도록 업데이트되었으며, UI/테스트가 `초대됨` 상태를 표시한다.

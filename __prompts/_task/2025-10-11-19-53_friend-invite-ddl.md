# friend_invites 테이블 생성 스크립트 (2025-10-11 19:53)
- 미가입자 초대 저장 요구사항을 반영해 필요한 컬럼, 상태, 제약, 인덱스를 정리했다.
- `pgcrypto` 확장을 포함해 friend_invites 테이블과 관련 트리거/인덱스를 생성하는 SQL을 작성했다.
- 결과는 `__prompts/_docs/sql_friend_invites_table.sql` 로 제공되며 Supabase 콘솔이나 CLI에서 실행하면 된다.

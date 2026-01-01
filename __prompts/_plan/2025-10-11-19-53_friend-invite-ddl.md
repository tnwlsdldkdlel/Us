# Todo
- [x] friend_invites 테이블 스키마 정의
- [x] 실행 가능한 DDL 스크립트 작성

# Plan
1. 요구된 필드/상태/만료/제약 조건을 정리한다.
2. Supabase에서 바로 실행할 수 있는 SQL 스크립트를 작성하고 저장한다.

# Working
- 19:50 요청된 필드와 제약 조건 재확인.
- 19:52 pgcrypto 확장, 테이블/인덱스/트리거를 포함한 SQL 스크립트 작성.

# Result
- friend_invites 테이블 생성용 SQL이 `__prompts/_docs/sql_friend_invites_table.sql` 에 기록됨.

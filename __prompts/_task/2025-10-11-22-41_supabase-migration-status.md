# 작업 로그: Supabase 마이그레이션 상태 확인
- 사용자 문의에 따라 Supabase MCP `list_migrations` 호출해 적용된 버전 목록을 확인
- 적용된 버전 중 `add_appointment_location_columns`, `adjust_appointments_rls_policies` 등 최근 SQL 파일과 일치하는지 점검
- 결과를 바탕으로 적용 여부 답변 준비

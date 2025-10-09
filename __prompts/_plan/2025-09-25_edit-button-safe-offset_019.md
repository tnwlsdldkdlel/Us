# Overview
- AppointmentEditScreen의 수정 버튼을 안전 영역과 키보드 상황에서 20px 갭을 유지하도록 조정

# Plan
1. 현재 플로팅 영역과 키보드 연동 스타일 로직 검토 (완료)
2. 안전 영역 및 키보드 높이에 따라 20px 여백을 유지하도록 Animated 스타일 보정
3. 스타일시트에서 하단 패딩/정렬 값 조정 및 ScrollView 패딩 재확인
4. 변경 사항 확인 후 관련 파일 저장

# Steps
- Animated 스타일에서 하단 안전 영역 보정 및 20px 갭 유지 로직을 적용
- floatingSubmitSurface 하단 패딩과 ScrollView 패딩을 체크하여 겹침 여부를 확인

# Result
- 코드 수정 완료, 실행 테스트는 미진행 (시뮬레이터에서 시각 확인 필요)

# Request
- AppointmentEditScreen의 "수정" 버튼을 항상 하단 20px 여백을 유지하고 키보드 노출 시에도 동일하게 동작하도록 업데이트 요청

# Changes
- useAnimatedKeyboard 기반 플로팅 스타일에서 키보드 높이를 안전 영역과 분리해 계산하고 20px 하단 여백을 보장하도록 보정
- Animated 뷰의 하단 패딩을 재계산해 floatingSubmitSurface의 내부 패딩과 합쳐도 20px 간격이 유지되도록 조정
- 하단 플로팅 영역 위에 ScrollView 콘텐츠가 가리지 않도록 기존 여유 패딩을 검토하여 유지

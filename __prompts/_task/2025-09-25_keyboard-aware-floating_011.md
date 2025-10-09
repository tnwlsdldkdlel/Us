# 요청 요약
- 키보드가 올라와도 메인 레이아웃을 고정하고, 키보드 위에 겹쳐지는 플로팅 `수정` 버튼을 구현해 달라는 요청.

# 적용 내역
- 키보드 이벤트에서 전달되는 높이를 상태로 추적해 플로팅 컨테이너의 `bottom` 값을 계산하고, `TouchableWithoutFeedback`으로 외부 탭 시 키보드를 닫도록 유지했습니다.
- `ScrollView` 하단 패딩을 확장해 콘텐츠가 플로팅 버튼에 가리지 않도록 했으며, 절대 위치 컨테이너(`floatingSubmitArea`, `floatingSubmitContainer`)를 추가해 버튼이 키보드 상단에 겹쳐집니다.

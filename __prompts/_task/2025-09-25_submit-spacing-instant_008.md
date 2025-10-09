# 요청 요약
- 입력 박스 터치 시 수정 버튼이 애니메이션 없이 즉시 키보드 위에 위치하도록 조정합니다.

# 적용 내역
- Animated 기반 여백 계산을 제거하고 키보드 이벤트가 발생 즉시 상태로 여백을 조정하도록 변경했습니다.
- 제출 버튼 래퍼를 일반 View로 교체하고 새 상태 값을 사용하도록 수정했습니다.
- 입력 포커스 시 `Keyboard.metrics()` 또는 저장된 마지막 높이를 활용해 미리 여백을 적용하도록 `onFocus` 핸들러를 보강했습니다.
- `Keyboard.scheduleLayoutAnimation`과 `keyboardDidChangeFrame` 이벤트를 연동해 키보드 이동과 제출 버튼 위치가 동시에 변하도록 하고, 빈 영역 터치 시 키보드가 닫히도록 `TouchableWithoutFeedback`을 추가했습니다.

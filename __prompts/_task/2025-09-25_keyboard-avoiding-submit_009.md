# 요청 요약
- 제출 버튼을 키보드 반응형(Keyboard Avoiding) UI로 전환해 수동 패딩 계산 없이 키보드에 맞춰 움직이도록 수정합니다.

# 적용 내역
- 키보드 이벤트(`keyboardWillShow`, `keyboardDidShow`, `keyboardWill/DidChangeFrame`)를 사용해 수정 버튼이 키보드와 동시에 8px 간격으로 이동하도록 상태를 제어했습니다.
- `TouchableWithoutFeedback`을 유지해 빈 영역 터치 시 키보드와 버튼이 즉시 내려가며, 버튼 상단/하단 여백을 8px로 고정했습니다.

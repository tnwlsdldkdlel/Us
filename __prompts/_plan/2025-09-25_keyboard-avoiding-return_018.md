# Overview
- `KeyboardAvoidingView`를 다시 도입해 `수정` 버튼이 키보드와 함께 자연스럽게 밀려 올라가게 하되, 버튼 뒤 컨테이너가 비어 보이지 않도록 백그라운드 색상을 유지합니다.

# Plan
1. 현재 Animated 기반 플로팅 구조를 KeyboardAvoidingView 중심 레이아웃으로 재구성할 아키텍처를 정리합니다.
2. `KeyboardAvoidingView` 하단에 버튼 영역을 배치하고, safe area/배경 색/8px 패딩을 유지하며 키보드 오프셋을 적용합니다.
3. 오프셋/스타일이 요구 사항과 부합하는지 확인하고 로그를 갱신합니다.

# Steps
- 2025-09-25: 계획 수립.
- 2025-09-25: `KeyboardAvoidingView` 기반 레이아웃으로 재구성하고, 버튼 영역을 플로팅 배경과 함께 고정했습니다.
- 2025-09-25: safe area 하단 여백과 8px 패딩을 유지하도록 스타일을 정리했습니다.

# Result
- `KeyboardAvoidingView`로 키보드가 버튼을 밀어 올리면서도 배경색이 유지되고, 버튼은 컨텐츠 위에 겹친 상태로 보입니다.

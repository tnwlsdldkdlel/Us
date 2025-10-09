# Overview
- Appointment 편집 화면의 제목/장소 입력 필드에서 머티리얼 아이콘을 직접 사용하며 onPress를 구현하고, 아이콘 크기를 24로 조정합니다.

# Plan
1. 제목/장소 입력 필드의 아이콘이 현재 TouchableOpacity로 감싸져 있는 구조를 확인합니다.
2. TouchableOpacity를 제거하고 MaterialIcons 자체에서 onPress를 처리하며, 필요한 스타일(간격 등)을 갱신합니다.
3. 불필요해진 스타일 정의를 정리하고 시각적 간격을 재조정합니다.

# Steps
- 2025-09-25: 제목/장소 입력 필드의 아이콘이 TouchableOpacity로 감싸진 구조를 다시 확인했습니다.
- 2025-09-25: TouchableOpacity를 제거하고 MaterialIcons에 onPress와 스타일을 직접 부여하면서 크기를 24로 조정했습니다.
- 2025-09-25: 사용되지 않는 스타일을 정리하고 새 간격 스타일을 추가했습니다.

# Result
- 제목/장소 입력 필드 아이콘이 MaterialIcons 단독으로 동작하며 onPress 이벤트와 24 크기가 적용되었습니다.

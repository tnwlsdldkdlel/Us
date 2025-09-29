import 'package:flutter_test/flutter_test.dart';

import 'package:us/app.dart';

void main() {
  testWidgets('메인 화면이 주요 섹션을 렌더링한다', (tester) async {
    await tester.pumpWidget(const UsApp());

    expect(find.text('Us'), findsOneWidget);
    expect(find.text('새로운 약속 시작하기'), findsOneWidget);
    expect(find.text('오늘의 약속'), findsOneWidget);
    expect(find.text('다가오는 약속'), findsOneWidget);
  });

  testWidgets('하단 내비게이션이 항목을 표출한다', (tester) async {
    await tester.pumpWidget(const UsApp());

    expect(find.text('홈'), findsOneWidget);
    expect(find.text('일정'), findsOneWidget);
    expect(find.text('메시지'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });
}

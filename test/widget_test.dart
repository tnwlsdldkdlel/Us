import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/data/friends/friend_repository.dart';
import 'package:us/screens/home/screens/home_screen.dart';

void main() {
  testWidgets('메인 화면이 주요 섹션을 렌더링한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          appointmentRepository: MockAppointmentRepository(),
          friendRepository: const MockFriendRepository(),
        ),
      ),
    );

    expect(find.text('새로운 약속 시작하기'), findsOneWidget);
    expect(find.textContaining('오늘의 약속'), findsOneWidget);
    expect(find.text('다가오는 약속'), findsOneWidget);
  });

  testWidgets('하단 내비게이션이 아이콘을 표시한다', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: HomeScreen(
          appointmentRepository: MockAppointmentRepository(),
          friendRepository: const MockFriendRepository(),
        ),
      ),
    );

    expect(find.byIcon(Icons.home_filled), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    expect(find.byIcon(Icons.group_outlined), findsOneWidget);
    expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
  });
}

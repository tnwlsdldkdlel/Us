import 'package:flutter/material.dart';

import 'package:us/data/mock_appointments.dart';
import 'package:us/theme/us_colors.dart';

import 'widgets/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayAppointments = mockTodayAppointments;
    final upcomingAppointments = mockUpcomingAppointments;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const HomeHeader(),
              const SizedBox(height: 16),
              const CreateInviteCard(),
              const SizedBox(height: 24),
              Section(
                title: '오늘의 약속',
                icon: Icons.local_fire_department_rounded,
                iconColor: UsColors.accent,
                child: Column(
                  children: [
                    for (final appointment in todayAppointments) ...[
                      TodayAppointmentCard(appointment: appointment),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Section(
                title: '다가오는 약속',
                trailing: Text(
                  '전체보기',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: UsColors.primary),
                ),
                child: Column(
                  children: [
                    for (final appointment in upcomingAppointments) ...[
                      UpcomingAppointmentTile(appointment: appointment),
                      const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const HomeNavigationBar(),
    );
  }
}

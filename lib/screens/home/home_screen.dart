import 'package:flutter/material.dart';

import 'package:us/data/mock_appointments.dart';
import 'package:us/models/appointment.dart';
import 'package:us/screens/appointment_detail/appointment_detail_screen.dart';
import 'package:us/theme/us_colors.dart';

import 'widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _openAppointmentDetail(Appointment appointment) {
    final detailId = appointment.detailId;
    if (detailId == null) {
      return;
    }
    final detail = mockAppointmentDetails[detailId];
    if (detail == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(detail: detail),
      ),
    );
  }

  void _openUpcomingAppointmentDetail(UpcomingAppointment appointment) {
    final detailId = appointment.detailId;
    if (detailId == null) {
      return;
    }
    final detail = mockAppointmentDetails[detailId];
    if (detail == null) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(detail: detail),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todayAppointments = mockTodayAppointments;
    final upcomingAppointments = mockUpcomingAppointments;

    final tabs = [
      _HomeOverviewTab(
        key: const ValueKey('home_tab'),
        todayAppointments: todayAppointments,
        upcomingAppointments: upcomingAppointments,
        onTodayAppointmentTap: _openAppointmentDetail,
        onUpcomingAppointmentTap: _openUpcomingAppointmentDetail,
      ),
      CalendarTab(
        key: const ValueKey('calendar_tab'),
        todayAppointments: todayAppointments,
        upcomingAppointments: upcomingAppointments,
        onTodayAppointmentTap: _openAppointmentDetail,
        onUpcomingAppointmentTap: _openUpcomingAppointmentDetail,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: tabs[_currentIndex],
        ),
      ),
      bottomNavigationBar: HomeNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          if (index >= tabs.length) {
            return;
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _HomeOverviewTab extends StatelessWidget {
  const _HomeOverviewTab({
    super.key,
    required this.todayAppointments,
    required this.upcomingAppointments,
    required this.onTodayAppointmentTap,
    required this.onUpcomingAppointmentTap,
  });

  final List<Appointment> todayAppointments;
  final List<UpcomingAppointment> upcomingAppointments;
  final void Function(Appointment) onTodayAppointmentTap;
  final void Function(UpcomingAppointment) onUpcomingAppointmentTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
          const SizedBox(height: 16),
          const CreateInviteCard(),
          const SizedBox(height: 24),
          Section(
            title: '🔥 오늘의 약속',
            child: Column(
              children: [
                for (final appointment in todayAppointments) ...[
                  TodayAppointmentCard(
                    appointment: appointment,
                    onTap: () => onTodayAppointmentTap(appointment),
                  ),
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
                  UpcomingAppointmentTile(
                    appointment: appointment,
                    onTap: () => onUpcomingAppointmentTap(appointment),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

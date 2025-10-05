import 'package:flutter/material.dart';

import 'package:us/data/mock_appointments.dart';
import 'package:us/models/appointment.dart';
import 'package:us/screens/appointment_detail/appointment_detail_screen.dart';
import 'package:us/screens/appointment_detail/appointment_edit_screen.dart';
import 'package:us/screens/calendar/calendar_screen.dart';
import 'package:us/screens/home/friends_screen.dart';
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
        builder: (_) =>
            AppointmentDetailScreen(detail: detail, title: detail.title),
      ),
    );
  }

  void _openCreateAppointment() {
    final now = DateTime.now();
    final newDetail = AppointmentDetail(
      id: 'new-${now.microsecondsSinceEpoch}',
      title: '',
      location: '',
      date: DateTime(now.year, now.month, now.day),
      startTime: TimeOfDay.fromDateTime(now),
      endTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
      participants: const [],
      comments: const [],
      description: '',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentEditScreen(detail: newDetail, isNew: true),
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
        builder: (_) =>
            AppointmentDetailScreen(detail: detail, title: detail.title),
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
        onCreateAppointment: _openCreateAppointment,
      ),
      CalendarScreen(
        key: const ValueKey('calendar_tab'),
        todayAppointments: todayAppointments,
        upcomingAppointments: upcomingAppointments,
        onTodayAppointmentTap: _openAppointmentDetail,
        onUpcomingAppointmentTap: _openUpcomingAppointmentDetail,
        onCreateAppointment: _openCreateAppointment,
      ),
      const FriendsScreen(key: ValueKey('friends_tab')),
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
    required this.onCreateAppointment,
  });

  final List<Appointment> todayAppointments;
  final List<UpcomingAppointment> upcomingAppointments;
  final void Function(Appointment) onTodayAppointmentTap;
  final void Function(UpcomingAppointment) onUpcomingAppointmentTap;
  final VoidCallback onCreateAppointment;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
          const SizedBox(height: 16),
          CreateInviteCard(onCreateAppointment: onCreateAppointment),
          const SizedBox(height: 24),
          Section(
            title: '🔥 오늘의 약속',
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayAppointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = todayAppointments[index];
                return TodayAppointmentCard(
                  appointment: appointment,
                  onTap: () => onTodayAppointmentTap(appointment),
                );
              },
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
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingAppointments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final appointment = upcomingAppointments[index];
                return UpcomingAppointmentTile(
                  appointment: appointment,
                  onTap: () => onUpcomingAppointmentTap(appointment),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

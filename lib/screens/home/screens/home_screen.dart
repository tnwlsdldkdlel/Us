import 'package:flutter/material.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/models/appointment.dart';
import 'package:us/screens/appointment_detail/screens/appointment_detail_screen.dart';
import 'package:us/screens/appointment_detail/screens/appointment_edit_screen.dart';
import 'package:us/screens/calendar/screens/calendar_screen.dart';
import 'package:us/screens/friends/screens/friends_screen.dart';
import 'package:us/screens/home/models/home_view_model.dart';
import 'package:us/screens/home/widgets/widgets.dart';
import 'package:us/screens/settings/screens/settings_screen.dart';
import 'package:us/theme/us_colors.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key, AppointmentRepository? appointmentRepository})
    : appointmentRepository =
          appointmentRepository ?? MockAppointmentRepository();

  final AppointmentRepository appointmentRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(repository: widget.appointmentRepository)
      ..loadAppointments();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _openAppointmentDetail(Appointment appointment) {
    final detailId = appointment.detailId;
    if (detailId == null) {
      return;
    }
    final detail = _viewModel.findDetail(detailId);
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
    final newDetail = _viewModel.createDraftDetail();

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
    final detail = detailId.isEmpty ? null : _viewModel.findDetail(detailId);
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
    return AnimatedBuilder(
      animation: _viewModel,
      builder: (context, _) {
        final state = _viewModel.state;

        final tabs = [
          _HomeOverviewTab(
            key: const ValueKey('home_tab'),
            todayAppointments: state.todayAppointments,
            upcomingAppointments: state.upcomingAppointments,
            onTodayAppointmentTap: _openAppointmentDetail,
            onUpcomingAppointmentTap: _openUpcomingAppointmentDetail,
            onCreateAppointment: _openCreateAppointment,
          ),
          CalendarScreen(
            key: const ValueKey('calendar_tab'),
            todayAppointments: state.todayAppointments,
            upcomingAppointments: state.upcomingAppointments,
            onTodayAppointmentTap: _openAppointmentDetail,
            onUpcomingAppointmentTap: _openUpcomingAppointmentDetail,
            onCreateAppointment: _openCreateAppointment,
          ),
          const FriendsScreen(key: ValueKey('friends_tab')),
          const SettingsScreen(key: ValueKey('settings_tab')),
        ];

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: tabs[_currentIndex],
                ),
                if (state.isLoading)
                  const Align(
                    alignment: Alignment.topCenter,
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
              ],
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
      },
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.spacingM,
        vertical: AppSpacing.spacingM,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(),
          const SizedBox(height: AppSpacing.spacingM),
          CreateInviteCard(onCreateAppointment: onCreateAppointment),
          const SizedBox(height: AppSpacing.spacingL),
          Section(
            title: '🔥 오늘의 약속',
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: todayAppointments.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.spacingM),
              itemBuilder: (context, index) {
                final appointment = todayAppointments[index];
                return TodayAppointmentCard(
                  appointment: appointment,
                  onTap: () => onTodayAppointmentTap(appointment),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.spacingL),
          Section(
            title: '다가오는 약속',
            trailing: Text(
              '전체보기',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: upcomingAppointments.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.spacingM),
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

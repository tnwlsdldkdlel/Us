import 'package:flutter/material.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/data/appointments/supabase_appointment_repository.dart';
import 'package:us/data/friends/friend_repository.dart';
import 'package:us/data/friends/supabase_friend_repository.dart';
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
  HomeScreen({
    super.key,
    AppointmentRepository? appointmentRepository,
    FriendRepository? friendRepository,
  })  : appointmentRepository =
          appointmentRepository ?? SupabaseAppointmentRepository(),
        friendRepository = friendRepository ?? SupabaseFriendRepository();

  final AppointmentRepository appointmentRepository;
  final FriendRepository friendRepository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final HomeViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel(repository: widget.appointmentRepository);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadAppointments();
    });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  Future<void> _openAppointmentDetail(Appointment appointment) async {
    final detailId = appointment.detailId;
    if (detailId == null) {
      return;
    }

    final detail = await _viewModel.fetchDetail(detailId);
    if (!mounted) {
      return;
    }
    if (detail == null) {
      _showMessage('약속 정보를 불러오지 못했습니다.');
      return;
    }
    _navigateToDetail(detail);
  }

  Future<void> _openCreateAppointment() async {
    final draft = _viewModel.createDraftDetail();

    final created = await Navigator.of(context).push<AppointmentDetail>(
      MaterialPageRoute(
        builder: (_) => AppointmentEditScreen(
          detail: draft,
          isNew: true,
          appointmentRepository: widget.appointmentRepository,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (created != null) {
      await _viewModel.loadAppointments();
      if (!mounted) {
        return;
      }
      _navigateToDetail(created);
    }
  }

  Future<void> _openUpcomingAppointmentDetail(
    UpcomingAppointment appointment,
  ) async {
    final detailId = appointment.detailId;
    if (detailId == null || detailId.isEmpty) {
      return;
    }

    final detail = await _viewModel.fetchDetail(detailId);
    if (!mounted) {
      return;
    }
    if (detail == null) {
      _showMessage('약속 정보를 불러오지 못했습니다.');
      return;
    }
    _navigateToDetail(detail);
  }

  void _navigateToDetail(AppointmentDetail detail) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AppointmentDetailScreen(
          detail: detail,
          title: detail.title,
          appointmentRepository: widget.appointmentRepository,
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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
          FriendsScreen(
            key: const ValueKey('friends_tab'),
            friendRepository: widget.friendRepository,
          ),
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
                if (state.errorMessage != null)
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFF97316)),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          state.errorMessage!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFB45309),
                              ),
                        ),
                      ),
                    ),
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
  final Future<void> Function(Appointment) onTodayAppointmentTap;
  final Future<void> Function(UpcomingAppointment) onUpcomingAppointmentTap;
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

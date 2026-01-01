import 'package:flutter/foundation.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/models/appointment.dart';

@immutable
class HomeState {
  const HomeState({
    required this.isLoading,
    required this.todayAppointments,
    required this.upcomingAppointments,
    this.errorMessage,
  });

  const HomeState.initial()
    : isLoading = true,
      todayAppointments = const [],
      upcomingAppointments = const [],
      errorMessage = null;

  final bool isLoading;
  final List<Appointment> todayAppointments;
  final List<UpcomingAppointment> upcomingAppointments;
  final String? errorMessage;

  HomeState copyWith({
    bool? isLoading,
    List<Appointment>? todayAppointments,
    List<UpcomingAppointment>? upcomingAppointments,
    String? Function()? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
    );
  }
}

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AppointmentRepository repository})
    : _repository = repository,
      _state = const HomeState.initial();

  final AppointmentRepository _repository;
  HomeState _state;

  HomeState get state => _state;

  Future<void> loadAppointments() async {
    _state = _state.copyWith(isLoading: true, errorMessage: () => null);
    notifyListeners();

    try {
      final overview = await _repository.fetchOverview();
      _state = HomeState(
        isLoading: false,
        todayAppointments: overview.today,
        upcomingAppointments: overview.upcoming,
        errorMessage: null,
      );
    } catch (_) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: () => '약속 정보를 불러오지 못했습니다.',
      );
    }
    notifyListeners();
  }

  Future<AppointmentDetail?> fetchDetail(String id) =>
      _repository.fetchDetailById(id);

  AppointmentDetail createDraftDetail({DateTime? reference}) =>
      _repository.createDraftDetail(reference: reference);
}

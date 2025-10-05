import 'package:flutter/foundation.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/models/appointment.dart';

@immutable
class HomeState {
  const HomeState({
    required this.isLoading,
    required this.todayAppointments,
    required this.upcomingAppointments,
  });

  const HomeState.initial()
      : isLoading = true,
        todayAppointments = const [],
        upcomingAppointments = const [];

  final bool isLoading;
  final List<Appointment> todayAppointments;
  final List<UpcomingAppointment> upcomingAppointments;

  HomeState copyWith({
    bool? isLoading,
    List<Appointment>? todayAppointments,
    List<UpcomingAppointment>? upcomingAppointments,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      todayAppointments: todayAppointments ?? this.todayAppointments,
      upcomingAppointments: upcomingAppointments ?? this.upcomingAppointments,
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

  void loadAppointments() {
    final today = _repository.getTodayAppointments();
    final upcoming = _repository.getUpcomingAppointments();

    _state = HomeState(
      isLoading: false,
      todayAppointments: today,
      upcomingAppointments: upcoming,
    );
    notifyListeners();
  }

  AppointmentDetail? findDetail(String id) => _repository.findDetailById(id);

  AppointmentDetail createDraftDetail({DateTime? reference}) =>
      _repository.createDraftDetail(reference: reference);
}

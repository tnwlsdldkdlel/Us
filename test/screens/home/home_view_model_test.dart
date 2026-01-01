import 'package:flutter_test/flutter_test.dart';

import 'package:us/data/appointments/appointment_repository.dart';
import 'package:us/screens/home/models/home_view_model.dart';

void main() {
  group('HomeViewModel', () {
    late HomeViewModel viewModel;
    late AppointmentRepository repository;

    setUp(() {
      repository = MockAppointmentRepository();
      viewModel = HomeViewModel(repository: repository);
    });

    test('loads appointments from repository', () async {
      expect(viewModel.state.isLoading, isTrue);

      await viewModel.loadAppointments();

      expect(viewModel.state.isLoading, isFalse);
      expect(viewModel.state.todayAppointments, isNotEmpty);
      expect(viewModel.state.upcomingAppointments, isNotEmpty);
    });

    test('fetchDetail returns appointment detail when it exists', () async {
      await viewModel.loadAppointments();
      final appointments = viewModel.state.todayAppointments;
      final detailId = appointments.first.detailId;

      final detail = detailId == null
          ? null
          : await viewModel.fetchDetail(detailId);

      expect(detail, isNotNull);
      expect(detail?.id, equals(detailId));
    });

    test('createDraftDetail returns detail with sensible defaults', () {
      final draft = viewModel.createDraftDetail();

      expect(draft.title, isEmpty);
      expect(draft.location, isEmpty);
      expect(draft.participants, isEmpty);
      expect(draft.comments, isEmpty);
      expect(draft.startTime.hour <= draft.endTime.hour, isTrue);
    });
  });
}

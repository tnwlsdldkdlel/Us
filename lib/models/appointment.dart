class Appointment {
  const Appointment({
    required this.title,
    required this.location,
    required this.timeLabel,
    this.description,
    this.participants = const [],
  });

  final String title;
  final String location;
  final String timeLabel;
  final String? description;
  final List<String> participants;
}

class UpcomingAppointment {
  const UpcomingAppointment({
    required this.title,
    required this.location,
    required this.remaining,
    this.note,
  });

  final String title;
  final String location;
  final String remaining;
  final String? note;
}

import 'package:meta/meta.dart';

@immutable
class AppointmentDraft {
  const AppointmentDraft({
    required this.title,
    required this.startAt,
    required this.duration,
    required this.locationName,
    required this.invitedFriendIds,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  final String title;
  final DateTime startAt;
  final Duration duration;
  final String locationName;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<String> invitedFriendIds;

  DateTime get endAt => startAt.add(duration);
}

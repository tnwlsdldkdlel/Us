import 'package:flutter/material.dart';

class Appointment {
  const Appointment({
    required this.title,
    required this.location,
    required this.timeLabel,
    this.description,
    this.participants = const [],
    this.detailId,
  });

  final String title;
  final String location;
  final String timeLabel;
  final String? description;
  final List<String> participants;
  final String? detailId;
}

class UpcomingAppointment {
  const UpcomingAppointment({
    required this.title,
    required this.location,
    required this.remaining,
    this.note,
    this.detailId,
  });

  final String title;
  final String location;
  final String remaining;
  final String? note;
  final String? detailId;
}

enum AttendanceStatus { going, pending, declined }

class ParticipantStatus {
  const ParticipantStatus({
    required this.name,
    required this.status,
    required this.statusLabel,
    required this.avatarInitial,
    required this.avatarColor,
  });

  final String name;
  final AttendanceStatus status;
  final String statusLabel;
  final String avatarInitial;
  final int avatarColor;
}

class AppointmentComment {
  const AppointmentComment({
    required this.author,
    required this.message,
    required this.timeLabel,
  });

  final String author;
  final String message;
  final String timeLabel;
}

class AppointmentDetail {
  const AppointmentDetail({
    required this.id,
    required this.title,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.location,
    required this.participants,
    required this.comments,
    this.description,
  });

  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String? description;
  final List<ParticipantStatus> participants;
  final List<AppointmentComment> comments;
}

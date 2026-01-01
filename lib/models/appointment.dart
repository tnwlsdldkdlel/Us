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
    required this.userId,
    required this.name,
    required this.status,
    required this.statusLabel,
    required this.avatarInitial,
    required this.avatarColor,
    this.email,
    this.avatarUrl,
  });

  final String userId;
  final String name;
  final String? email;
  final String? avatarUrl;
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
    required this.creatorId,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
  });

  final String id;
  final String title;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String location;
  final String creatorId;
  final String? description;
  final String? address;
  final double? latitude;
  final double? longitude;
  final List<ParticipantStatus> participants;
  final List<AppointmentComment> comments;

  AppointmentDetail copyWith({
    String? id,
    String? title,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? location,
    String? creatorId,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    List<ParticipantStatus>? participants,
    List<AppointmentComment>? comments,
  }) {
    return AppointmentDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      creatorId: creatorId ?? this.creatorId,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      participants: participants ?? this.participants,
      comments: comments ?? this.comments,
    );
  }
}

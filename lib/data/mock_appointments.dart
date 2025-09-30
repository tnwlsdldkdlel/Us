import 'package:flutter/material.dart';

import '../models/appointment.dart';

final mockTodayAppointments = [
  Appointment(
    title: '한강에서 저녁',
    location: '압강',
    timeLabel: '12:00',
    description: '남영훈 외 6명과 함께 만나요!',
    participants: ['N', 'S', 'Y', '+3'],
    detailId: 'hanRiverDinner',
  ),
  Appointment(
    title: '수진이 생일파티',
    location: '우시성',
    timeLabel: '12:00',
    description: '남영훈과 만나서 만나요!',
    participants: ['S', 'J', 'M'],
    detailId: 'suzyBirthday',
  ),
];

final mockUpcomingAppointments = [
  UpcomingAppointment(
    title: '주말 등산',
    location: '북한산 등산로',
    remaining: '내일',
    detailId: 'mountainHike',
  ),
  UpcomingAppointment(
    title: '생일 파티',
    location: '우정빌딩 1층',
    remaining: '9일 남음',
    note: '아직 장소를 정하지 않았어요 😳',
    detailId: 'officeBirthday',
  ),
];

final today = DateTime.now();

final mockAppointmentDetails = {
  'hanRiverDinner': AppointmentDetail(
    id: 'hanRiverDinner',
    title: '한강에서 저녁',
    date: today,
    startTime: TimeOfDay(hour: 10, minute: 0),
    endTime: TimeOfDay(hour: 14, minute: 0),
    location: '한강',
    description: '따뜻한 커피와 함께하는 피크닉 모임이에요.',
    participants: [
      ParticipantStatus(
        name: '최현우',
        status: AttendanceStatus.going,
        statusLabel: '참여',
        avatarInitial: '최',
        avatarColor: 0xFF10B981,
      ),
      ParticipantStatus(
        name: '정유진',
        status: AttendanceStatus.pending,
        statusLabel: '대기',
        avatarInitial: '정',
        avatarColor: 0xFF38BDF8,
      ),
      ParticipantStatus(
        name: '강태민',
        status: AttendanceStatus.declined,
        statusLabel: '거절',
        avatarInitial: '강',
        avatarColor: 0xFFF97316,
      ),
    ],
    comments: [
      AppointmentComment(
        author: '최현우',
        message: '약속 기다리고 있을게요!',
        timeLabel: '2시간 전',
      ),
      AppointmentComment(
        author: '정유진',
        message: '다들 내일 봐요~',
        timeLabel: '1월 27일',
      ),
    ],
  ),
  'suzyBirthday': AppointmentDetail(
    id: 'suzyBirthday',
    title: '수진이 생일파티',
    date: today,
    startTime: TimeOfDay(hour: 19, minute: 0),
    endTime: TimeOfDay(hour: 22, minute: 0),
    location: '우시성',
    description: '드레스 코드: 파스텔 색상 🎉',
    participants: [
      ParticipantStatus(
        name: '남영훈',
        status: AttendanceStatus.going,
        statusLabel: '참여',
        avatarInitial: '남',
        avatarColor: 0xFF6366F1,
      ),
      ParticipantStatus(
        name: '김지수',
        status: AttendanceStatus.pending,
        statusLabel: '대기',
        avatarInitial: '김',
        avatarColor: 0xFFEC4899,
      ),
      ParticipantStatus(
        name: '박민아',
        status: AttendanceStatus.going,
        statusLabel: '참여',
        avatarInitial: '박',
        avatarColor: 0xFF0EA5E9,
      ),
    ],
    comments: [
      AppointmentComment(
        author: '남영훈',
        message: '선물 준비 완료! 기대돼요.',
        timeLabel: '5시간 전',
      ),
      AppointmentComment(
        author: '김지수',
        message: '조금 늦을 수도 있어요!',
        timeLabel: '어제',
      ),
    ],
  ),
  'mountainHike': AppointmentDetail(
    id: 'mountainHike',
    title: '주말 등산',
    date: today.add(const Duration(days: 1)),
    startTime: TimeOfDay(hour: 7, minute: 30),
    endTime: TimeOfDay(hour: 12, minute: 0),
    location: '북한산 등산로',
    description: '초보 코스, 간단한 도시락을 준비해주세요.',
    participants: [
      ParticipantStatus(
        name: '이도현',
        status: AttendanceStatus.going,
        statusLabel: '참여',
        avatarInitial: '이',
        avatarColor: 0xFF14B8A6,
      ),
      ParticipantStatus(
        name: '박가은',
        status: AttendanceStatus.going,
        statusLabel: '참여',
        avatarInitial: '박',
        avatarColor: 0xFFF472B6,
      ),
      ParticipantStatus(
        name: '조민석',
        status: AttendanceStatus.pending,
        statusLabel: '대기',
        avatarInitial: '조',
        avatarColor: 0xFF94A3B8,
      ),
    ],
    comments: [
      AppointmentComment(
        author: '이도현',
        message: '새 등산화 샀어요! 빨리 신고 싶네요.',
        timeLabel: '3시간 전',
      ),
      AppointmentComment(
        author: '박가은',
        message: '간식 뭐 가져갈까요?',
        timeLabel: '1월 26일',
      ),
    ],
  ),
  'officeBirthday': AppointmentDetail(
    id: 'officeBirthday',
    title: '생일 파티',
    date: today.add(const Duration(days: 9)),
    startTime: TimeOfDay(hour: 18, minute: 0),
    endTime: TimeOfDay(hour: 21, minute: 0),
    location: '우정빌딩 1층',
    description: '케이크와 간단한 다과가 준비될 예정이에요.',
    participants: [
      ParticipantStatus(
        name: '최지훈',
        status: AttendanceStatus.going,
        statusLabel: '참여',
        avatarInitial: '최',
        avatarColor: 0xFF22C55E,
      ),
      ParticipantStatus(
        name: '윤세라',
        status: AttendanceStatus.pending,
        statusLabel: '대기',
        avatarInitial: '윤',
        avatarColor: 0xFFFB7185,
      ),
      ParticipantStatus(
        name: '문주원',
        status: AttendanceStatus.declined,
        statusLabel: '거절',
        avatarInitial: '문',
        avatarColor: 0xFFF97316,
      ),
    ],
    comments: [
      AppointmentComment(
        author: '최지훈',
        message: '장소 예약 완료했어요.',
        timeLabel: '2일 전',
      ),
    ],
  ),
};

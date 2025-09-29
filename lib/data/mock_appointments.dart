import '../models/appointment.dart';

const mockTodayAppointments = [
  Appointment(
    title: '한강에서 저녁',
    location: '압강',
    timeLabel: '12:00',
    description: '남영훈 외 6명과 함께 만나요!',
    participants: ['N', 'S', 'Y', '+3'],
  ),
  Appointment(
    title: '수진이 생일파티',
    location: '우시성',
    timeLabel: '12:00',
    description: '남영훈과 만나서 만나요!',
    participants: ['S', 'J', 'M'],
  ),
];

const mockUpcomingAppointments = [
  UpcomingAppointment(title: '주말 등산', location: '북한산 등산로', remaining: '내일'),
  UpcomingAppointment(
    title: '생일 파티',
    location: '우정빌딩 1층',
    remaining: '9일 남음',
    note: '아직 장소를 정하지 않았어요 😳',
  ),
];

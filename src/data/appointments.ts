export type ParticipantStatus = "confirmed" | "pending" | "declined";

export type Participant = {
  id: string;
  name: string;
  color: string;
  status: ParticipantStatus;
};

export type Comment = {
  id: string;
  authorId: string;
  message: string;
  timestamp: string;
};

export type Appointment = {
  id: string;
  title: string;
  date: string; // ISO date without time
  startTime: string; // ISO datetime
  endTime: string; // ISO datetime
  location: string;
  highlight: string;
  message: string;
  participants: Participant[];
  extraLabel?: string;
  comments: Comment[];
};

const today = new Date();
const baseDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());

function toISODate(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}-${month}-${day}`;
}

function toISODateTime(date: Date, hours: number, minutes: number): string {
  const dt = new Date(
    date.getFullYear(),
    date.getMonth(),
    date.getDate(),
    hours,
    minutes,
    0,
    0
  );
  return dt.toISOString();
}

const nextWeekend = new Date(baseDate);
nextWeekend.setDate(baseDate.getDate() + 5);

export const appointments: Appointment[] = [
  {
    id: "han-river",
    title: "한강에서 치맥",
    date: toISODate(baseDate),
    startTime: toISODateTime(baseDate, 10, 0),
    endTime: toISODateTime(baseDate, 14, 0),
    location: "한강",
    highlight: "남영훈님 외 6명",
    message: "과 함께 만나요! 👋🏻",
    participants: [
      { id: "nam", name: "남영훈", color: "#0EA5E9", status: "confirmed" },
      { id: "yu", name: "정유진", color: "#F97316", status: "pending" },
      { id: "kang", name: "강태민", color: "#6366F1", status: "declined" },
    ],
    extraLabel: "+1",
    comments: [
      {
        id: "comment-1",
        authorId: "nam",
        message: "약속 기다리고 있을게요!",
        timestamp: toISODateTime(baseDate, 14, 0),
      },
      {
        id: "comment-2",
        authorId: "yu",
        message: "다들 내일 봬요~",
        timestamp: toISODateTime(baseDate, 9, 0),
      },
    ],
  },
  {
    id: "hiking",
    title: "주말 등산",
    date: toISODate(nextWeekend),
    startTime: toISODateTime(nextWeekend, 9, 0),
    endTime: toISODateTime(nextWeekend, 12, 0),
    location: "북한산 등산로",
    highlight: "남영훈님",
    message: "이끄는 등산 모임! 🥾",
    participants: [
      { id: "nam", name: "남영훈", color: "#0EA5E9", status: "confirmed" },
      { id: "park", name: "박소영", color: "#34D399", status: "confirmed" },
    ],
    comments: [],
  },
  {
    id: "birthday",
    title: "수진이 생일파티",
    date: toISODate(nextWeekend),
    startTime: toISODateTime(nextWeekend, 20, 0),
    endTime: toISODateTime(nextWeekend, 23, 0),
    location: "자곡동",
    highlight: "남형준님",
    message: "과 함께 만나요! 👋🏻",
    participants: [
      { id: "nam", name: "남영훈", color: "#0EA5E9", status: "confirmed" },
      { id: "su", name: "수진", color: "#F59E0B", status: "confirmed" },
    ],
    comments: [],
  },
];

export function getAppointmentById(id: string): Appointment | undefined {
  return appointments.find((appointment) => appointment.id === id);
}

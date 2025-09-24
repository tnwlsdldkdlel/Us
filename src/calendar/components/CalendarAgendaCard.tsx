import type { ReactElement } from "react";
import TodayAppointmentCard from "../../content/components/TodayAppointmentCard";

type CalendarAgendaCardProps = {
  title: string;
  location: string;
  time: string;
  highlight?: string;
  message: string;
  participants?: { initials: string; color: string }[];
  extraLabel?: string;
  onPress?: () => void;
};

export default function CalendarAgendaCard(
  props: CalendarAgendaCardProps
): ReactElement {
  return <TodayAppointmentCard {...props} />;
}

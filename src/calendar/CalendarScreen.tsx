import type { ReactElement } from "react";
import { useMemo, useState } from "react";
import { ScrollView, Text, View } from "react-native";
import { useNavigation } from "@react-navigation/native";
import type { NavigationProp } from "@react-navigation/native";
import { SafeAreaView } from "react-native-safe-area-context";
import CalendarView from "./components/CalendarView";
import CalendarAgendaCard from "./components/CalendarAgendaCard";
import { calendarStyles } from "./styles";
import { buildMonthMatrix, isSameDay, startOfDay } from "./utils/date";
import { appointments } from "../data/appointments";
import type { RootStackParamList } from "../navigation/types";

export default function CalendarScreen(): ReactElement {
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const today = useMemo(() => startOfDay(new Date()), []);
  const [baseDate, setBaseDate] = useState(
    () => new Date(today.getFullYear(), today.getMonth(), 1)
  );
  const [selectedDate, setSelectedDate] = useState(today);

  const visibleMonthDays = useMemo(() => buildMonthMatrix(baseDate), [baseDate]);

  const timeFormatter = useMemo(
    () =>
      new Intl.DateTimeFormat("ko-KR", {
        hour: "2-digit",
        minute: "2-digit",
        hour12: false,
      }),
    []
  );

  const filteredAgenda = useMemo(() => {
    return appointments
      .filter((appointment) =>
        isSameDay(new Date(appointment.date), selectedDate)
      )
      .map((appointment) => ({
        id: appointment.id,
        title: appointment.title,
        location: appointment.location,
        time: timeFormatter.format(new Date(appointment.startTime)),
        highlight: appointment.highlight,
        message: appointment.message,
        participants: appointment.participants.map((participant) => ({
          initials: participant.name.slice(0, 1),
          color: participant.color,
        })),
        extraLabel: appointment.extraLabel,
      }));
  }, [selectedDate, timeFormatter]);

  return (
    <SafeAreaView
      style={calendarStyles.safeArea}
      edges={["top", "left", "right", "bottom"]}
    >
      <ScrollView
        contentContainerStyle={calendarStyles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <CalendarView
          baseDate={baseDate}
          monthMatrix={visibleMonthDays}
          selectedDate={selectedDate}
          onPrevMonth={() =>
            setBaseDate((prev) => {
              const next = new Date(prev.getFullYear(), prev.getMonth() - 1, 1);
              setSelectedDate(next);
              return next;
            })
          }
          onNextMonth={() =>
            setBaseDate((prev) => {
              const next = new Date(prev.getFullYear(), prev.getMonth() + 1, 1);
              setSelectedDate(next);
              return next;
            })
          }
          onSelectDate={(date) => {
            setSelectedDate(date);
            if (date.getMonth() !== baseDate.getMonth()) {
              setBaseDate(new Date(date.getFullYear(), date.getMonth(), 1));
            }
          }}
        />
        <View style={calendarStyles.agendaSection}>
          {filteredAgenda.length === 0 ? (
            <View style={calendarStyles.emptyState}>
              <Text style={calendarStyles.emptyStateText}>
                선택한 날짜에 일정이 없어요.
              </Text>
            </View>
          ) : (
            filteredAgenda.map((item) => (
              <CalendarAgendaCard
                key={item.id}
                {...item}
                onPress={() =>
                  navigation.navigate("AppointmentDetail", {
                    appointmentId: item.id,
                  })
                }
              />
            ))
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

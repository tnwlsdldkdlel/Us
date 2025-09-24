import type { ReactElement } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import { Text, TouchableOpacity, View } from "react-native";
import { calendarViewStyles } from "../styles";
import { isSameDay, startOfDay, type CalendarDay } from "../utils/date";

const WEEKDAY_LABELS = ["일", "월", "화", "수", "목", "금", "토"];

type CalendarViewProps = {
  baseDate: Date;
  monthMatrix: CalendarDay[][];
  selectedDate: Date;
  onPrevMonth: () => void;
  onNextMonth: () => void;
  onSelectDate: (date: Date) => void;
};

export default function CalendarView({
  baseDate,
  monthMatrix,
  selectedDate,
  onPrevMonth,
  onNextMonth,
  onSelectDate,
}: CalendarViewProps): ReactElement {
  const today = startOfDay(new Date());
  const headerLabel = `${baseDate.getFullYear()}년 ${baseDate.getMonth() + 1}월`;

  return (
    <View style={calendarViewStyles.container}>
      <View style={calendarViewStyles.header}>
        <TouchableOpacity onPress={onPrevMonth}>
          <MaterialIcons name="chevron-left" size={22} color="#111" />
        </TouchableOpacity>
        <Text style={calendarViewStyles.headerTitle}>{headerLabel}</Text>
        <TouchableOpacity onPress={onNextMonth}>
          <MaterialIcons name="chevron-right" size={22} color="#111" />
        </TouchableOpacity>
      </View>
      <View style={calendarViewStyles.weekdayRow}>
        {WEEKDAY_LABELS.map((label) => (
          <Text key={label} style={calendarViewStyles.weekdayLabel}>
            {label}
          </Text>
        ))}
      </View>
      <View style={calendarViewStyles.grid}>
        {monthMatrix.map((week, rowIdx) => (
          <View key={`week-${rowIdx}`} style={calendarViewStyles.weekRow}>
            {week.map(({ date, isCurrentMonth }, colIdx) => {
              const normalized = startOfDay(date);
              const isToday = isSameDay(normalized, today);
              const isSelected = isSameDay(normalized, selectedDate);
              return (
                <TouchableOpacity
                  key={`day-${rowIdx}-${colIdx}`}
                  style={[
                    calendarViewStyles.dayCell,
                    isSelected && calendarViewStyles.selectedCell,
                  ]}
                  onPress={() => onSelectDate(normalized)}
                  activeOpacity={0.8}
                >
                  <Text
                    style={[
                      calendarViewStyles.dayText,
                      !isCurrentMonth && calendarViewStyles.mutedDayText,
                      isSelected && calendarViewStyles.selectedText,
                      !isSelected && isToday && calendarViewStyles.todayOutlineText,
                    ]}
                  >
                    {date.getDate()}
                  </Text>
                  {isSelected ? (
                    <View style={calendarViewStyles.indicator} />
                  ) : null}
                </TouchableOpacity>
              );
            })}
          </View>
        ))}
      </View>
    </View>
  );
}

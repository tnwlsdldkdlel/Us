import type { ReactElement } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import { Text, TouchableOpacity, View } from "react-native";
import { todayCardStyles } from "./styles";

type Participant = {
  initials: string;
  color: string;
};

type TodayAppointmentCardProps = {
  title: string;
  location: string;
  time: string;
  message: string;
  highlight?: string;
  participants?: Participant[];
  extraLabel?: string;
  onPress?: () => void;
};

export default function TodayAppointmentCard({
  title,
  location,
  time,
  message,
  highlight,
  participants,
  extraLabel,
  onPress,
}: TodayAppointmentCardProps): ReactElement {
  return (
    <TouchableOpacity
      style={todayCardStyles.container}
      activeOpacity={0.85}
      onPress={onPress}
    >
      <View style={todayCardStyles.accent} />
      <View style={todayCardStyles.content}>
        <View>
          <View style={todayCardStyles.headerRow}>
            <Text style={todayCardStyles.title}>{title}</Text>
            <View style={todayCardStyles.timeContainer}>
              <Text style={todayCardStyles.timeText}>{time}</Text>
            </View>
          </View>
          <View style={todayCardStyles.locationRow}>
            <MaterialIcons name="place" size={16} color="#10B981" />
            <Text style={todayCardStyles.locationText}>{location}</Text>
          </View>
          <View style={todayCardStyles.messageRow}>
            <Text style={todayCardStyles.message}>
              {highlight ? (
                <Text style={todayCardStyles.highlight}>
                  {highlight}
                  {" "}
                </Text>
              ) : null}
              {message}
            </Text>
            {participants && participants.length > 0 ? (
              <View style={todayCardStyles.participantsRow}>
                {participants.map((participant) => (
                  <View
                    key={`${participant.initials}-${participant.color}`}
                    style={[
                      todayCardStyles.participantAvatar,
                      { backgroundColor: participant.color },
                    ]}
                  >
                    <Text style={todayCardStyles.participantLabel}>
                      {participant.initials}
                    </Text>
                  </View>
                ))}
                {extraLabel ? (
                  <View style={todayCardStyles.extraChip}>
                    <Text style={todayCardStyles.extraChipText}>{extraLabel}</Text>
                  </View>
                ) : null}
              </View>
            ) : null}
          </View>
        </View>
      </View>
    </TouchableOpacity>
  );
}

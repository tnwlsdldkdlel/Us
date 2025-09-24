import type { ReactElement } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import { Text, TouchableOpacity, View } from "react-native";
import { upcomingCardStyles } from "./styles";

type UpcomingAppointmentCardProps = {
  title: string;
  location?: string | null;
  badgeLabel: string;
  onPress?: () => void;
};

export default function UpcomingAppointmentCard({
  title,
  location,
  badgeLabel,
  onPress,
}: UpcomingAppointmentCardProps): ReactElement {
  return (
    <TouchableOpacity
      style={upcomingCardStyles.container}
      activeOpacity={0.85}
      onPress={onPress}
    >
      <View style={upcomingCardStyles.headerRow}>
        <Text style={upcomingCardStyles.title}>{title}</Text>
        <View style={upcomingCardStyles.badge}>
          <Text style={upcomingCardStyles.badgeText}>{badgeLabel}</Text>
        </View>
      </View>
      <View style={upcomingCardStyles.locationRow}>
        {location ? (
          <>
            <MaterialIcons name="place" size={16} color="#9CA3AF" />
            <Text style={[upcomingCardStyles.locationText]}>{location}</Text>
          </>
        ) : (
          <Text style={upcomingCardStyles.locationText}>
            아직 장소를 정하지 않았어요.
          </Text>
        )}
      </View>
    </TouchableOpacity>
  );
}

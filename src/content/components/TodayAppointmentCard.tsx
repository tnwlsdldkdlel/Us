import type { ReactElement } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import { Text, View } from "react-native";
import { todayCardStyles } from "./styles";
import { colors } from "src/styles/theme";

export default function TodayAppointmentCard(): ReactElement {
  return (
    <View style={todayCardStyles.container}>
      <View style={todayCardStyles.accent} />
      <View style={todayCardStyles.content}>
        <View>
          <View style={todayCardStyles.titleRow}>
            <Text style={todayCardStyles.title}>한강에서 치맥</Text>
            <View style={todayCardStyles.timeContainer}>
              <Text style={todayCardStyles.timeText}>12:00</Text>
            </View>
          </View>
          <View style={todayCardStyles.locationRow}>
            <MaterialIcons name="place" size={16} color="#6B7280" />
            <Text style={todayCardStyles.locationText}>한강</Text>
          </View>
        </View>
        <Text style={todayCardStyles.message}>
          <Text style={{ color: colors.accent }}>치맥동아리</Text>에서 만나요!
          👋🏻
        </Text>
      </View>
    </View>
  );
}

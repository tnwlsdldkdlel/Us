import type { ReactElement } from "react";
import { StatusBar } from "expo-status-bar";
import { Text, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import StartAppointmentCard from "./components/StartAppointmentCard";
import TodayAppointmentCard from "./components/TodayAppointmentCard";
import { contentStyles } from "./styles";

export default function HomeScreen(): ReactElement {
  return (
    <SafeAreaView
      edges={["left", "right", "bottom"]}
      style={contentStyles.safeArea}
    >
      <View style={contentStyles.container}>
        <StartAppointmentCard />
        <Text style={contentStyles.sectionHeading}>🔥 오늘의 약속</Text>
        <TodayAppointmentCard />
        <StatusBar style="dark" />
      </View>
    </SafeAreaView>
  );
}

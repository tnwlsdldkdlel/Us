import type { ReactElement } from "react";
import { useMemo } from "react";
import { StatusBar } from "expo-status-bar";
import { ScrollView, Text, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useNavigation } from "@react-navigation/native";
import type { NavigationProp } from "@react-navigation/native";
import StartAppointmentCard from "./components/StartAppointmentCard";
import TodayAppointmentCard from "./components/TodayAppointmentCard";
import UpcomingAppointmentCard from "./components/UpcomingAppointmentCard";
import { contentStyles } from "./styles";
import { appointments } from "../data/appointments";
import type { RootStackParamList } from "../navigation/types";

function formatTimeLabel(date: Date): string {
  return new Intl.DateTimeFormat("ko-KR", {
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  }).format(date);
}

export default function HomeScreen(): ReactElement {
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();

  const todayAppointments = useMemo(() => {
    return appointments.slice(0, 2).map((appointment) => ({
      id: appointment.id,
      title: appointment.title,
      location: appointment.location,
      time: formatTimeLabel(new Date(appointment.startTime)),
      highlight: appointment.highlight,
      message: appointment.message,
      participants: appointment.participants.map((participant) => ({
        initials: participant.name.slice(0, 1),
        color: participant.color,
      })),
      extraLabel: appointment.extraLabel,
    }));
  }, []);

  const upcomingAppointments = useMemo(
    () => [
      {
        id: "hiking",
        title: "주말 등산",
        location: "북한산 등산로",
        badgeLabel: "내일",
      },
      {
        id: "birthday",
        title: "생일 파티",
        location: null,
        badgeLabel: "9월19일",
      },
    ],
    []
  );

  return (
    <SafeAreaView
      edges={["left", "right", "bottom"]}
      style={contentStyles.safeArea}
    >
      <ScrollView
        contentContainerStyle={contentStyles.scrollContent}
        showsVerticalScrollIndicator={false}
      >
        <StartAppointmentCard />

        <View style={contentStyles.sectionHeader}>
          <Text style={contentStyles.sectionTitle}>🔥 오늘의 약속</Text>
        </View>
        <View style={contentStyles.cardStack}>
          {todayAppointments.map((appointment, index) => (
            <View
              key={appointment.id}
              style={
                index !== todayAppointments.length - 1
                  ? contentStyles.cardSpacing
                  : undefined
              }
            >
              <TodayAppointmentCard
                title={appointment.title}
                location={appointment.location}
                time={appointment.time}
                highlight={appointment.highlight}
                message={appointment.message}
                participants={appointment.participants}
                extraLabel={appointment.extraLabel}
                onPress={() =>
                  navigation.navigate("AppointmentDetail", {
                    appointmentId: appointment.id,
                  })
                }
              />
            </View>
          ))}
        </View>

        <View style={contentStyles.sectionHeader}>
          <Text style={contentStyles.sectionTitle}>다가오는 약속</Text>
          <Text style={contentStyles.sectionAction}>전체보기</Text>
        </View>
        <View style={contentStyles.cardStack}>
          {upcomingAppointments.map((appointment, index) => (
            <View
              key={appointment.id}
              style={
                index !== upcomingAppointments.length - 1
                  ? contentStyles.cardSpacing
                  : undefined
              }
            >
              <UpcomingAppointmentCard
                title={appointment.title}
                location={appointment.location}
                badgeLabel={appointment.badgeLabel}
                onPress={() =>
                  navigation.navigate("AppointmentDetail", {
                    appointmentId: appointment.id,
                  })
                }
              />
            </View>
          ))}
        </View>
      </ScrollView>
      <StatusBar style="dark" />
    </SafeAreaView>
  );
}

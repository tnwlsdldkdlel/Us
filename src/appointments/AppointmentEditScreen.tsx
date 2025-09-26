import type { ReactElement } from "react";
import { useMemo, useState } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import {
  Keyboard,
  KeyboardAvoidingView,
  Pressable,
  Platform,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  TouchableWithoutFeedback,
  View,
} from "react-native";
import {
  SafeAreaView,
  useSafeAreaInsets,
} from "react-native-safe-area-context";
import { appointmentEditStyles } from "./editStyles";
import { getAppointmentById } from "../data/appointments";
import { useNavigation, useRoute } from "@react-navigation/native";
import type { NavigationProp, RouteProp } from "@react-navigation/native";
import type { RootStackParamList } from "../navigation/types";
import { spacing } from "../styles/theme";

const formatDate = (date: Date): string =>
  new Intl.DateTimeFormat("ko-KR", {
    year: "numeric",
    month: "numeric",
    day: "numeric",
  }).format(date);

const formatTime = (date: Date): string =>
  new Intl.DateTimeFormat("ko-KR", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  }).format(date);

type AppointmentEditRoute = RouteProp<RootStackParamList, "AppointmentEdit">;

type ClearIconProps = {
  accessibilityLabel: string;
  onPress: () => void;
};

function ClearIcon({
  accessibilityLabel,
  onPress,
}: ClearIconProps): ReactElement {
  return (
    <Pressable
      onPress={onPress}
      hitSlop={8}
      style={appointmentEditStyles.clearIcon}
      accessibilityRole="button"
      accessibilityLabel={accessibilityLabel}
    >
      <MaterialIcons name="close" size={24} color="#6B7280" />
    </Pressable>
  );
}

export default function AppointmentEditScreen(): ReactElement {
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const route = useRoute<AppointmentEditRoute>();
  const insets = useSafeAreaInsets();

  const appointment = useMemo(() => {
    return getAppointmentById(route.params.appointmentId);
  }, [route.params.appointmentId]);

  const [title, setTitle] = useState(appointment?.title ?? "");
  const [location, setLocation] = useState(appointment?.location ?? "");

  const startDate = appointment ? new Date(appointment.startTime) : new Date();

  const scrollContainerStyle = useMemo(() => {
    return [
      appointmentEditStyles.container,
      { paddingBottom: spacing.vertical * 6 + insets.bottom + 80 },
    ];
  }, [insets.bottom]);

  return (
    <SafeAreaView
      style={appointmentEditStyles.safeArea}
      edges={["top", "left", "right", "bottom"]}
    >
      <KeyboardAvoidingView
        style={appointmentEditStyles.keyboardAvoider}
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        keyboardVerticalOffset={8}
      >
        <TouchableWithoutFeedback onPress={Keyboard.dismiss} accessible={false}>
          <View style={appointmentEditStyles.contentWrapper}>
            <ScrollView
              contentContainerStyle={scrollContainerStyle}
              keyboardShouldPersistTaps="handled"
            >
              <View style={appointmentEditStyles.header}>
                <TouchableOpacity
                  style={appointmentEditStyles.headerButton}
                  onPress={() => navigation.goBack()}
                >
                  <MaterialIcons name="arrow-back" size={24} color="#111" />
                </TouchableOpacity>
              </View>

              <View style={appointmentEditStyles.card}>
                <View style={appointmentEditStyles.fieldGroup}>
                  <Text style={appointmentEditStyles.fieldLabel}>제목</Text>
                  <View style={appointmentEditStyles.textFieldRow}>
                    <TextInput
                      style={appointmentEditStyles.textField}
                      placeholder="제목"
                      value={title}
                      onChangeText={setTitle}
                    />
                    {title ? (
                      <ClearIcon
                        onPress={() => setTitle("")}
                        accessibilityLabel="제목 지우기"
                      />
                    ) : null}
                  </View>
                </View>

                <View style={appointmentEditStyles.fieldGroup}>
                  <Text style={appointmentEditStyles.fieldLabel}>장소</Text>
                  <View style={appointmentEditStyles.textFieldRow}>
                    <TextInput
                      style={appointmentEditStyles.textField}
                      placeholder="장소"
                      value={location}
                      onChangeText={setLocation}
                    />
                    {location ? (
                      <ClearIcon
                        onPress={() => setLocation("")}
                        accessibilityLabel="장소 지우기"
                      />
                    ) : null}
                  </View>
                </View>

                <View style={appointmentEditStyles.fieldGroup}>
                  <Text style={appointmentEditStyles.fieldLabel}>시작일</Text>
                  <View style={appointmentEditStyles.dateRow}>
                    <TouchableOpacity style={appointmentEditStyles.dateButton}>
                      <Text style={appointmentEditStyles.dateButtonLabel}>
                        {formatDate(startDate)}
                      </Text>
                    </TouchableOpacity>
                    <TouchableOpacity style={appointmentEditStyles.timeButton}>
                      <Text style={appointmentEditStyles.timeButtonLabel}>
                        {formatTime(startDate)}
                      </Text>
                    </TouchableOpacity>
                  </View>
                </View>

                <View style={appointmentEditStyles.fieldGroup}>
                  <View style={appointmentEditStyles.participantsRow}>
                    <Text
                      style={[
                        appointmentEditStyles.fieldLabel,
                        { marginBottom: 0 },
                      ]}
                    >
                      참여자
                    </Text>
                    <TouchableOpacity
                      style={appointmentEditStyles.addParticipantButton}
                      activeOpacity={0.85}
                    >
                      <Text style={appointmentEditStyles.addParticipantLabel}>
                        + 참여자 추가
                      </Text>
                    </TouchableOpacity>
                  </View>
                </View>
              </View>
            </ScrollView>
            <View
              pointerEvents="box-none"
              style={[appointmentEditStyles.floatingSubmitArea]}
            >
              <View style={appointmentEditStyles.floatingSubmitSurface}>
                <TouchableOpacity
                  style={appointmentEditStyles.submitButton}
                  activeOpacity={0.85}
                >
                  <Text style={appointmentEditStyles.submitLabel}>수정</Text>
                </TouchableOpacity>
              </View>
            </View>
          </View>
        </TouchableWithoutFeedback>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

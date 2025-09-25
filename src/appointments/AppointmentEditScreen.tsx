import type { ReactElement } from "react";
import { useEffect, useMemo, useRef, useState } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import {
  Keyboard,
  Pressable,
  Platform,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  type KeyboardEvent,
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
import { use } from "../../node_modules/@types/react/index.d";

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
  const baseSubmitSpacing = useMemo(() => insets.bottom + 16, [insets.bottom]);
  const [submitSpacing, setSubmitSpacing] = useState(baseSubmitSpacing);
  const keyboardSpacingRef = useRef(baseSubmitSpacing);

  useEffect(() => {
    setSubmitSpacing(baseSubmitSpacing);
    keyboardSpacingRef.current = baseSubmitSpacing;
  }, [baseSubmitSpacing]);

  useEffect(() => {
    const showEvent =
      Platform.OS === "ios" ? "keyboardWillShow" : "keyboardDidShow";
    const hideEvent =
      Platform.OS === "ios" ? "keyboardWillHide" : "keyboardDidHide";
    const frameEvent = "keyboardDidChangeFrame";

    const handleKeyboardHeight = (event: KeyboardEvent): void => {
      const height = event.endCoordinates?.height ?? 0;
      const target = Math.max(height - insets.bottom, 0) + 8;
      setSubmitSpacing(target);
      keyboardSpacingRef.current = target;
    };

    const handleHide = (): void => {
      setSubmitSpacing(baseSubmitSpacing);
      keyboardSpacingRef.current = baseSubmitSpacing;
    };

    const showSubscription = Keyboard.addListener(showEvent, handleKeyboardHeight);
    const hideSubscription = Keyboard.addListener(hideEvent, handleHide);
    const frameSubscription = Keyboard.addListener(frameEvent, handleKeyboardHeight);

    return () => {
      showSubscription.remove();
      hideSubscription.remove();
      frameSubscription.remove();
    };
  }, [baseSubmitSpacing, insets.bottom]);

  const handleInputFocus = (): void => {
    const metrics = Keyboard.metrics();
    if (metrics?.height != null) {
      const target = Math.max(metrics.height - insets.bottom, 0) + 8;
      setSubmitSpacing(target);
      keyboardSpacingRef.current = target;
      return;
    }

    const storedSpacing = keyboardSpacingRef.current;
    if (storedSpacing !== baseSubmitSpacing) {
      setSubmitSpacing(storedSpacing);
    }
  };

  return (
    <SafeAreaView
      style={appointmentEditStyles.safeArea}
      edges={["top", "left", "right", "bottom"]}
    >
      <View style={appointmentEditStyles.contentWrapper}>
        <ScrollView
          contentContainerStyle={appointmentEditStyles.container}
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
                  onFocus={handleInputFocus}
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
                  onFocus={handleInputFocus}
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
          style={[
            appointmentEditStyles.submitContainer,
            { paddingBottom: submitSpacing },
          ]}
        >
          <TouchableOpacity
            style={appointmentEditStyles.submitButton}
            activeOpacity={0.85}
          >
            <Text style={appointmentEditStyles.submitLabel}>수정</Text>
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}

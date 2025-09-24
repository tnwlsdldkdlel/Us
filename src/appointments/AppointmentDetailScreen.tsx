import type { ReactElement } from "react";
import { useMemo, useRef, useState } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import {
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { appointmentDetailStyles } from "./styles";
import {
  getAppointmentById,
  type Appointment,
  type Participant,
  type ParticipantStatus,
} from "../data/appointments";
import { useNavigation, useRoute } from "@react-navigation/native";
import type { NavigationProp, RouteProp } from "@react-navigation/native";
import type { RootStackParamList } from "../navigation/types";

const STATUS_LABEL_MAP: Record<ParticipantStatus, string> = {
  confirmed: "참여",
  pending: "대기",
  declined: "거절",
};

const STATUS_COLOR_MAP: Record<ParticipantStatus, string> = {
  confirmed: "#10B981",
  pending: "#E5E7EB",
  declined: "#FECACA",
};

const STATUS_TEXT_COLOR_MAP: Record<ParticipantStatus, string> = {
  confirmed: "#FFFFFF",
  pending: "#4B5563",
  declined: "#9B1C1C",
};

function formatKoreanDate(date: Date): string {
  return new Intl.DateTimeFormat("ko-KR", {
    year: "numeric",
    month: "long",
    day: "numeric",
    weekday: "long",
  }).format(date);
}

function formatTimeRange(start: Date, end: Date): string {
  const formatter = new Intl.DateTimeFormat("ko-KR", {
    hour: "numeric",
    minute: "2-digit",
    hour12: true,
  });
  return `${formatter.format(start)} - ${formatter.format(end)}`;
}

function formatHeaderLabel(date: Date): string {
  return new Intl.DateTimeFormat("ko-KR", {
    month: "long",
    day: "numeric",
    weekday: "long",
  }).format(date);
}

function getInitials(name: string): string {
  return name.slice(0, 1);
}

type AppointmentDetailRoute = RouteProp<
  RootStackParamList,
  "AppointmentDetail"
>;

type AppointmentDetailScreenProps = {
  appointment: Appointment;
};

function AppointmentContent({
  appointment,
}: AppointmentDetailScreenProps): ReactElement {
  const startDate = new Date(appointment.startTime);
  const endDate = new Date(appointment.endTime);

  return (
    <View style={appointmentDetailStyles.cardBody}>
      <Text style={appointmentDetailStyles.title}>{appointment.title}</Text>
      <Text style={appointmentDetailStyles.dateText}>
        {formatKoreanDate(startDate)}
      </Text>
      <Text style={appointmentDetailStyles.timeText}>
        {formatTimeRange(startDate, endDate)}
      </Text>
      <View style={appointmentDetailStyles.locationRow}>
        <MaterialIcons name="place" size={20} color="#64748B" />
        <Text style={appointmentDetailStyles.locationText}>
          {appointment.location}
        </Text>
      </View>
      <TouchableOpacity
        style={[
          appointmentDetailStyles.actionButton,
          { backgroundColor: "#10B981" },
        ]}
        activeOpacity={0.85}
      >
        <Text
          style={[appointmentDetailStyles.actionLabel, { color: "#FFFFFF" }]}
        >
          참여
        </Text>
      </TouchableOpacity>
      <TouchableOpacity
        style={[
          appointmentDetailStyles.actionButton,
          { backgroundColor: "#E5E7EB" },
        ]}
        activeOpacity={0.85}
      >
        <Text
          style={[appointmentDetailStyles.actionLabel, { color: "#4B5563" }]}
        >
          거절
        </Text>
      </TouchableOpacity>
      <View style={appointmentDetailStyles.participantsSection}>
        <Text style={appointmentDetailStyles.sectionTitle}>참여자</Text>
        {appointment.participants.map((participant) => (
          <ParticipantRow key={participant.id} participant={participant} />
        ))}
      </View>
      <View style={appointmentDetailStyles.commentsSection}>
        <Text style={appointmentDetailStyles.sectionTitle}>댓글</Text>
        {appointment.comments.length === 0 ? (
          <Text style={appointmentDetailStyles.commentMessage}>
            아직 댓글이 없어요.
          </Text>
        ) : (
          appointment.comments.map((comment) => (
            <CommentRow
              key={comment.id}
              participant={appointment.participants.find(
                (p) => p.id === comment.authorId
              )}
              message={comment.message}
              timestamp={comment.timestamp}
            />
          ))
        )}
      </View>
    </View>
  );
}

function ParticipantRow({
  participant,
}: {
  participant: Participant;
}): ReactElement {
  return (
    <View style={appointmentDetailStyles.participantRow}>
      <View style={appointmentDetailStyles.participantInfo}>
        <View
          style={[
            appointmentDetailStyles.avatar,
            { backgroundColor: participant.color },
          ]}
        >
          <Text style={appointmentDetailStyles.avatarLabel}>
            {getInitials(participant.name)}
          </Text>
        </View>
        <Text style={appointmentDetailStyles.participantName}>
          {participant.name}
        </Text>
      </View>
      <View
        style={[
          appointmentDetailStyles.statusChip,
          { backgroundColor: STATUS_COLOR_MAP[participant.status] },
        ]}
      >
        <Text
          style={[
            appointmentDetailStyles.statusLabel,
            { color: STATUS_TEXT_COLOR_MAP[participant.status] },
          ]}
        >
          {STATUS_LABEL_MAP[participant.status]}
        </Text>
      </View>
    </View>
  );
}

type CommentRowProps = {
  participant?: Participant;
  message: string;
  timestamp: string;
};

function CommentRow({
  participant,
  message,
  timestamp,
}: CommentRowProps): ReactElement {
  const date = new Date(timestamp);
  const now = new Date();
  const diffMs = now.getTime() - date.getTime();
  let timeLabel: string;
  if (diffMs >= 0 && diffMs < 1000 * 60 * 60 * 24) {
    const hours = Math.max(1, Math.floor(diffMs / (1000 * 60 * 60)));
    timeLabel = `${hours}시간 전`;
  } else {
    timeLabel = new Intl.DateTimeFormat("ko-KR", {
      month: "numeric",
      day: "numeric",
    }).format(date);
  }

  return (
    <View style={appointmentDetailStyles.commentRow}>
      <View
        style={[
          appointmentDetailStyles.avatar,
          { backgroundColor: participant?.color ?? "#CBD5F5" },
        ]}
      >
        <Text style={appointmentDetailStyles.avatarLabel}>
          {participant ? getInitials(participant.name) : "?"}
        </Text>
      </View>
      <View style={appointmentDetailStyles.commentContent}>
        <View style={appointmentDetailStyles.commentHeader}>
          <Text style={appointmentDetailStyles.commentAuthor}>
            {participant?.name ?? "알 수 없음"}
          </Text>
          <Text style={appointmentDetailStyles.commentMeta}>{timeLabel}</Text>
        </View>
        <Text style={appointmentDetailStyles.commentMessage}>{message}</Text>
      </View>
    </View>
  );
}

export default function AppointmentDetailScreen(): ReactElement {
  const navigation = useNavigation<NavigationProp<RootStackParamList>>();
  const route = useRoute<AppointmentDetailRoute>();
  const [commentText, setCommentText] = useState("");
  const inputRef = useRef<TextInput>(null);

  const appointment = useMemo(() => {
    return getAppointmentById(route.params.appointmentId);
  }, [route.params.appointmentId]);

  if (!appointment) {
    return (
      <SafeAreaView
        style={appointmentDetailStyles.safeArea}
        edges={["top", "left", "right", "bottom"]}
      >
        <View style={appointmentDetailStyles.container}>
          <View style={appointmentDetailStyles.header}>
            <TouchableOpacity
              style={appointmentDetailStyles.headerIconButton}
              onPress={() => navigation.goBack()}
            >
              <MaterialIcons name="arrow-back" size={24} color="#111" />
            </TouchableOpacity>
            <Text style={appointmentDetailStyles.headerTitle}>약속 상세</Text>
            <View style={appointmentDetailStyles.headerIconButton} />
          </View>
          <Text>약속 정보를 찾을 수 없습니다.</Text>
        </View>
      </SafeAreaView>
    );
  }

  const startDate = useMemo(
    () => new Date(appointment.startTime),
    [appointment.startTime]
  );
  const headerLabel = formatHeaderLabel(startDate);

  return (
    <SafeAreaView
      style={appointmentDetailStyles.safeArea}
      edges={["top", "left", "right", "bottom"]}
    >
      <KeyboardAvoidingView
        style={{ flex: 1 }}
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        keyboardVerticalOffset={Platform.OS === "ios" ? 80 : 0}
      >
        <ScrollView
          contentContainerStyle={appointmentDetailStyles.container}
          showsVerticalScrollIndicator={false}
        >
          <View style={appointmentDetailStyles.header}>
            <TouchableOpacity
              style={appointmentDetailStyles.headerIconButton}
              onPress={() => navigation.goBack()}
            >
              <MaterialIcons name="arrow-back" size={24} color="#111" />
            </TouchableOpacity>
            <Text style={appointmentDetailStyles.headerTitle}>
              {headerLabel}
            </Text>
            <TouchableOpacity style={appointmentDetailStyles.headerIconButton}>
              <MaterialIcons name="more-vert" size={22} color="#111" />
            </TouchableOpacity>
          </View>
          <View style={appointmentDetailStyles.card}>
            <AppointmentContent appointment={appointment} />
          </View>
        </ScrollView>
        <View style={appointmentDetailStyles.inputBarContainer}>
          <View style={appointmentDetailStyles.inputBar}>
            <TextInput
              ref={inputRef}
              style={appointmentDetailStyles.inputField}
              placeholder="댓글 남기기"
              placeholderTextColor="#9ca3afff"
              value={commentText}
              onChangeText={setCommentText}
              multiline
              returnKeyType="send"
            />
            <TouchableOpacity
              onPress={() => {
                // TODO: wire up submit handler
                setCommentText("");
              }}
              disabled={commentText.trim().length === 0}
            >
              <MaterialIcons
                name="send"
                size={20}
                color={commentText.trim().length === 0 ? "#9CA3AF" : "#111"}
              />
            </TouchableOpacity>
          </View>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

import { StyleSheet } from "react-native";
import { colors, spacing } from "../styles/theme";

export const appointmentDetailStyles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
    paddingTop: spacing.vertical,
    paddingBottom: spacing.vertical * 7,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 20,
    paddingHorizontal: 5,
  },
  headerIconButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
  },
  headerTitle: {
    flex: 1,
    textAlign: "center",
    fontSize: 18,
    fontWeight: "700",
    color: colors.primaryText,
  },
  card: {
    borderRadius: 18,
    backgroundColor: colors.background,
    paddingHorizontal: 0,
    paddingVertical: 0,
  },
  cardBody: {
    paddingHorizontal: spacing.horizontal,
  },
  title: {
    fontSize: 24,
    fontWeight: "700",
    color: colors.primaryText,
    marginBottom: 8,
  },
  dateText: {
    fontSize: 15,
    color: colors.secondaryText,
    marginBottom: 6,
  },
  timeText: {
    fontSize: 15,
    color: colors.secondaryText,
    marginBottom: 12,
  },
  locationRow: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 18,
  },
  locationText: {
    marginLeft: 6,
    fontSize: 15,
    color: colors.secondaryText,
  },
  actionButton: {
    borderRadius: 12,
    paddingVertical: 14,
    alignItems: "center",
    marginBottom: 10,
  },
  actionLabel: {
    fontSize: 16,
    fontWeight: "600",
  },
  participantsSection: {
    marginTop: 12,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    backgroundColor: colors.background,
    paddingHorizontal: spacing.horizontal,
    paddingVertical: 16,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: "600",
    color: colors.primaryText,
    marginBottom: 12,
  },
  participantRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginBottom: 12,
  },
  participantInfo: {
    flexDirection: "row",
    alignItems: "center",
  },
  avatar: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  avatarLabel: {
    color: colors.background,
    fontWeight: "700",
  },
  participantName: {
    fontSize: 15,
    color: colors.primaryText,
  },
  statusChip: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 999,
  },
  statusLabel: {
    fontSize: 13,
    fontWeight: "600",
  },
  commentsSection: {
    marginTop: 20,
    borderRadius: 16,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    backgroundColor: colors.background,
    paddingHorizontal: spacing.horizontal,
    paddingVertical: 16,
  },
  commentRow: {
    flexDirection: "row",
    marginBottom: 12,
  },
  commentContent: {
    marginLeft: 0,
    flex: 1,
  },
  commentHeader: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  commentAuthor: {
    fontSize: 14,
    fontWeight: "600",
    color: colors.primaryText,
  },
  commentMessage: {
    marginTop: 4,
    fontSize: 14,
    color: colors.secondaryText,
  },
  commentMeta: {
    fontSize: 12,
    color: colors.muted,
  },
  inputBarContainer: {
    paddingHorizontal: spacing.horizontal,
    paddingVertical: 8,
    backgroundColor: colors.background,
  },
  inputBar: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#F3F4F6",
    borderRadius: 16,
    paddingHorizontal: 16,
    paddingVertical: 12,
  },
  inputField: {
    flex: 1,
    fontSize: 15,
    color: colors.primaryText,
    marginRight: 12,
  },
});

import { StyleSheet } from "react-native";
import { colors, spacing } from "../styles/theme";

export const appointmentEditStyles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
    paddingHorizontal: spacing.horizontal,
    paddingTop: spacing.vertical,
    paddingBottom: spacing.vertical * 2,
  },
  contentWrapper: {
    flex: 1,
  },
  header: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 20,
  },
  headerButton: {
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
    marginRight: 36,
  },
  card: {
    flex: 1,
    borderRadius: 18,
    paddingTop: spacing.vertical,
  },
  fieldGroup: {
    marginBottom: 20,
  },
  fieldLabel: {
    fontSize: 14,
    color: colors.secondaryText,
    marginBottom: 8,
  },
  textFieldRow: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#F8F8F8",
    borderRadius: 12,
    height: 50,
    paddingHorizontal: 8,
    paddingVertical: 0,
  },
  textField: {
    flex: 1,
    fontSize: 15,
    color: colors.primaryText,
  },
  clearIcon: {
    marginLeft: 12,
    padding: 4,
  },
  dateRow: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 12,
    gap: 12,
  },
  dateButton: {
    flex: 1,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#10B981",
    paddingVertical: 12,
    alignItems: "center",
  },
  dateButtonLabel: {
    color: "#10B981",
    fontSize: 15,
    fontWeight: "600",
  },
  timeButton: {
    flex: 1,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#E2E8F0",
    paddingVertical: 12,
    alignItems: "center",
  },
  timeButtonLabel: {
    fontSize: 15,
    color: colors.secondaryText,
    fontWeight: "500",
  },
  participantsRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginTop: 12,
    paddingRight: 4,
  },
  addParticipantButton: {
    borderRadius: 16,
    backgroundColor: "#E5E7EB",
    paddingHorizontal: 20,
    paddingVertical: 10,
  },
  addParticipantLabel: {
    color: "#6B7280",
    fontSize: 13,
    fontWeight: "500",
  },
  submitContainer: {
    paddingHorizontal: spacing.horizontal,
    paddingTop: spacing.vertical * 2,
  },
  submitButton: {
    borderRadius: 16,
    backgroundColor: "#10B981",
    paddingVertical: 14,
    alignItems: "center",
  },
  submitLabel: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
});

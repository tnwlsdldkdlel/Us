import { StyleSheet } from "react-native";
import { colors, spacing } from "../styles/theme";

export const calendarStyles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  scrollContent: {
    paddingHorizontal: spacing.horizontal,
    paddingTop: spacing.vertical,
    paddingBottom: spacing.vertical * 3,
  },
  agendaSection: {
    marginTop: 20,
    gap: 12,
  },
  emptyState: {
    borderRadius: 16,
    backgroundColor: "#F8FAFC",
    paddingVertical: 24,
    alignItems: "center",
  },
  emptyStateText: {
    fontSize: 14,
    color: colors.secondaryText,
  },
});

export const calendarViewStyles = StyleSheet.create({
  container: {
    borderRadius: 18,
    backgroundColor: colors.background,
    paddingVertical: 16,
    paddingHorizontal: 20,
    shadowColor: "#000000",
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.05,
    shadowRadius: 12,
    elevation: 2,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 16,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: colors.primaryText,
  },
  weekdayRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 12,
  },
  weekdayLabel: {
    flex: 1,
    textAlign: "center",
    fontSize: 13,
    color: colors.secondaryText,
  },
  grid: {
    gap: 12,
  },
  weekRow: {
    flexDirection: "row",
    justifyContent: "space-between",
  },
  dayCell: {
    flex: 1,
    aspectRatio: 1,
    alignItems: "center",
    justifyContent: "center",
    borderRadius: 999,
  },
  dayText: {
    fontSize: 15,
    color: colors.primaryText,
  },
  mutedDayText: {
    color: colors.muted,
  },
  selectedCell: {
    backgroundColor: "#10B981",
  },
  selectedText: {
    color: colors.background,
    fontWeight: "700",
  },
  todayOutlineText: {
    color: "#10B981",
    fontWeight: "700",
  },
  indicator: {
    width: 4,
    height: 4,
    borderRadius: 2,
    backgroundColor: colors.background,
    marginTop: 4,
  },
});

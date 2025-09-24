import { StyleSheet } from "react-native";
import { colors, spacing } from "../styles/theme";

export const contentStyles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
    paddingHorizontal: spacing.horizontal,
    paddingTop: spacing.vertical,
    backgroundColor: colors.background,
  },
  scrollContent: {
    paddingHorizontal: spacing.horizontal,
    paddingTop: spacing.vertical,
    paddingBottom: spacing.vertical * 3,
  },
  sectionHeader: {
    marginTop: spacing.vertical * 2,
    marginBottom: 12,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "700",
    color: colors.primaryText,
  },
  sectionAction: {
    fontSize: 13,
    fontWeight: "600",
    color: colors.accent,
  },
  cardStack: {
    width: "100%",
  },
  cardSpacing: {
    marginBottom: 12,
  },
  screenHeading: {
    fontSize: 24,
    fontWeight: "600",
    color: colors.primaryText,
    marginBottom: 8,
  },
  screenBody: {
    fontSize: 16,
    color: colors.secondaryText,
  },
});

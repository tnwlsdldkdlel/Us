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
  sectionHeading: {
    fontSize: 18,
    fontWeight: "600",
    color: colors.primaryText,
    marginTop: spacing.vertical * 2,
    marginBottom: 12,
  },
  heading: {
    fontSize: 24,
    fontWeight: "600",
    color: colors.primaryText,
    marginBottom: 8,
  },
  body: {
    fontSize: 16,
    color: colors.secondaryText,
  },
});

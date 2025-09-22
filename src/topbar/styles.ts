import { StyleSheet } from "react-native";
import { colors, spacing } from "../styles/theme";

export const headerStyles = StyleSheet.create({
  safeArea: {
    backgroundColor: colors.background,
  },
  container: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: spacing.horizontal,
    paddingVertical: spacing.vertical,
    borderBottomWidth: StyleSheet.hairlineWidth,
    borderBottomColor: colors.border,
    backgroundColor: colors.background,
    height: 56,
    shadowRadius: 6,
    elevation: 4,
  },
  sideSpacer: {
    width: 24,
  },
  title: {
    flex: 1,
    textAlign: "center",
    fontSize: 30,
    fontWeight: "bold",
    color: colors.accent,
  },
  icon: {
    color: colors.primaryText,
  },
});

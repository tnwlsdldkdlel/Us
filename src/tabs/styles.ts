import { StyleSheet } from "react-native";
import { colors } from "../styles/theme";

export const tabStyles = StyleSheet.create({
  safeArea: {
    backgroundColor: colors.background,
  },
  tabBar: {
    backgroundColor: colors.background,
    borderTopWidth: 1,
    height: 56,
    paddingBottom: 16,
    paddingTop: 16,
    shadowRadius: 6,
    elevation: 0,
  },
});

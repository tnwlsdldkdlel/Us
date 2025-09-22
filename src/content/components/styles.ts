import { StyleSheet } from "react-native";
import { colors } from "../../styles/theme";

export const cardStyles = StyleSheet.create({
  container: {
    height: 140,
    padding: 16,
    borderRadius: 16,
    justifyContent: "space-between",
  },
  titleContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  title: {
    fontSize: 20,
    fontWeight: "700",
    color: "#FFFFFF",
    marginBottom: 4,
  },
  subtitle: {
    fontSize: 14,
    color: "#F8FAFC",
  },
  button: {
    backgroundColor: "rgba(255, 255, 255, 0.2)",
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 8,
    opacity: 1,
    alignSelf: "flex-start",
    borderWidth: 1,
    borderColor: "rgba(255, 255, 255, 0.2)",
  },
  buttonLabel: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "600",
  },
});

export const todayCardStyles = StyleSheet.create({
  container: {
    height: 114,
    borderRadius: 8,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    padding: 17,
    backgroundColor: colors.background,
    flexDirection: "row",
    alignItems: "stretch",
  },
  accent: {
    width: 8,
    height: "100%",
    borderRadius: 4,
    backgroundColor: "#10B981",
  },
  content: {
    flex: 1,
    marginLeft: 12,
    justifyContent: "space-between",
  },
  titleRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  title: {
    fontSize: 16,
    fontWeight: "600",
    color: colors.primaryText,
  },
  timeContainer: {
    backgroundColor: colors.accent,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 50,
  },
  timeText: {
    fontSize: 16,
    color: colors.background,
  },
  locationRow: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 6,
  },
  locationText: {
    marginLeft: 4,
    fontSize: 14,
    color: colors.secondaryText,
  },
  message: {
    marginTop: 12,
    fontSize: 14,
    color: colors.secondaryText,
  },
});

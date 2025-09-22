import type { ReactElement } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import { Text, View } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { headerStyles } from "./styles";

export default function AppHeader(): ReactElement {
  return (
    <SafeAreaView edges={["top"]} style={headerStyles.safeArea}>
      <View style={headerStyles.container}>
        <View style={headerStyles.sideSpacer} />
        <Text style={headerStyles.title}>Us</Text>
        <MaterialIcons
          name="notifications-none"
          size={24}
          style={headerStyles.icon}
        />
      </View>
    </SafeAreaView>
  );
}

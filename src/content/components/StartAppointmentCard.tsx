import type { ReactElement } from "react";
import { LinearGradient } from "expo-linear-gradient";
import { Pressable, Text, View } from "react-native";
import { cardStyles } from "./styles";
import { MaterialIcons } from "@expo/vector-icons";

type StartAppointmentCardProps = {
  onCreatePress?: () => void;
};

export default function StartAppointmentCard({
  onCreatePress,
}: StartAppointmentCardProps): ReactElement {
  return (
    <LinearGradient
      colors={["#10B981", "#34D399"]}
      start={{ x: 0, y: 0 }}
      end={{ x: 1, y: 1 }}
      style={cardStyles.container}
    >
      <View>
        <View style={cardStyles.titleContainer}>
          <Text style={cardStyles.title}>새로운 약속 시작하기</Text>
          <MaterialIcons name="add" color={"white"} size={30}></MaterialIcons>
        </View>
        <Text style={cardStyles.subtitle}>
          친구와 시간을 정하고 간편하게 초대하세요.
        </Text>
      </View>
      <Pressable
        accessibilityRole="button"
        onPress={onCreatePress}
        style={cardStyles.button}
      >
        <Text style={cardStyles.buttonLabel}>약속 만들기</Text>
      </Pressable>
    </LinearGradient>
  );
}

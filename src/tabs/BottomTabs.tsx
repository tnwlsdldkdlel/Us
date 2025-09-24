import type { ReactElement } from "react";
import { MaterialIcons } from "@expo/vector-icons";
import {
  BottomTabBar,
  createBottomTabNavigator,
} from "@react-navigation/bottom-tabs";
import type { BottomTabBarProps } from "@react-navigation/bottom-tabs";
import type { RouteProp } from "@react-navigation/native";
import { SafeAreaView } from "react-native-safe-area-context";
import { colors } from "../styles/theme";
import { tabStyles } from "./styles";
import AppHeader from "../topbar/AppHeader";
import HomeScreen from "../content/HomeScreen";
import PlaceholderScreen from "../content/PlaceholderScreen";
import CalendarScreen from "../calendar/CalendarScreen";
import type { TabParamList } from "../navigation/types";

const Tab = createBottomTabNavigator<TabParamList>();

const ICON_MAP: Record<keyof TabParamList, string> = {
  Home: "home",
  Calendar: "calendar-month",
  Add: "add-comment",
  Users: "group",
  Profile: "account-circle",
};

function SafeAreaTabBar(props: BottomTabBarProps): ReactElement {
  return (
    <SafeAreaView edges={["bottom"]} style={tabStyles.safeArea}>
      <BottomTabBar {...props} />
    </SafeAreaView>
  );
}

const renderPlaceholder = (title: string) => (): ReactElement =>
  <PlaceholderScreen title={title} />;

export default function BottomTabs(): ReactElement {
  return (
    <Tab.Navigator
      tabBar={(props) => <SafeAreaTabBar {...props} />}
      screenOptions={({
        route,
      }: {
        route: RouteProp<TabParamList, keyof TabParamList>;
      }) => ({
        headerShown: route.name === "Home",
        header: route.name === "Home" ? () => <AppHeader /> : undefined,
        tabBarShowLabel: false,
        tabBarActiveTintColor: colors.accent,
        tabBarInactiveTintColor: colors.muted,
        tabBarStyle: tabStyles.tabBar,
        tabBarIcon: ({ color }) => (
          <MaterialIcons name={ICON_MAP[route.name]} size={30} color={color} />
        ),
      })}
    >
      <Tab.Screen name="Home" component={HomeScreen} />
      <Tab.Screen
        name="Calendar"
        component={CalendarScreen}
        options={{ headerShown: false }}
      />
      <Tab.Screen
        name="Add"
        children={renderPlaceholder("추가")}
        options={{ headerShown: false }}
      />
      <Tab.Screen
        name="Users"
        children={renderPlaceholder("유저")}
        options={{ headerShown: false }}
      />
      <Tab.Screen
        name="Profile"
        children={renderPlaceholder("프로필")}
        options={{ headerShown: false }}
      />
    </Tab.Navigator>
  );
}

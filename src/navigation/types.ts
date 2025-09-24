import type { Appointment } from "../data/appointments";

export type RootStackParamList = {
  MainTabs: undefined;
  AppointmentDetail: { appointmentId: Appointment["id"] };
};

export type TabParamList = {
  Home: undefined;
  Calendar: undefined;
  Add: undefined;
  Users: undefined;
  Profile: undefined;
};

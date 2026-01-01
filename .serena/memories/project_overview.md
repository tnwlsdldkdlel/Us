# Us Project Overview
- **Purpose**: Flutter 3.x appointment planner that syncs with Supabase backend for authentication and profile data.
- **Entry points**: `lib/main.dart` initializes Supabase then boots `UsApp`; `lib/app.dart` wires localization, theme, and routes via `AuthGate`.
- **Architecture**: Feature-first layout under `lib/` with directories for app shell (`app/`), configuration (`config/`), data repositories (`data/`), domain models (`models/`), screen-specific UI (`screens/`), shared services (`services/`), and widgets (`widgets/`).
- **Auth flow**: `lib/app/auth_gate.dart` subscribes to Supabase auth state, ensures user profile via `AuthRepository`, and routes to `LoginScreen` or `HomeScreen`.
- **Key integrations**: `supabase_flutter` for auth/database, `http` for API calls, `flutter_localizations` for multi-language support.
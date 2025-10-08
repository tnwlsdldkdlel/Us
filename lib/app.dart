import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home/screens/home_screen.dart';
import 'theme/app_theme.dart';

class UsApp extends StatelessWidget {
  const UsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'), // Add other supported locales here
      ],
      title: 'Us',
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      home: HomeScreen(),
    );
  }
}

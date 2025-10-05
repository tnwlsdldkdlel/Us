import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screens/home/screens/home_screen.dart';
import 'theme/us_colors.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: UsColors.primary),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        fontFamily: 'SpoqaHanSansNeo',
      ),
      home: HomeScreen(),
    );
  }
}

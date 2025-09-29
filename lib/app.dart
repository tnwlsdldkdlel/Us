import 'package:flutter/material.dart';

import 'screens/home/home_screen.dart';
import 'theme/us_colors.dart';

class UsApp extends StatelessWidget {
  const UsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Us',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: UsColors.primary),
        scaffoldBackgroundColor: const Color(0xFFF6F7F9),
        fontFamily: 'SpoqaHanSansNeo',
      ),
      home: const HomeScreen(),
    );
  }
}

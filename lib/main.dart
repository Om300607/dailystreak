import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

void main() {
  runApp(const DailyStreakApp());
}

class DailyStreakApp extends StatelessWidget {
  const DailyStreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DailyStreak',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background1,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.amber,
          brightness: Brightness.dark,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              bodyColor: AppColors.textPrimary,
              displayColor: AppColors.textPrimary,
            ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surfaceElevated,
          textStyle: const TextStyle(color: AppColors.textPrimary),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.surfaceElevated,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

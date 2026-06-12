import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:study_tracker/app/navigation/bottomNav.dart';
import 'package:study_tracker/shared/provider/theme_provider.dart';

class StudyTrackerApp extends ConsumerWidget {
  const StudyTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
        title: 'Study Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: _lightTheme(),
        darkTheme: _darkTheme(),
        home: BottomNav());
  }

  ThemeData _lightTheme() {
    const primary = Color(0xFF5C6BC0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF5F5F5),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }

  ThemeData _darkTheme() {
    const primary = Color.fromARGB(255, 110, 140, 201);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121212),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dailyhistor/src/routing/app_router.dart';
import 'package:dailyhistor/src/routing/app_startup.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);
    return MaterialApp.router(
      routerConfig: goRouter,
      builder: (_, child) {
        return AppStartupWidget(
          onLoaded: (_) => child!,
        );
      },
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2), // Soft blue as primary
          secondary: const Color(0xFFF5A623), // Muted orange as secondary
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light gray background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50), // Dark gray for headlines
          ),
          titleMedium: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF34495E), // Slightly lighter gray for titles
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Color(0xFF2C3E50), // Dark gray for body text
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF34495E), // Slightly lighter gray for secondary text
          ),
        ),
      ),
    );
  }
}

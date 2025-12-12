import 'package:flutter/material.dart';
import 'package:myapp/history_screen.dart';
import 'package:myapp/home_screen.dart';
import 'package:myapp/settings_screen.dart';
import 'package:myapp/theme.dart';
import 'package:provider/provider.dart';
import 'package:myapp/water_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WaterProvider(),
      child: MaterialApp(
        title: 'Hydration Tracker',
        theme: AppTheme.lightTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/history': (context) => const HistoryScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}

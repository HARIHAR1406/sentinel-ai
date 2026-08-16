import 'package:flutter/material.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const SentinelAiApp());
}

class SentinelAiApp extends StatelessWidget {
  const SentinelAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sentinel AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

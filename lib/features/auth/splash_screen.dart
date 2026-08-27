import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/home'); // GoRouter redirect handles unauthenticated users -> /login
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightCanvas, // Always dark for splash
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 80, color: AppColors.sentinelBlue),
            const SizedBox(height: 24),
            Text(
              'SENTINEL AI',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(color: AppColors.textPrimaryLight),
            ),
          ],
        ),
      ),
    );
  }
}

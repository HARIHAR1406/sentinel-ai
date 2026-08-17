import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class EmergencySupportScreen extends StatelessWidget {
  const EmergencySupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Support'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.riskCriticalDark.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.riskCriticalDark, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.emergency_share_rounded, color: AppColors.riskCriticalDark, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Are you in immediate danger?',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you require immediate assistance, contact local authorities immediately.',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Trigger emergency call logic
                  },
                  icon: const Icon(Icons.call, size: 28),
                  label: const Text('CALL LOCAL AUTHORITIES (911)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.riskCriticalDark,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppColors.riskCriticalDark.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 64,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Trigger trusted contacts alert
                  },
                  icon: const Icon(Icons.group_rounded, size: 28),
                  label: const Text('ALERT TRUSTED CONTACTS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    foregroundColor: AppColors.riskCriticalDark,
                    side: const BorderSide(color: AppColors.riskCriticalDark, width: 2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Sentinel AI cannot guarantee rapid response from local authorities. Always take necessary steps to ensure your immediate physical safety.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Help'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.sentinelBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.shield, size: 48, color: AppColors.sentinelBlue),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Sentinel AI',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0 (Build 42)',
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Text(
              'Documentation',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  _buildListTile(context, Icons.help_outline, 'Help Center'),
                  const Divider(height: 1),
                  _buildListTile(context, Icons.article_outlined, 'Terms of Service'),
                  const Divider(height: 1),
                  _buildListTile(context, Icons.privacy_tip_outlined, 'Privacy Policy'),
                  const Divider(height: 1),
                  _buildListTile(context, Icons.gavel_outlined, 'Community Guidelines'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.riskHighDark),
                  foregroundColor: AppColors.riskHighDark,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Delete Account', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 48),
            Center(
              child: Text(
                '© 2026 Sentinel AI. All rights reserved.',
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Handle navigation or external link
      },
    );
  }
}

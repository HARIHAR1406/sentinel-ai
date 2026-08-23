import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/database_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // User Header
            Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.sentinelBlue,
                  child: Text('JD', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John Doe', style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24)),
                      const SizedBox(height: 4),
                      Text('john.doe@example.com', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Profile Options
            _buildSectionHeader(context, 'Safety & Trust'),
            _buildListTile(context, Icons.shield_outlined, 'My Incident Reports', () => context.push('/incident_tracking')),
            _buildListTile(context, Icons.people_outline, 'Trusted Contacts', () => context.push('/trusted_contacts')),
            _buildListTile(context, Icons.location_on_outlined, 'Saved Locations', () => context.push('/saved_locations')),
            
            userProfileAsync.when(
              data: (user) {
                if (user?.role == 'admin') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildSectionHeader(context, 'Administration'),
                      _buildListTile(context, Icons.admin_panel_settings, 'Incident Moderation', () => context.push('/incident_verification')),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
            ),
            
            const SizedBox(height: 24),
            _buildSectionHeader(context, 'Preferences'),
            _buildListTile(context, Icons.settings_outlined, 'Settings', () => context.push('/settings')),
            _buildListTile(context, Icons.help_outline, 'Help & Support', () => context.push('/about')),
            
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.logout, color: AppColors.riskHighDark),
              label: const Text('Sign Out', style: TextStyle(color: AppColors.riskHighDark)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.riskHighDark),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
            const SizedBox(height: 80), // Padding for FAB
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, left: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildListTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.sentinelBlue),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

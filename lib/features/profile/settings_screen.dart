import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/sentinel_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: SentinelButton(label: 'System', isGhost: true, onPressed: (){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme persistence pending state management implementation.')));
                })),
                const SizedBox(width: 8),
                Expanded(child: SentinelButton(label: 'Light', isGhost: true, onPressed: (){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme persistence pending state management implementation.')));
                })),
                const SizedBox(width: 8),
                Expanded(child: SentinelButton(label: 'Dark', onPressed: (){
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme persistence pending state management implementation.')));
                })),
              ],
            ),
            const SizedBox(height: 32),
            Text('Notifications & Alerts', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(title: const Text('Critical Safety Alerts'), value: true, onChanged: null),
            SwitchListTile(title: const Text('Route Risk Changes'), value: true, onChanged: (v){}),
            SwitchListTile(title: const Text('Nearby Incidents'), value: true, onChanged: (v){}),
            
            const SizedBox(height: 32),
            Text('Privacy', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(title: const Text('Share Anonymized Data'), value: true, onChanged: (v){}),
            
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Account deletion requires re-authentication.')),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.riskHighDark),
                foregroundColor: AppColors.riskHighDark,
              ),
              child: const Text('Delete Account'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/sentinel_button.dart';
import '../../data/services/background_geofence_service.dart';
import '../../core/theme/theme_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isBackgroundMonitoringEnabled = false;

  Future<void> _toggleBackgroundMonitoring(bool value) async {
    if (value) {
      // Request permissions
      var locationStatus = await Permission.locationAlways.status;
      if (!locationStatus.isGranted) {
        // Request foreground first if needed, though locationAlways normally handles it
        // on newer Android versions you must request locationWhenInUse first.
        await Permission.locationWhenInUse.request();
        locationStatus = await Permission.locationAlways.request();
      }

      var notificationStatus = await Permission.notification.status;
      if (!notificationStatus.isGranted) {
        notificationStatus = await Permission.notification.request();
      }

      if (locationStatus.isGranted && notificationStatus.isGranted) {
        await BackgroundGeofenceService.registerGeofencingTask();
        setState(() {
          _isBackgroundMonitoringEnabled = true;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Background monitoring activated.')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permissions required for background monitoring.')),
          );
        }
      }
    } else {
      // Cancel task
      await BackgroundGeofenceService.cancelGeofencingTask();
      setState(() {
        _isBackgroundMonitoringEnabled = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Background monitoring deactivated.')),
        );
      }
    }
  }

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
                Expanded(child: SentinelButton(label: 'System', isGhost: ref.watch(themeProvider) != ThemeMode.system, onPressed: (){
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.system);
                })),
                const SizedBox(width: 8),
                Expanded(child: SentinelButton(label: 'Light', isGhost: ref.watch(themeProvider) != ThemeMode.light, onPressed: (){
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.light);
                })),
                const SizedBox(width: 8),
                Expanded(child: SentinelButton(label: 'Dark', isGhost: ref.watch(themeProvider) != ThemeMode.dark, onPressed: (){
                  ref.read(themeProvider.notifier).setTheme(ThemeMode.dark);
                })),
              ],
            ),
            const SizedBox(height: 32),
            Text('Notifications & Alerts', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(title: const Text('Critical Safety Alerts'), value: true, onChanged: null),
            SwitchListTile(title: const Text('Route Risk Changes'), value: true, onChanged: (v){}),
            SwitchListTile(title: const Text('Nearby Incidents'), value: true, onChanged: (v){}),
            
            const SizedBox(height: 32),
            Text('Safety Tracking', style: Theme.of(context).textTheme.titleLarge),
            SwitchListTile(
              title: const Text('Background Safety Monitoring'),
              subtitle: const Text('Receive alerts for high-risk zones even when the app is closed.'),
              value: _isBackgroundMonitoringEnabled,
              onChanged: _toggleBackgroundMonitoring,
            ),

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

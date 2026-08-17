import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class TripSafetyModeScreen extends StatefulWidget {
  const TripSafetyModeScreen({super.key});

  @override
  State<TripSafetyModeScreen> createState() => _TripSafetyModeScreenState();
}

class _TripSafetyModeScreenState extends State<TripSafetyModeScreen> {
  bool _isModeActive = false;
  bool _shareLocation = true;
  bool _autoAlert = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Safety Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _isModeActive ? AppColors.sentinelBlue.withValues(alpha: 0.1) : theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isModeActive ? AppColors.sentinelBlue : theme.dividerColor, 
                  width: 2
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    _isModeActive ? Icons.shield_rounded : Icons.shield_outlined, 
                    color: _isModeActive ? AppColors.sentinelBlue : theme.colorScheme.secondary, 
                    size: 48
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isModeActive ? 'Active Monitoring ON' : 'Safety Mode is OFF',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _isModeActive ? AppColors.sentinelBlue : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'When active, Sentinel AI monitors your route and will alert trusted contacts if you fail to arrive by your designated ETA.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _isModeActive = !_isModeActive;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isModeActive ? AppColors.riskHighDark : AppColors.sentinelBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        _isModeActive ? 'STOP MONITORING' : 'START TRIP', 
                        style: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Trip Settings',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: const Text('Estimated Arrival Time (ETA)'),
                    subtitle: const Text('Set when you expect to arrive safely.'),
                    trailing: const Text('Not Set', style: TextStyle(color: AppColors.sentinelBlue, fontWeight: FontWeight.bold)),
                    onTap: () {
                      // Show time picker
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.location_on_outlined),
                    title: const Text('Share Live Location'),
                    subtitle: const Text('Broadcast location to Trusted Contacts.'),
                    value: _shareLocation,
                    activeThumbColor: AppColors.sentinelBlue,
                    onChanged: (val) => setState(() => _shareLocation = val),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: const Text('Auto-Alert on Delay'),
                    subtitle: const Text('Alert contacts if ETA is exceeded by 15 mins.'),
                    value: _autoAlert,
                    activeThumbColor: AppColors.sentinelBlue,
                    onChanged: (val) => setState(() => _autoAlert = val),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

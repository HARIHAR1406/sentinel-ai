import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import '../../shared/widgets/sentinel_empty_state.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  // Temporary mock data for UI validation
  static final List<Map<String, dynamic>> _mockAlerts = [
    {
      'title': 'High Risk Area Ahead',
      'description': 'You are approaching Marina Road, which currently has a High Risk classification due to recent reports.',
      'time': 'Just now',
      'level': RiskLevel.high,
    },
    {
      'title': 'Trip Safety Alert',
      'description': 'Mark Reynolds has arrived safely at their destination.',
      'time': '2 hours ago',
      'level': RiskLevel.low,
    },
    {
      'title': 'New Incident Reported',
      'description': 'Suspicious activity reported 400m from your current location.',
      'time': 'Yesterday',
      'level': RiskLevel.medium,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Alerts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: _mockAlerts.isNotEmpty ? _buildAlertsList(context) : _buildEmptyState(),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _mockAlerts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final alert = _mockAlerts[index];
        return _buildAlertCard(
          context: context,
          title: alert['title'] as String,
          description: alert['description'] as String,
          time: alert['time'] as String,
          level: alert['level'] as RiskLevel,
        );
      },
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required String title,
    required String description,
    required String time,
    required RiskLevel level,
  }) {
    Color indicatorColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (level) {
      case RiskLevel.low: indicatorColor = isDark ? AppColors.riskLowDark : AppColors.riskLowLight; break;
      case RiskLevel.medium: indicatorColor = isDark ? AppColors.riskMediumDark : AppColors.riskMediumLight; break;
      case RiskLevel.high: indicatorColor = isDark ? AppColors.riskHighDark : AppColors.riskHighLight; break;
      case RiskLevel.critical: indicatorColor = isDark ? AppColors.riskCriticalDark : AppColors.riskCriticalLight; break;
    }

    return Card(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                        Text(time, style: Theme.of(context).textTheme.labelLarge),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SentinelEmptyState(
      icon: Icons.notifications_off_outlined,
      title: 'No Active Alerts',
      description: 'You have no safety alerts at this time. Stay safe!',
    );
  }
}

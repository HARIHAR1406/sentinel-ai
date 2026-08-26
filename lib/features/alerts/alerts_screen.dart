import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/risk_chip.dart';
import '../../shared/widgets/sentinel_empty_state.dart';
import '../../data/services/safety_alerts_provider.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(safetyAlertsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Alerts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (alerts.isNotEmpty)
            TextButton(
              onPressed: () {
                // Clear all alerts logic could go here, or handled individually
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: SafeArea(
        child: alerts.isNotEmpty ? _buildAlertsList(context, ref, alerts) : _buildEmptyState(),
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, WidgetRef ref, List alerts) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final alert = alerts[index];
        return _buildAlertCard(
          context: context,
          ref: ref,
          id: alert.id,
          title: alert.title,
          description: alert.description,
          timestamp: alert.timestamp,
          level: alert.level,
          isRead: alert.isRead,
        );
      },
    );
  }

  Widget _buildAlertCard({
    required BuildContext context,
    required WidgetRef ref,
    required String id,
    required String title,
    required String description,
    required DateTime timestamp,
    required RiskLevel level,
    required bool isRead,
  }) {
    Color indicatorColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (level) {
      case RiskLevel.low: indicatorColor = isDark ? AppColors.riskLowDark : AppColors.riskLowLight; break;
      case RiskLevel.medium: indicatorColor = isDark ? AppColors.riskMediumDark : AppColors.riskMediumLight; break;
      case RiskLevel.high: indicatorColor = isDark ? AppColors.riskHighDark : AppColors.riskHighLight; break;
      case RiskLevel.critical: indicatorColor = isDark ? AppColors.riskCriticalDark : AppColors.riskCriticalLight; break;
    }

    final timeString = DateFormat('hh:mm a').format(timestamp);

    return Dismissible(
      key: Key(id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(safetyAlertsProvider.notifier).dismissAlert(id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: Theme.of(context).colorScheme.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            ref.read(safetyAlertsProvider.notifier).markAsRead(id);
          }
          // Potentially open MapScreen or incident details here
        },
        child: Card(
          elevation: isRead ? 0 : 2,
          color: isRead ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
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
                            Expanded(
                              child: Text(
                                title, 
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  color: isRead ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7) : indicatorColor,
                                )
                              )
                            ),
                            Text(
                              timeString, 
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Theme.of(context).colorScheme.secondary
                              )
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description, 
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isRead ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7) : null,
                          )
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const SentinelEmptyState(
      icon: Icons.safety_check_outlined,
      title: 'No Active Safety Alerts',
      description: 'There are currently no significant verified incidents detected in your immediate vicinity. Always remain aware of your surroundings.',
    );
  }
}

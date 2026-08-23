import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/services/firestore_notification_service.dart';
import '../../data/models/notification_model.dart';

class NotificationCenterScreen extends ConsumerWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text('No notifications yet.'),
            );
          }

          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final dateFormat = DateFormat('MMM dd, hh:mm a');

              IconData icon;
              Color iconColor;

              switch (notification.priority) {
                case NotificationPriority.critical:
                case NotificationPriority.high:
                  icon = Icons.warning_rounded;
                  iconColor = Colors.red;
                  break;
                case NotificationPriority.medium:
                  icon = Icons.info_outline;
                  iconColor = Colors.orange;
                  break;
                case NotificationPriority.low:
                  icon = Icons.notifications_none;
                  iconColor = Colors.blue;
                  break;
              }

              return ListTile(
                tileColor: notification.read ? null : theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                leading: CircleAvatar(
                  backgroundColor: iconColor.withValues(alpha: 0.1),
                  child: Icon(icon, color: iconColor),
                ),
                title: Text(
                  notification.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(notification.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(notification.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
                isThreeLine: true,
                onTap: () async {
                  if (!notification.read) {
                    await ref.read(notificationServiceProvider).markAsRead(notification.id);
                  }
                  
                  if (notification.incidentId != null && context.mounted) {
                    // Navigate to the incident detail via ID if we have it
                    // The simplest way without fetching the whole model is just a specific route 
                    // or handling the fetch on the detail screen. 
                    // However, we are passing the model via extra usually. 
                    // To handle this properly, the app should have a way to fetch an incident by ID.
                    // For Phase 7.9, we can just show a snackbar or implement a fetcher.
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incident detail fetching not fully implemented in Notifications yet.')),
                    );
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

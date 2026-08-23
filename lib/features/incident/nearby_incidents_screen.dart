import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/risk_chip.dart';
import '../../data/services/database_service.dart';
import '../../data/models/incident_model.dart';

class NearbyIncidentsScreen extends ConsumerWidget {
  const NearbyIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final incidentsStream = ref.watch(nearbyIncidentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Incidents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: incidentsStream.when(
          data: (incidents) {
            if (incidents.isEmpty) {
              return const Center(
                child: Text('No incidents found in your area.'),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: incidents.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final incident = incidents[index];
                
                // Format relative time simply for this phase
                final diff = DateTime.now().difference(incident.timestamp);
                String timeStr;
                if (diff.inMinutes < 60) {
                  timeStr = '\${diff.inMinutes} mins ago';
                } else if (diff.inHours < 24) {
                  timeStr = '\${diff.inHours} hours ago';
                } else {
                  timeStr = '\${diff.inDays} days ago';
                }

                // Map model enum to risk chip level
                RiskLevel riskLevel;
                switch (incident.severity) {
                  case IncidentSeverity.critical:
                    riskLevel = RiskLevel.high;
                    break;
                  case IncidentSeverity.high:
                    riskLevel = RiskLevel.high;
                    break;
                  case IncidentSeverity.medium:
                    riskLevel = RiskLevel.medium;
                    break;
                  case IncidentSeverity.low:
                    riskLevel = RiskLevel.low;
                    break;
                }

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (incident.verificationStatus == VerificationStatus.verified) {
                        context.push('/incident_detail', extra: incident);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unverified incidents cannot be viewed in detail.')),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  incident.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              RiskChip(level: riskLevel),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.secondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '\${incident.latitude.toStringAsFixed(4)}, \${incident.longitude.toStringAsFixed(4)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.access_time_outlined, size: 16, color: theme.colorScheme.secondary),
                              const SizedBox(width: 4),
                              Text(
                                timeStr,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(
            child: Text('Error loading incidents: $err', style: TextStyle(color: theme.colorScheme.error)),
          ),
        ),
      ),
    );
  }
}

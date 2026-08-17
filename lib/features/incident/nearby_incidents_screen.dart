import 'package:flutter/material.dart';

import '../../shared/widgets/risk_chip.dart';
import 'package:go_router/go_router.dart';

class NearbyIncidentsScreen extends StatelessWidget {
  const NearbyIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Dummy Data for UI validation
    final incidents = [
      {
        'title': 'Suspicious Activity',
        'location': '4th Ave & Main St (0.2 mi)',
        'time': '10 mins ago',
        'risk': RiskLevel.low,
      },
      {
        'title': 'Road Closure',
        'location': 'Highway 9 Southbound (1.1 mi)',
        'time': '45 mins ago',
        'risk': RiskLevel.medium,
      },
      {
        'title': 'Severe Altercation',
        'location': 'Downtown Plaza (1.5 mi)',
        'time': '1 hour ago',
        'risk': RiskLevel.high,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Incidents'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: incidents.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final incident = incidents[index];
            return Card(
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
                            incident['title'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        RiskChip(level: incident['risk'] as RiskLevel),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 16, color: theme.colorScheme.secondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            incident['location'] as String,
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
                          incident['time'] as String,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

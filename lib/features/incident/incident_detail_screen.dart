import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/models/incident_model.dart';
import '../../shared/widgets/risk_chip.dart';

class IncidentDetailScreen extends ConsumerWidget {
  final IncidentModel incident;

  const IncidentDetailScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Safety check: ensure only verified incidents are shown
    if (incident.verificationStatus != VerificationStatus.verified) {
      return Scaffold(
        appBar: AppBar(title: const Text('Incident Details')),
        body: const Center(child: Text('This incident is not verified and cannot be displayed.')),
      );
    }

    RiskLevel riskLevel;
    switch (incident.severity) {
      case IncidentSeverity.critical:
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

    final dateFormat = DateFormat('MMM dd, yyyy • hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    incident.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RiskChip(level: riskLevel),
              ],
            ),
            const SizedBox(height: 8),
            
            // Verification Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Verified by Sentinel AI',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Information', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const Divider(),
                    _buildDetailRow(context, Icons.category, 'Type', incident.type),
                    if (incident.aiAnalysis != null)
                      _buildDetailRow(context, Icons.label, 'Subcategory', incident.aiAnalysis!.subCategory),
                    _buildDetailRow(context, Icons.access_time, 'Reported', dateFormat.format(incident.timestamp)),
                    _buildDetailRow(context, Icons.location_on, 'Location', '\${incident.latitude.toStringAsFixed(4)}, \${incident.longitude.toStringAsFixed(4)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Summary', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      incident.aiAnalysis?.summary ?? incident.description,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // AI Confidence (if available)
            if (incident.aiAnalysis != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Text('AI Intelligence', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 8),
                      Text('Confidence Score: \${(incident.aiAnalysis!.confidence * 100).toStringAsFixed(0)}%'),
                      const SizedBox(height: 4),
                      Text('Priority: \${incident.aiAnalysis!.priority.toUpperCase()}'),
                    ],
                  ),
                ),
              ),
              
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

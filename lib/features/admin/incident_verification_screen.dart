import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/incident_model.dart';
import '../../data/services/database_service.dart';

final pendingIncidentsProvider = StreamProvider.autoDispose<List<IncidentModel>>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return dbService.getPendingIncidentsStream();
});

class IncidentVerificationScreen extends ConsumerStatefulWidget {
  const IncidentVerificationScreen({super.key});

  @override
  ConsumerState<IncidentVerificationScreen> createState() => _IncidentVerificationScreenState();
}

class _IncidentVerificationScreenState extends ConsumerState<IncidentVerificationScreen> {
  Future<void> _verify(IncidentModel incident) async {
    final confirmed = await _confirmDialog('Verify Incident', 'Are you sure you want to verify this incident? It will become public.');
    if (confirmed == true) {
      try {
        await ref.read(databaseServiceProvider).verifyIncident(incident.id);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident verified')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: \$e')));
      }
    }
  }

  Future<void> _reject(IncidentModel incident) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Incident'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Reject')),
        ],
      ),
    );
    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        await ref.read(databaseServiceProvider).rejectIncident(incident.id, reasonController.text.trim());
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident rejected')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: \$e')));
      }
    }
  }

  Future<void> _markDuplicate(IncidentModel incident) async {
    final idController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Duplicate'),
        content: TextField(
          controller: idController,
          decoration: const InputDecoration(labelText: 'Original Incident ID (optional)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange), child: const Text('Mark Duplicate')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        final originalId = idController.text.trim().isEmpty ? 'unknown' : idController.text.trim();
        await ref.read(databaseServiceProvider).markIncidentDuplicate(incident.id, originalId);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incident marked as duplicate')));
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: \$e')));
      }
    }
  }

  Future<bool?> _confirmDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pendingAsync = ref.watch(pendingIncidentsProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Moderation'),
      ),
      body: pendingAsync.when(
        data: (incidents) {
          if (incidents.isEmpty) {
            return const Center(child: Text('No pending incidents to verify.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(incident.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Category: \${incident.type} | Severity: \${incident.severity.name}'),
                      Text('Description: \${incident.description}'),
                      Text('Reported: \${incident.timestamp.toLocal()}'),
                      if (incident.aiAnalysis != null) ...[
                        const Divider(),
                        const Text('AI Intelligence', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        Text('SubCategory: \${incident.aiAnalysis!.subCategory}'),
                        Text('Confidence: \${(incident.aiAnalysis!.confidence * 100).toStringAsFixed(1)}%'),
                        Text('Priority: \${incident.aiAnalysis!.priority}'),
                        Text('Risk Level: \${incident.aiAnalysis!.riskLevel}'),
                        Text('Summary: \${incident.aiAnalysis!.summary}'),
                        if (incident.aiAnalysis!.duplicateStatus != 'NOT_SIMILAR')
                           Text('Duplicate Warning: \${incident.aiAnalysis!.duplicateStatus}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _verify(incident),
                            child: const Text('VERIFY', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => _reject(incident),
                            child: const Text('REJECT', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            onPressed: () => _markDuplicate(incident),
                            child: const Text('DUPLICATE', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: \$err')),
      ),
    );
  }
}

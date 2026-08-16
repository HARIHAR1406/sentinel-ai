import 'package:flutter/material.dart';
import '../../shared/widgets/risk_chip.dart';

class GenericFeatureScreen extends StatelessWidget {
  final String title;
  const GenericFeatureScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Overview of $title', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Data Point 1'),
                subtitle: const Text('Verified by Sentinel AI'),
                trailing: const RiskChip(level: RiskLevel.low),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning_amber),
                title: const Text('Data Point 2'),
                subtitle: const Text('Requires Attention'),
                trailing: const RiskChip(level: RiskLevel.medium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';


class IncidentTrackingScreen extends StatelessWidget {
  const IncidentTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle, color: AppColors.successDark),
                title: const Text('Theft Report'),
                subtitle: const Text('Status: Verified • Yesterday'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.pending, color: AppColors.riskMediumDark),
                title: const Text('Suspicious Activity'),
                subtitle: const Text('Status: Under Review • 2 days ago'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}

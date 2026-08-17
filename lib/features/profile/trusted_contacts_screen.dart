import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TrustedContactsScreen extends StatelessWidget {
  const TrustedContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.person_add), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const Text('Manage contacts who receive your safety check-ins and emergency alerts.'),
            const SizedBox(height: 16),
            Card(
              child: SwitchListTile(
                secondary: const CircleAvatar(child: Text('MR')),
                title: const Text('Mark Reynolds'),
                subtitle: const Text('Family • Share Trip'),
                value: true,
                onChanged: (val) {},
                activeThumbColor: AppColors.sentinelBlue,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: SwitchListTile(
                secondary: const CircleAvatar(child: Text('SJ')),
                title: const Text('Sarah Jenkins'),
                subtitle: const Text('Friend • Emergency Contact'),
                value: false,
                onChanged: (val) {},
                activeThumbColor: AppColors.sentinelBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

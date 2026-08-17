import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class SavedLocationsScreen extends StatelessWidget {
  const SavedLocationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    
    final locations = [
      {'name': 'Home', 'address': '123 Residential Ave, Suburbia', 'icon': Icons.home_rounded},
      {'name': 'Work', 'address': 'Tech Plaza, Downtown', 'icon': Icons.work_rounded},
      {'name': 'Gym', 'address': 'Iron Fitness, 4th Street', 'icon': Icons.fitness_center_rounded},
      {'name': 'Kids School', 'address': 'Elementary St, Suburbia', 'icon': Icons.school_rounded},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Locations'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Add location action
            },
          )
        ],
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16.0),
          itemCount: locations.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final loc = locations[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.sentinelBlue.withValues(alpha: 0.1),
                  child: Icon(loc['icon'] as IconData, color: AppColors.sentinelBlue),
                ),
                title: Text(loc['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(loc['address'] as String),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {},
                ),
                onTap: () {
                  // Navigate to location on map
                  context.go('/map');
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

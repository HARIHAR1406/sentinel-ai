import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../shared/widgets/risk_chip.dart';
import '../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.sentinelBlue),
                            const SizedBox(width: 8),
                            Text('Connaught Place', style: Theme.of(context).textTheme.titleLarge),
                          ],
                        ),
                        const CircleAvatar(
                          backgroundColor: AppColors.sentinelBlue,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Safety Hero Card
                    GestureDetector(
                      onTap: () => context.push('/location_risk'),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Area Safety Profile', style: Theme.of(context).textTheme.titleMedium),
                              const SizedBox(height: 12),
                              const RiskChip(level: RiskLevel.medium),
                              const SizedBox(height: 12),
                              Text(
                                'Based on 7 verified incidents in the last 24 hours. Tap to view full risk analysis.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // AI Suggestion
                    GestureDetector(
                      onTap: () => context.push('/ai_safety_suggestions'),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(left: BorderSide(color: AppColors.aiHorizon, width: 4)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.smart_toy, color: AppColors.aiHorizon),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('AI-Assisted Analysis', 
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.aiHorizon)),
                                  const SizedBox(height: 4),
                                  Text('Consider avoiding Marina Road after 22:00. Tap for details.', 
                                    style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Nearby Incidents
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nearby Incidents', style: Theme.of(context).textTheme.titleLarge),
                        TextButton(
                          onPressed: () => context.push('/nearby_incidents'),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.warning, color: AppColors.riskHighDark),
                        title: const Text('Theft Reported'),
                        subtitle: const Text('200m away • 10 mins ago'),
                        trailing: const RiskChip(level: RiskLevel.high),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.info_outline, color: AppColors.riskMediumDark),
                        title: const Text('Suspicious Activity'),
                        subtitle: const Text('400m away • 1 hr ago'),
                        trailing: const RiskChip(level: RiskLevel.medium),
                      ),
                    ),
                    const SizedBox(height: 80), // Padding for FAB
                  ],
                ),
              ),
            );
          }
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          heroTag: 'emergency_home',
          onPressed: () => context.push('/emergency_support'),
          backgroundColor: AppColors.emergencyDark,
          child: const Icon(Icons.emergency, color: Colors.white),
        ),
      ),
    );
  }
}

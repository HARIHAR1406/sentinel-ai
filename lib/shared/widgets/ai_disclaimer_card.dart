import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AIDisclaimerCard extends StatelessWidget {
  const AIDisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                Text('AI recommendations are suggestions and are not verified facts.', 
                  style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

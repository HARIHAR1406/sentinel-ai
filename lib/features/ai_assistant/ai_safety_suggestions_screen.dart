import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/ai_disclaimer_card.dart';
import 'package:go_router/go_router.dart';

class AiSafetySuggestionsScreen extends StatelessWidget {
  const AiSafetySuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final suggestions = [
      {
        'title': 'Consider Route B',
        'desc': 'Current Route A has reported delays due to road closure. Route B is 4 mins longer but has no reported incidents.',
        'icon': Icons.alt_route_rounded
      },
      {
        'title': 'Avoid Downtown Plaza',
        'desc': 'Multiple user reports indicate a severe altercation in this area within the last hour.',
        'icon': Icons.gpp_bad_rounded
      },
      {
        'title': 'Enable Trip Safety Mode',
        'desc': 'You are entering an unfamiliar area at night. Consider sharing your live location with Trusted Contacts.',
        'icon': Icons.share_location_rounded
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Safety Suggestions'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const AIDisclaimerCard(),
            const SizedBox(height: 24),
            Text(
              'Contextual Insights',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ...suggestions.map((s) => _buildSuggestionCard(theme, s)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(ThemeData theme, Map<String, dynamic> suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: const BorderSide(color: AppColors.aiHorizon, width: 4),
          top: BorderSide(color: theme.dividerColor),
          right: BorderSide(color: theme.dividerColor),
          bottom: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(suggestion['icon'] as IconData, color: AppColors.aiHorizon, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    suggestion['desc'] as String,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

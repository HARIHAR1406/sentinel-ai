import 'package:flutter/material.dart';

class SentinelEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? ctaLabel;
  final VoidCallback? onCtaPressed;

  const SentinelEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.ctaLabel,
    this.onCtaPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          if (ctaLabel != null && onCtaPressed != null) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onCtaPressed,
              child: Text(ctaLabel!),
            ),
          ]
        ],
      ),
    );
  }
}

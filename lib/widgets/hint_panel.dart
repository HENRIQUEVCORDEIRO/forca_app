import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HintPanel extends StatelessWidget {
  const HintPanel({
    super.key,
    required this.hint,
    required this.isHintUsed,
    required this.enabled,
    required this.onRequestHint,
  });

  final String? hint;
  final bool isHintUsed;
  final bool enabled;
  final VoidCallback onRequestHint;

  @override
  Widget build(BuildContext context) {
    final String? currentHint = hint;
    final bool canRequest = enabled && !isHintUsed;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Align(
          alignment: Alignment.centerRight,
          child: IconButton.filled(
            onPressed: canRequest ? onRequestHint : null,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.onAccent,
              disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
              disabledForegroundColor: AppColors.onAccent.withValues(
                alpha: 0.6,
              ),
            ),
            tooltip: 'Dica',
            icon: const Icon(Icons.lightbulb_outline),
          ),
        ),
        if (currentHint != null) ...<Widget>[
          const SizedBox(height: 4),
          _HintCard(text: currentHint),
        ],
      ],
    );
  }
}

class _HintCard extends StatelessWidget {
  const _HintCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.accent)),
    );
  }
}

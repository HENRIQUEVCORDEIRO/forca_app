import 'package:flutter/material.dart';

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
        FilledButton.tonalIcon(
          onPressed: canRequest ? onRequestHint : null,
          icon: const Icon(Icons.lightbulb_outline),
          label: const Text('Dica'),
        ),
        if (currentHint != null) ...<Widget>[
          const SizedBox(height: 8),
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
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium
            ?.copyWith(color: colors.onSurface),
      ),
    );
  }
}

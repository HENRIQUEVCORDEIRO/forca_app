import 'package:flutter/material.dart';

class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    super.key,
    required this.letters,
    required this.usedLetters,
    required this.enabled,
    required this.onLetterSelected,
  });

  final List<String> letters;
  final Set<String> usedLetters;
  final bool enabled;
  final ValueChanged<String> onLetterSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final String letter in letters)
          _LetterButton(
            key: ValueKey<String>('letter-$letter'),
            letter: letter,
            isUsed: usedLetters.contains(letter),
            enabled: enabled,
            onPressed: () => onLetterSelected(letter),
          ),
      ],
    );
  }
}

class _LetterButton extends StatelessWidget {
  const _LetterButton({
    super.key,
    required this.letter,
    required this.isUsed,
    required this.enabled,
    required this.onPressed,
  });

  final String letter;
  final bool isUsed;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (isUsed) {
      return _UsedLetterChip(letter: letter);
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          letter,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _UsedLetterChip extends StatelessWidget {
  const _UsedLetterChip({required this.letter});

  final String letter;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: colors.outline,
          decoration: TextDecoration.lineThrough,
          decorationColor: colors.outline,
        ),
      ),
    );
  }
}

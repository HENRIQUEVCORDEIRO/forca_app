import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class LetterKeyboard extends StatelessWidget {
  const LetterKeyboard({
    super.key,
    required this.rows,
    required this.usedLetters,
    required this.enabled,
    required this.onLetterSelected,
  });

  static const List<List<String>> qwertyRows = <List<String>>[
    <String>['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
    <String>['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
    <String>['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
  ];

  final List<List<String>> rows;
  final Set<String> usedLetters;
  final bool enabled;
  final ValueChanged<String> onLetterSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (final List<String> row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: <Widget>[
                for (final String letter in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _LetterButton(
                        key: ValueKey<String>('letter-$letter'),
                        letter: letter,
                        isUsed: usedLetters.contains(letter),
                        enabled: enabled,
                        onPressed: () => onLetterSelected(letter),
                      ),
                    ),
                  ),
              ],
            ),
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
      height: 54,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 54),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: AppColors.keyboardButton,
          foregroundColor: AppColors.keyboardLetter,
          side: BorderSide.none,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          letter,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.keyboardLetter,
          ),
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
    return Container(
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.keyboardButton.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppColors.keyboardLetter.withValues(alpha: 0.6),
          decoration: TextDecoration.lineThrough,
          decorationColor: AppColors.keyboardLetter,
        ),
      ),
    );
  }
}

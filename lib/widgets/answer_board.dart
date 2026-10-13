import 'package:flutter/material.dart';

@immutable
class AnswerDisplayChar {
  const AnswerDisplayChar({required this.text, required this.isRevealed});

  final String text;
  final bool isRevealed;
}

class AnswerBoard extends StatelessWidget {
  const AnswerBoard({super.key, required this.words});

  final List<List<AnswerDisplayChar>> words;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 12,
      children: <Widget>[
        for (var wordIndex = 0; wordIndex < words.length; wordIndex++)
          _AnswerWord(wordIndex: wordIndex, characters: words[wordIndex]),
      ],
    );
  }
}

class _AnswerWord extends StatelessWidget {
  const _AnswerWord({required this.wordIndex, required this.characters});

  final int wordIndex;
  final List<AnswerDisplayChar> characters;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 8,
      children: <Widget>[
        for (var charIndex = 0; charIndex < characters.length; charIndex++)
          _AnswerLetterTile(
            key: ValueKey<String>('word-$wordIndex-char-$charIndex'),
            character: characters[charIndex],
          ),
      ],
    );
  }
}

class _AnswerLetterTile extends StatelessWidget {
  const _AnswerLetterTile({super.key, required this.character});

  final AnswerDisplayChar character;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: 30,
      height: 40,
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            character.isRevealed ? character.text : '_',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: character.isRevealed ? colors.onSurface : colors.outline,
            ),
          ),
        ),
      ),
    );
  }
}

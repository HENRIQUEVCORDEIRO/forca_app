import 'letter_normalizer.dart';

final _letterPattern = RegExp(r'^\p{L}$', unicode: true);

class AnswerCharacter {
  final String original;
  final bool isLetter;
  final String? baseLetter;

  factory AnswerCharacter(String original) {
    final letter = _letterPattern.hasMatch(original);
    return AnswerCharacter._(
      original: original,
      isLetter: letter,
      baseLetter: letter ? LetterNormalizer.normalize(original) : null,
    );
  }

  const AnswerCharacter._({
    required this.original,
    required this.isLetter,
    required this.baseLetter,
  });
}

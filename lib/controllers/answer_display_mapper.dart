import '../domain/hangman_entry.dart';
import '../widgets/answer_board.dart';

List<List<AnswerDisplayChar>> buildAnswerWords(
  HangmanEntry entry,
  Set<String> revealedLetters,
) {
  final words = <List<AnswerDisplayChar>>[];
  var current = <AnswerDisplayChar>[];

  for (final character in entry.characters) {
    if (character.original == ' ') {
      if (current.isNotEmpty) {
        words.add(current);
      }
      current = <AnswerDisplayChar>[];
      continue;
    }

    final revealed =
        !character.isLetter || revealedLetters.contains(character.baseLetter);
    current.add(
      AnswerDisplayChar(text: character.original, isRevealed: revealed),
    );
  }

  if (current.isNotEmpty) {
    words.add(current);
  }

  return words;
}

import '../data/entries_load_exception.dart';
import 'answer_category.dart';
import 'answer_character.dart';
import 'difficulty.dart';

class HangmanEntry {
  final String answer;
  final AnswerCategory category;
  final Difficulty difficulty;
  final List<String> hints;

  HangmanEntry({
    required this.answer,
    required this.category,
    required this.difficulty,
    required List<String> hints,
  }) : hints = List.unmodifiable(hints);

  factory HangmanEntry.fromJson(Map<String, dynamic> json) {
    final answer = _readAnswer(json);
    final category = AnswerCategory.fromJson(_readText(json, 'category'));
    final difficulty = Difficulty.fromJson(_readText(json, 'difficulty'));
    final hints = _readHints(json);

    return HangmanEntry(
      answer: answer,
      category: category,
      difficulty: difficulty,
      hints: hints,
    );
  }

  List<AnswerCharacter> get characters =>
      answer.split('').map(AnswerCharacter.new).toList(growable: false);

  Set<String> get requiredLetters {
    final letters = <String>{};
    for (final character in characters) {
      final base = character.baseLetter;
      if (base != null) {
        letters.add(base);
      }
    }
    return letters;
  }

  static String _readText(Map<String, dynamic> json, String field) {
    if (!json.containsKey(field)) {
      throw EntriesLoadException('Campo obrigatório ausente: "$field".');
    }
    final value = json[field];
    if (value is! String) {
      throw EntriesLoadException(
        'O campo "$field" deveria ser texto, mas recebeu '
        '${value.runtimeType}.',
      );
    }
    return value;
  }

  static String _readAnswer(Map<String, dynamic> json) {
    final answer = _readText(json, 'answer');

    if (answer.trim().isEmpty) {
      throw EntriesLoadException('A resposta está vazia.');
    }

    final hasLetter = answer
        .split('')
        .any((character) => AnswerCharacter(character).isLetter);
    if (!hasLetter) {
      throw EntriesLoadException(
        'A resposta "$answer" não contém nenhuma letra.',
      );
    }

    return answer;
  }

  static List<String> _readHints(Map<String, dynamic> json) {
    if (!json.containsKey('hints')) {
      throw EntriesLoadException('Campo obrigatório ausente: "hints".');
    }

    final value = json['hints'];
    if (value is! List) {
      throw EntriesLoadException(
        'O campo "hints" deveria ser uma lista, mas recebeu '
        '${value.runtimeType}.',
      );
    }
    if (value.isEmpty) {
      throw EntriesLoadException('A lista de dicas está vazia.');
    }

    final hints = <String>[];
    for (var i = 0; i < value.length; i++) {
      final hint = value[i];
      if (hint is! String) {
        throw EntriesLoadException(
          'A dica de índice $i não é texto: recebeu ${hint.runtimeType}.',
        );
      }
      if (hint.trim().isEmpty) {
        throw EntriesLoadException('A dica de índice $i está vazia.');
      }
      hints.add(hint);
    }

    return hints;
  }
}

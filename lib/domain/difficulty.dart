import '../data/entries_load_exception.dart';

enum Difficulty {
  easy('Fácil'),
  medium('Médio'),
  hard('Difícil');

  const Difficulty(this.label);

  final String label;

  static Difficulty fromJson(String value) {
    for (final difficulty in values) {
      if (difficulty.name == value) {
        return difficulty;
      }
    }
    throw EntriesLoadException(
      'Dificuldade inválida: "$value". Valores permitidos: '
      '${values.map((difficulty) => difficulty.name).join(', ')}.',
    );
  }
}

import '../data/entries_load_exception.dart';

enum AnswerCategory {
  animals('Animais'),
  humanBody('Corpo humano'),
  sports('Esportes'),
  technology('Tecnologia');

  const AnswerCategory(this.label);

  final String label;

  static AnswerCategory fromJson(String value) {
    for (final category in values) {
      if (category.name == value) {
        return category;
      }
    }
    throw EntriesLoadException(
      'Categoria inválida: "$value". Valores permitidos: '
      '${values.map((category) => category.name).join(', ')}.',
    );
  }
}

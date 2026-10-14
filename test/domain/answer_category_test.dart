import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/data/entries_load_exception.dart';
import 'package:hangman_game/domain/answer_category.dart';

void main() {
  group('AnswerCategory', () {
    test('expõe os valores técnicos na ordem da especificação', () {
      expect(AnswerCategory.values.map((category) => category.name), [
        'animals',
        'humanBody',
        'sports',
        'technology',
      ]);
    });

    test('expõe os rótulos em português', () {
      expect(AnswerCategory.values.map((category) => category.label), [
        'Animais',
        'Corpo humano',
        'Esportes',
        'Tecnologia',
      ]);
    });

    test('fromJson converte cada valor válido', () {
      expect(AnswerCategory.fromJson('animals'), AnswerCategory.animals);
      expect(AnswerCategory.fromJson('humanBody'), AnswerCategory.humanBody);
      expect(AnswerCategory.fromJson('sports'), AnswerCategory.sports);
      expect(AnswerCategory.fromJson('technology'), AnswerCategory.technology);
    });

    test('fromJson lança EntriesLoadException para valor desconhecido', () {
      expect(
        () => AnswerCategory.fromJson('games'),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('Categoria inválida'),
              contains('games'),
              contains('animals'),
            ),
          ),
        ),
      );
    });

    test('a mensagem de erro lista os valores permitidos', () {
      try {
        AnswerCategory.fromJson('games');
        fail('deveria ter lançado EntriesLoadException');
      } on EntriesLoadException catch (error) {
        for (final category in AnswerCategory.values) {
          expect(error.message, contains(category.name));
        }
      }
    });

    test('fromJson distingue maiúsculas de minúsculas', () {
      expect(
        () => AnswerCategory.fromJson('Animals'),
        throwsA(isA<EntriesLoadException>()),
      );
    });

    test('fromJson não aceita texto vazio', () {
      expect(
        () => AnswerCategory.fromJson(''),
        throwsA(isA<EntriesLoadException>()),
      );
    });
  });
}

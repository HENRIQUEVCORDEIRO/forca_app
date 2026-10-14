import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/data/entries_load_exception.dart';
import 'package:hangman_game/domain/difficulty.dart';

void main() {
  group('Difficulty', () {
    test('expõe os valores técnicos na ordem da especificação', () {
      expect(Difficulty.values.map((difficulty) => difficulty.name), [
        'easy',
        'medium',
        'hard',
      ]);
    });

    test('expõe os rótulos em português', () {
      expect(Difficulty.values.map((difficulty) => difficulty.label), [
        'Fácil',
        'Médio',
        'Difícil',
      ]);
    });

    test('fromJson converte cada valor válido', () {
      expect(Difficulty.fromJson('easy'), Difficulty.easy);
      expect(Difficulty.fromJson('medium'), Difficulty.medium);
      expect(Difficulty.fromJson('hard'), Difficulty.hard);
    });

    test('fromJson lança EntriesLoadException para valor desconhecido', () {
      expect(
        () => Difficulty.fromJson('impossible'),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('Dificuldade inválida'),
              contains('impossible'),
              contains('easy'),
            ),
          ),
        ),
      );
    });

    test('a mensagem de erro lista os valores permitidos', () {
      try {
        Difficulty.fromJson('impossible');
        fail('deveria ter lançado EntriesLoadException');
      } on EntriesLoadException catch (error) {
        for (final difficulty in Difficulty.values) {
          expect(error.message, contains(difficulty.name));
        }
      }
    });

    test('fromJson distingue maiúsculas de minúsculas', () {
      expect(
        () => Difficulty.fromJson('Easy'),
        throwsA(isA<EntriesLoadException>()),
      );
    });

    test('fromJson não aceita texto vazio', () {
      expect(
        () => Difficulty.fromJson(''),
        throwsA(isA<EntriesLoadException>()),
      );
    });
  });
}

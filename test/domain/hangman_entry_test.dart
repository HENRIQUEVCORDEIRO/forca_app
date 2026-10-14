import 'package:flutter_test/flutter_test.dart';
import 'package:forca_app/data/entries_load_exception.dart';
import 'package:forca_app/domain/answer_category.dart';
import 'package:forca_app/domain/difficulty.dart';
import 'package:forca_app/domain/hangman_entry.dart';

Map<String, dynamic> entryJson(
  String answer, {
  String category = 'animals',
  String difficulty = 'easy',
  List<String>? hints,
}) => {
  'answer': answer,
  'category': category,
  'difficulty': difficulty,
  'hints': hints ?? ['Uma pista qualquer.'],
};

void main() {
  group('HangmanEntry.fromJson', () {
    test('converte todos os campos', () {
      final entry = HangmanEntry.fromJson(
        entryJson(
          'CORAÇÃO',
          category: 'humanBody',
          difficulty: 'hard',
          hints: ['Primeira pista.', 'Segunda pista.'],
        ),
      );

      expect(entry.answer, 'CORAÇÃO');
      expect(entry.category, AnswerCategory.humanBody);
      expect(entry.difficulty, Difficulty.hard);
      expect(entry.hints, ['Primeira pista.', 'Segunda pista.']);
    });

    test('a lista de dicas é imutável', () {
      final entry = HangmanEntry.fromJson(entryJson('CORAÇÃO'));
      expect(() => entry.hints.add('outra'), throwsUnsupportedError);
    });
  });

  group('decomposição de respostas', () {
    test('CORAÇÃO decompõe Ç e Ã e mantém o original', () {
      final entry = HangmanEntry.fromJson(entryJson('CORAÇÃO'));

      expect(entry.characters, hasLength(7));
      expect(entry.characters.map((c) => c.original).join(), 'CORAÇÃO');
      expect(entry.answer, 'CORAÇÃO');
      expect(entry.requiredLetters, {'C', 'O', 'R', 'A'});

      expect(entry.characters[4].original, 'Ç');
      expect(entry.characters[4].baseLetter, 'C');
      expect(entry.characters[5].original, 'Ã');
      expect(entry.characters[5].baseLetter, 'A');
    });

    test('CÉREBRO decompõe o É acentuado', () {
      final entry = HangmanEntry.fromJson(entryJson('CÉREBRO'));

      expect(entry.characters, hasLength(7));
      expect(entry.characters.map((c) => c.original).join(), 'CÉREBRO');
      expect(entry.requiredLetters, {'C', 'E', 'R', 'B', 'O'});
      expect(entry.characters[1].original, 'É');
      expect(entry.characters[1].baseLetter, 'E');
    });

    test('COLUNA VERTEBRAL preserva o espaço na posição original', () {
      final entry = HangmanEntry.fromJson(entryJson('COLUNA VERTEBRAL'));

      expect(entry.characters, hasLength(16));
      expect(
        entry.characters.map((c) => c.original).join(),
        'COLUNA VERTEBRAL',
      );
      expect(entry.requiredLetters, {
        'A',
        'B',
        'C',
        'E',
        'L',
        'N',
        'O',
        'R',
        'T',
        'U',
        'V',
      });

      final space = entry.characters[6];
      expect(space.original, ' ');
      expect(space.isLetter, isFalse);
      expect(space.baseLetter, isNull);
      expect(entry.requiredLetters, isNot(contains(' ')));
    });

    test('QUATI SUL-AMERICANO preserva o hífen na posição original', () {
      final entry = HangmanEntry.fromJson(entryJson('QUATI SUL-AMERICANO'));

      expect(entry.characters, hasLength(19));
      expect(
        entry.characters.map((c) => c.original).join(),
        'QUATI SUL-AMERICANO',
      );
      expect(entry.requiredLetters, {
        'A',
        'C',
        'E',
        'I',
        'L',
        'M',
        'N',
        'O',
        'Q',
        'R',
        'S',
        'T',
        'U',
      });

      final hyphen = entry.characters[9];
      expect(hyphen.original, '-');
      expect(hyphen.isLetter, isFalse);
      expect(hyphen.baseLetter, isNull);
      expect(entry.requiredLetters, isNot(contains('-')));
    });

    test("apóstrofo é preservado e não vira letra", () {
      final entry = HangmanEntry.fromJson(entryJson("D'ÁGUA"));

      expect(entry.characters, hasLength(6));
      expect(entry.characters.map((c) => c.original).join(), "D'ÁGUA");
      expect(entry.requiredLetters, {'D', 'A', 'G', 'U'});

      final apostrophe = entry.characters[1];
      expect(apostrophe.original, "'");
      expect(apostrophe.isLetter, isFalse);
      expect(apostrophe.baseLetter, isNull);
    });

    test('letras repetidas entram uma única vez em requiredLetters', () {
      final entry = HangmanEntry.fromJson(entryJson('ARARA'));
      expect(entry.characters, hasLength(5));
      expect(entry.requiredLetters, {'A', 'R'});
    });
  });

  group('validações', () {
    void falha(Map<String, dynamic> json, String trecho) {
      expect(
        () => HangmanEntry.fromJson(json),
        throwsA(
          isA<EntriesLoadException>().having(
            (error) => error.message,
            'message',
            contains(trecho),
          ),
        ),
      );
    }

    test('campo obrigatório ausente', () {
      for (final field in ['answer', 'category', 'difficulty', 'hints']) {
        final json = entryJson('CORAÇÃO')..remove(field);
        expect(
          () => HangmanEntry.fromJson(json),
          throwsA(isA<EntriesLoadException>()),
          reason: 'campo "$field" ausente deveria falhar',
        );
      }
    });

    test('campo de texto com tipo errado', () {
      falha(entryJson('A')..['answer'] = 42, 'deveria ser texto');
      falha(entryJson('A')..['category'] = 7, 'deveria ser texto');
      falha(entryJson('A')..['difficulty'] = true, 'deveria ser texto');
    });

    test('resposta vazia ou apenas com espaços', () {
      falha(entryJson(''), 'A resposta está vazia.');
      falha(entryJson('   '), 'A resposta está vazia.');
    });

    test('resposta sem nenhuma letra', () {
      falha(entryJson('- - -'), 'não contém nenhuma letra');
      falha(entryJson('123'), 'não contém nenhuma letra');
    });

    test('categoria fora dos valores permitidos', () {
      falha(entryJson('A', category: 'games'), 'Categoria inválida');
    });

    test('dificuldade fora dos valores permitidos', () {
      falha(entryJson('A', difficulty: 'impossible'), 'Dificuldade inválida');
    });

    test('dicas com problema', () {
      falha(entryJson('A')..['hints'] = 'texto', 'deveria ser uma lista');
      falha(entryJson('A', hints: []), 'lista de dicas está vazia');
      falha(
        entryJson('A', hints: ['ok', '']),
        'A dica de índice 1 está vazia.',
      );
      falha(
        entryJson('A', hints: ['ok', '   ']),
        'A dica de índice 1 está vazia.',
      );
      final json = entryJson('A');
      json['hints'] = ['ok', 99];
      expect(
        () => HangmanEntry.fromJson(json),
        throwsA(isA<EntriesLoadException>()),
      );
    });

    test('fromJson não define o índice da entrada', () {
      try {
        HangmanEntry.fromJson(entryJson('A', category: 'games'));
        fail('deveria ter lançado EntriesLoadException');
      } on EntriesLoadException catch (error) {
        expect(error.entryIndex, isNull);
      }
    });
  });
}

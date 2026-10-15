import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/controllers/answer_display_mapper.dart';
import 'package:hangman_game/domain/answer_category.dart';
import 'package:hangman_game/domain/difficulty.dart';
import 'package:hangman_game/domain/hangman_entry.dart';
import 'package:hangman_game/widgets/answer_board.dart';

HangmanEntry _entry(String answer) => HangmanEntry(
  answer: answer,
  category: AnswerCategory.animals,
  difficulty: Difficulty.easy,
  hints: const <String>['pista'],
);

String _texts(List<List<AnswerDisplayChar>> words) => words
    .map((List<AnswerDisplayChar> w) => w.map((c) => c.text).join())
    .join(' | ');

String _rendered(List<List<AnswerDisplayChar>> words) => words
    .map(
      (List<AnswerDisplayChar> w) =>
          w.map((AnswerDisplayChar c) => c.isRevealed ? c.text : '_').join(),
    )
    .join(' | ');

void main() {
  group('estrutura das palavras', () {
    test('resposta de uma palavra só vira uma palavra', () {
      final words = buildAnswerWords(_entry('CORAÇÃO'), const <String>{});
      expect(words, hasLength(1));
      expect(_texts(words), 'CORAÇÃO');
    });

    test('resposta com espaço vira duas palavras', () {
      final words = buildAnswerWords(
        _entry('COLUNA VERTEBRAL'),
        const <String>{},
      );
      expect(words, hasLength(2));
      expect(_texts(words), 'COLUNA | VERTEBRAL');
      expect(words.first, hasLength(6));
      expect(words.last, hasLength(9));
    });

    test('hífen fica preso à palavra, sem virar separador', () {
      final words = buildAnswerWords(
        _entry('QUATI SUL-AMERICANO'),
        const <String>{},
      );
      expect(words, hasLength(2));
      expect(_texts(words), 'QUATI | SUL-AMERICANO');
      expect(words.last.first.text, 'S');
      expect(words.last[3].text, '-');
    });

    test('apóstrofo permanece na palavra', () {
      final words = buildAnswerWords(_entry("D'ÁGUA"), const <String>{});
      expect(words, hasLength(1));
      expect(words.single, hasLength(6));
      expect(words.single[1].text, "'");
    });
  });

  group('revelação', () {
    test('nada é revelado inicialmente', () {
      final words = buildAnswerWords(
        _entry('COLUNA VERTEBRAL'),
        const <String>{},
      );
      expect(_rendered(words), '______ | _________');
      expect(
        words
            .expand((List<AnswerDisplayChar> w) => w)
            .every((AnswerDisplayChar c) => !c.isRevealed),
        isTrue,
      );
    });

    test('letra acertada é revelada na posição original', () {
      final words = buildAnswerWords(_entry('CASA'), const <String>{'C', 'A'});
      expect(_rendered(words), 'CA_A');
    });

    test('letra acentuada acerta pela letra base', () {
      final words = buildAnswerWords(_entry('CORAÇÃO'), const <String>{'C'});
      expect(words.single[0].isRevealed, isTrue);
      expect(words.single[4].text, 'Ç');
      expect(words.single[4].isRevealed, isTrue);
    });

    test('caracteres estruturais ficam sempre visíveis', () {
      final words = buildAnswerWords(
        _entry('QUATI SUL-AMERICANO'),
        const <String>{},
      );
      final hyphen = words.last[3];
      expect(hyphen.text, '-');
      expect(hyphen.isRevealed, isTrue);

      final apostrophe = buildAnswerWords(_entry("D'ÁGUA"), const <String>{});
      expect(apostrophe.single[1].isRevealed, isTrue);
    });

    test('o texto original nunca é alterado', () {
      final words = buildAnswerWords(_entry('CORAÇÃO'), const <String>{});
      expect(_texts(words).replaceAll(' | ', ''), 'CORAÇÃO');
    });
  });
}

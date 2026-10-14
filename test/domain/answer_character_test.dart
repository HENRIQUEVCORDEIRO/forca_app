import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/domain/answer_character.dart';

void main() {
  group('AnswerCharacter', () {
    test('letra acentuada mantém o original e expoe a base', () {
      final character = AnswerCharacter('Ã');
      expect(character.original, 'Ã');
      expect(character.isLetter, isTrue);
      expect(character.baseLetter, 'A');
    });

    test('cedilha mantém o original e expoe a base', () {
      final character = AnswerCharacter('Ç');
      expect(character.original, 'Ç');
      expect(character.isLetter, isTrue);
      expect(character.baseLetter, 'C');
    });

    test('letra simples mantém o original e expoe a base', () {
      final character = AnswerCharacter('Q');
      expect(character.original, 'Q');
      expect(character.isLetter, isTrue);
      expect(character.baseLetter, 'Q');
    });

    test('espaço é caractere estrutural', () {
      final character = AnswerCharacter(' ');
      expect(character.original, ' ');
      expect(character.isLetter, isFalse);
      expect(character.baseLetter, isNull);
    });

    test('hífen é caractere estrutural', () {
      final character = AnswerCharacter('-');
      expect(character.original, '-');
      expect(character.isLetter, isFalse);
      expect(character.baseLetter, isNull);
    });

    test('apóstrofo é caractere estrutural', () {
      final character = AnswerCharacter("'");
      expect(character.original, "'");
      expect(character.isLetter, isFalse);
      expect(character.baseLetter, isNull);
    });

    test('pontuação e dígitos também são estruturais', () {
      for (final punctuation in ['.', ',', '!', '?', '1', '2', '@']) {
        final character = AnswerCharacter(punctuation);
        expect(character.isLetter, isFalse, reason: '"$punctuation"');
        expect(character.baseLetter, isNull, reason: '"$punctuation"');
        expect(character.original, punctuation);
      }
    });

    test('a normalização não reescreve o original', () {
      final character = AnswerCharacter('Ç');
      expect(character.original, isNot('C'));
      expect(character.original.length, 1);
      expect(character.baseLetter, 'C');
    });

    test('reconhece letra acentuada como letra', () {
      for (final letra in ['Á', 'É', 'Ê', 'Í', 'Ó', 'Ô', 'Ã', 'Ç']) {
        expect(AnswerCharacter(letra).isLetter, isTrue, reason: letra);
      }
    });
  });
}

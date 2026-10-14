import 'package:flutter_test/flutter_test.dart';
import 'package:forca_app/domain/letter_normalizer.dart';

void main() {
  group('LetterNormalizer', () {
    const baseLetters = <String, String>{
      'Á': 'A',
      'À': 'A',
      'Â': 'A',
      'Ã': 'A',
      'Ä': 'A',
      'É': 'E',
      'È': 'E',
      'Ê': 'E',
      'Ë': 'E',
      'Í': 'I',
      'Ì': 'I',
      'Î': 'I',
      'Ï': 'I',
      'Ó': 'O',
      'Ò': 'O',
      'Ô': 'O',
      'Õ': 'O',
      'Ö': 'O',
      'Ú': 'U',
      'Ù': 'U',
      'Û': 'U',
      'Ü': 'U',
      'Ç': 'C',
    };

    test('mapeia todas as letras acentuadas da especificação', () {
      baseLetters.forEach((acentuada, base) {
        expect(
          LetterNormalizer.normalize(acentuada),
          base,
          reason: 'normalize("$acentuada") deveria resultar em "$base"',
        );
      });
    });

    test('resolve as minúsculas acentuadas', () {
      expect(LetterNormalizer.normalize('à'), 'A');
      expect(LetterNormalizer.normalize('á'), 'A');
      expect(LetterNormalizer.normalize('â'), 'A');
      expect(LetterNormalizer.normalize('ã'), 'A');
      expect(LetterNormalizer.normalize('é'), 'E');
      expect(LetterNormalizer.normalize('ê'), 'E');
      expect(LetterNormalizer.normalize('í'), 'I');
      expect(LetterNormalizer.normalize('ó'), 'O');
      expect(LetterNormalizer.normalize('ô'), 'O');
      expect(LetterNormalizer.normalize('õ'), 'O');
      expect(LetterNormalizer.normalize('ú'), 'U');
      expect(LetterNormalizer.normalize('ç'), 'C');
    });

    test('converte letra sem acento para maiúscula', () {
      expect(LetterNormalizer.normalize('c'), 'C');
      expect(LetterNormalizer.normalize('z'), 'Z');
      expect(LetterNormalizer.normalize('Q'), 'Q');
    });

    test('devolve a própria letra para caracteres não acentuados', () {
      expect(LetterNormalizer.normalize('-'), '-');
      expect(LetterNormalizer.normalize(' '), ' ');
    });

    test('nunca altera a string recebida', () {
      const entrada = 'Ã';
      LetterNormalizer.normalize(entrada);
      expect(entrada, 'Ã');
    });
  });
}

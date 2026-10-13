import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/widgets/letter_keyboard.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  const List<String> letters = <String>['A', 'B', 'C'];

  testWidgets('exibe todas as letras disponíveis', (tester) async {
    await tester.pumpWidget(
      _host(
        LetterKeyboard(
          letters: letters,
          usedLetters: const <String>{},
          enabled: true,
          onLetterSelected: (_) {},
        ),
      ),
    );

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('dispara o callback ao tocar numa letra disponível', (
    tester,
  ) async {
    String? selected;
    await tester.pumpWidget(
      _host(
        LetterKeyboard(
          letters: letters,
          usedLetters: const <String>{},
          enabled: true,
          onLetterSelected: (String letter) => selected = letter,
        ),
      ),
    );

    await tester.tap(find.text('B'));

    expect(selected, 'B');
  });

  testWidgets('não dispara o callback para uma letra já usada', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _host(
        LetterKeyboard(
          letters: letters,
          usedLetters: const <String>{'A'},
          enabled: true,
          onLetterSelected: (String letter) => selected = letter,
        ),
      ),
    );

    await tester.tap(find.text('A'));

    expect(selected, isNull);
  });

  testWidgets('não dispara o callback quando desabilitado', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _host(
        LetterKeyboard(
          letters: letters,
          usedLetters: const <String>{},
          enabled: false,
          onLetterSelected: (String letter) => selected = letter,
        ),
      ),
    );

    await tester.tap(find.text('A'));

    expect(selected, isNull);
  });
}

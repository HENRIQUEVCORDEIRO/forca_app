import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/widgets/answer_board.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('esconde letras não reveladas com underline', (tester) async {
    await tester.pumpWidget(
      _host(
        const AnswerBoard(
          words: <List<AnswerDisplayChar>>[
            <AnswerDisplayChar>[
              AnswerDisplayChar(text: 'C', isRevealed: false),
              AnswerDisplayChar(text: 'A', isRevealed: false),
            ],
          ],
        ),
      ),
    );

    expect(find.text('_'), findsNWidgets(2));
    expect(find.text('C'), findsNothing);
    expect(find.text('A'), findsNothing);
  });

  testWidgets('revela letras preservando a grafia original', (tester) async {
    await tester.pumpWidget(
      _host(
        const AnswerBoard(
          words: <List<AnswerDisplayChar>>[
            <AnswerDisplayChar>[
              AnswerDisplayChar(text: 'Ç', isRevealed: true),
              AnswerDisplayChar(text: 'A', isRevealed: false),
            ],
          ],
        ),
      ),
    );

    expect(find.text('Ç'), findsOneWidget);
    expect(find.text('_'), findsOneWidget);
  });

  testWidgets('exibe caracteres estruturais desde o início', (tester) async {
    await tester.pumpWidget(
      _host(
        const AnswerBoard(
          words: <List<AnswerDisplayChar>>[
            <AnswerDisplayChar>[
              AnswerDisplayChar(text: 'S', isRevealed: false),
              AnswerDisplayChar(text: '-', isRevealed: true),
              AnswerDisplayChar(text: 'A', isRevealed: false),
            ],
          ],
        ),
      ),
    );

    expect(find.text('-'), findsOneWidget);
    expect(find.text('_'), findsNWidgets(2));
  });

  testWidgets('mantém as palavras separadas em grupos distintos', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const AnswerBoard(
          words: <List<AnswerDisplayChar>>[
            <AnswerDisplayChar>[AnswerDisplayChar(text: 'A', isRevealed: true)],
            <AnswerDisplayChar>[AnswerDisplayChar(text: 'B', isRevealed: true)],
          ],
        ),
      ),
    );

    expect(find.byType(Wrap), findsNWidgets(3));
  });

  testWidgets('quebra palavras longas sem overflow', (tester) async {
    final List<AnswerDisplayChar> longWord = List<AnswerDisplayChar>.generate(
      30,
      (int index) => const AnswerDisplayChar(text: 'A', isRevealed: true),
    );

    await tester.pumpWidget(
      _host(
        Center(
          child: SizedBox(
            width: 320,
            child: AnswerBoard(words: <List<AnswerDisplayChar>>[longWord]),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}

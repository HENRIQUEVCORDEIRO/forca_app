import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/screens/game_screen.dart';
import 'package:hangman_game/widgets/answer_board.dart';
import 'package:hangman_game/widgets/hangman_character.dart';

HangmanCharacterAssets _assets() => HangmanCharacterAssets(
  idleImages: <ImageProvider>[
    for (var stage = 0; stage <= 5; stage++) AssetImage('idle_$stage.png'),
  ],
  errorImages: <int, List<ImageProvider>>{
    1: <ImageProvider>[const AssetImage('e1.png')],
  },
);

Widget _app({
  int mistakes = 0,
  int maxMistakes = 5,
  CharacterStatus status = CharacterStatus.playing,
  List<List<AnswerDisplayChar>> words = const <List<AnswerDisplayChar>>[
    <AnswerDisplayChar>[
      AnswerDisplayChar(text: 'C', isRevealed: false),
      AnswerDisplayChar(text: 'A', isRevealed: false),
      AnswerDisplayChar(text: 'S', isRevealed: false),
      AnswerDisplayChar(text: 'A', isRevealed: false),
    ],
  ],
  Set<String> usedLetters = const <String>{},
  String? hint,
  bool isHintUsed = false,
  ValueChanged<String>? onLetterSelected,
  VoidCallback? onRequestHint,
  VoidCallback? onPlayAgain,
  VoidCallback? onExit,
}) {
  return MaterialApp(
    home: GameScreen(
      categoryLabel: 'Animais',
      difficultyLabel: 'Fácil',
      mistakes: mistakes,
      maxMistakes: maxMistakes,
      status: status,
      words: words,
      usedLetters: usedLetters,
      hint: hint,
      isHintUsed: isHintUsed,
      onLetterSelected: onLetterSelected ?? (_) {},
      onRequestHint: onRequestHint ?? () {},
      onPlayAgain: onPlayAgain ?? () {},
      onExit: onExit,
      characterAssets: _assets(),
    ),
  );
}

Finder _inBoard(Finder finder) =>
    find.descendant(of: find.byType(AnswerBoard), matching: finder);

void main() {
  testWidgets('mostra a palavra oculta com underlines', (tester) async {
    await tester.pumpWidget(_app());

    expect(_inBoard(find.text('_')), findsNWidgets(4));
  });

  testWidgets('revela apenas as letras descobertas', (tester) async {
    await tester.pumpWidget(
      _app(
        words: const <List<AnswerDisplayChar>>[
          <AnswerDisplayChar>[
            AnswerDisplayChar(text: 'A', isRevealed: true),
            AnswerDisplayChar(text: 'B', isRevealed: false),
          ],
        ],
      ),
    );

    expect(_inBoard(find.text('A')), findsOneWidget);
    expect(_inBoard(find.text('_')), findsOneWidget);
  });

  testWidgets('exibe o teclado QWERTY completo', (tester) async {
    await tester.pumpWidget(_app());

    const String letters = 'QWERTYUIOPASDFGHJKLZXCVBNM';
    for (final String letter in letters.split('')) {
      expect(find.text(letter), findsOneWidget);
    }
  });

  testWidgets('dispara o callback ao tocar numa letra nova', (tester) async {
    String? selected;
    await tester.pumpWidget(_app(onLetterSelected: (l) => selected = l));

    await tester.tap(find.text('Q'));

    expect(selected, 'Q');
  });

  testWidgets('não dispara o callback para letra já usada', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _app(
        usedLetters: const <String>{'Q'},
        onLetterSelected: (l) => selected = l,
      ),
    );

    await tester.tap(find.text('Q'));

    expect(selected, isNull);
  });

  testWidgets('não dispara o callback com o jogo encerrado', (tester) async {
    String? selected;
    await tester.pumpWidget(
      _app(status: CharacterStatus.won, onLetterSelected: (l) => selected = l),
    );

    await tester.tap(find.text('Q'), warnIfMissed: false);

    expect(selected, isNull);
  });

  testWidgets('solicita a dica pelo botão', (tester) async {
    int requested = 0;
    await tester.pumpWidget(_app(onRequestHint: () => requested++));

    await tester.tap(find.byIcon(Icons.lightbulb_outline));

    expect(requested, 1);
  });

  testWidgets('exibe a dica quando disponível', (tester) async {
    await tester.pumpWidget(_app(hint: 'Animal doméstico', isHintUsed: true));

    expect(find.text('Animal doméstico'), findsOneWidget);
  });

  testWidgets('mostra a vitória e permite jogar novamente', (tester) async {
    int played = 0;
    await tester.pumpWidget(
      _app(status: CharacterStatus.won, onPlayAgain: () => played++),
    );

    expect(find.text('Você venceu!'), findsOneWidget);

    await tester.tap(find.text('Jogar novamente'));

    expect(played, 1);
  });

  testWidgets('mostra a derrota', (tester) async {
    await tester.pumpWidget(_app(status: CharacterStatus.lost));

    expect(find.text('Você perdeu!'), findsOneWidget);
  });
}

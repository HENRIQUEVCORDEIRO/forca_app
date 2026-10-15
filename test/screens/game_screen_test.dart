import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/domain/answer_category.dart';
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
  ValueChanged<AnswerCategory>? onCategoryChanged,
  VoidCallback? onExit,
}) {
  return MaterialApp(
    home: GameScreen(
      categoryLabel: 'Animais',
      onCategoryChanged: onCategoryChanged ?? (_) {},
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

Future<void> _pump(WidgetTester tester, Widget app) async {
  tester.view.physicalSize = const Size(400, 820);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(app);
}

void main() {
  testWidgets('mostra a palavra oculta com underlines', (tester) async {
    await _pump(tester, _app());

    expect(_inBoard(find.text('_')), findsNWidgets(4));
  });

  testWidgets('revela apenas as letras descobertas', (tester) async {
    await _pump(
      tester,
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
    await _pump(tester, _app());

    const String letters = 'QWERTYUIOPASDFGHJKLZXCVBNM';
    for (final String letter in letters.split('')) {
      expect(find.text(letter), findsOneWidget);
    }
  });

  testWidgets('permite selecionar outra categoria no topbar', (tester) async {
    AnswerCategory? selectedCategory;
    await _pump(
      tester,
      _app(onCategoryChanged: (category) => selectedCategory = category),
    );

    await tester.tap(find.text('Animais'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tecnologia').last);

    expect(selectedCategory, AnswerCategory.technology);
  });

  testWidgets('dispara o callback ao tocar numa letra nova', (tester) async {
    String? selected;
    await _pump(tester, _app(onLetterSelected: (l) => selected = l));

    await tester.tap(find.text('Q'));

    expect(selected, 'Q');
  });

  testWidgets('não dispara o callback para letra já usada', (tester) async {
    String? selected;
    await _pump(
      tester,
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
    await _pump(
      tester,
      _app(status: CharacterStatus.won, onLetterSelected: (l) => selected = l),
    );

    await tester.tap(find.text('Q'), warnIfMissed: false);

    expect(selected, isNull);
  });

  testWidgets('solicita a dica pelo botão', (tester) async {
    int requested = 0;
    await _pump(tester, _app(onRequestHint: () => requested++));

    await tester.tap(find.byIcon(Icons.lightbulb_outline));

    expect(requested, 1);
  });

  testWidgets('exibe a dica quando disponível', (tester) async {
    await _pump(tester, _app(hint: 'Animal doméstico', isHintUsed: true));

    expect(find.text('Animal doméstico'), findsOneWidget);
  });

  testWidgets('mostra a vitória e permite jogar novamente', (tester) async {
    int played = 0;
    await _pump(
      tester,
      _app(status: CharacterStatus.won, onPlayAgain: () => played++),
    );

    expect(find.text('Você venceu!'), findsOneWidget);

    await tester.tapAt(tester.getCenter(find.byType(GameScreen)));

    expect(played, 1);
  });

  testWidgets('não reinicia ao tocar na tela durante o jogo', (tester) async {
    int played = 0;
    await _pump(tester, _app(onPlayAgain: () => played++));

    await tester.tapAt(tester.getCenter(find.byType(GameScreen)));

    expect(played, 0);
  });

  testWidgets('mostra a derrota', (tester) async {
    await _pump(tester, _app(status: CharacterStatus.lost));

    expect(find.text('Você perdeu!'), findsOneWidget);
  });
}

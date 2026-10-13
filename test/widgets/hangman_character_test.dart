import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangman_game/widgets/hangman_character.dart';

HangmanCharacterAssets _assets() => HangmanCharacterAssets(
  idleImages: <ImageProvider>[
    for (var stage = 0; stage <= 6; stage++) AssetImage('idle_$stage.png'),
  ],
  errorImages: <int, List<ImageProvider>>{
    1: <ImageProvider>[
      const AssetImage('e1_0.png'),
      const AssetImage('e1_1.png'),
      const AssetImage('e1_2.png'),
    ],
    6: <ImageProvider>[
      const AssetImage('e6_0.png'),
      const AssetImage('e6_1.png'),
    ],
  },
  victoryImages: <ImageProvider>[
    const AssetImage('win_0.png'),
    const AssetImage('win_1.png'),
  ],
  defeatImages: <ImageProvider>[const AssetImage('lose_0.png')],
);

String _currentImage(WidgetTester tester) {
  final Image image = tester.widget<Image>(find.byType(Image));
  return (image.image as AssetImage).assetName;
}

Future<void> _pump(
  WidgetTester tester, {
  required int mistakes,
  required CharacterStatus status,
}) {
  return tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: HangmanCharacter(
          assets: _assets(),
          mistakes: mistakes,
          maxMistakes: 6,
          status: status,
          frameDuration: const Duration(milliseconds: 100),
        ),
      ),
    ),
  );
}

void main() {
  test('standard assets seguem a convenção de nomes', () {
    final HangmanCharacterAssets assets = HangmanCharacterAssets.standard(
      maxMistakes: 6,
    );

    expect(
      (assets.idleImages.first as AssetImage).assetName,
      'assets/images/character/idle_00.png',
    );
    expect(
      (assets.errorImages[1]!.first as AssetImage).assetName,
      'assets/images/character/error_01/frame_00.png',
    );
    expect(
      (assets.victoryImages.first as AssetImage).assetName,
      'assets/images/character/victory/frame_00.png',
    );
    expect(assets.idleImages, hasLength(7));
    expect(assets.errorImages[6], hasLength(5));
  });

  testWidgets('começa no idle do estágio inicial', (tester) async {
    await _pump(tester, mistakes: 0, status: CharacterStatus.playing);

    expect(_currentImage(tester), 'idle_0.png');
  });

  testWidgets('toca o clipe de erro e para no idle do estágio', (tester) async {
    await _pump(tester, mistakes: 0, status: CharacterStatus.playing);
    await _pump(tester, mistakes: 1, status: CharacterStatus.playing);

    await tester.pump();
    expect(_currentImage(tester), 'e1_0.png');

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(_currentImage(tester), 'idle_1.png');
  });

  testWidgets('toca a vitória e volta ao idle', (tester) async {
    await _pump(tester, mistakes: 2, status: CharacterStatus.playing);
    await _pump(tester, mistakes: 2, status: CharacterStatus.won);

    await tester.pump();
    expect(_currentImage(tester), 'win_0.png');

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(_currentImage(tester), 'idle_2.png');
  });

  testWidgets('toca a derrota e volta ao idle final', (tester) async {
    await _pump(tester, mistakes: 6, status: CharacterStatus.playing);
    await _pump(tester, mistakes: 6, status: CharacterStatus.lost);

    await tester.pump();
    expect(_currentImage(tester), 'lose_0.png');

    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    expect(_currentImage(tester), 'idle_6.png');
  });

  testWidgets('encadeia o clipe de erro e depois a derrota', (tester) async {
    await _pump(tester, mistakes: 5, status: CharacterStatus.playing);
    await _pump(tester, mistakes: 6, status: CharacterStatus.lost);

    await tester.pump();
    expect(_currentImage(tester), 'e6_0.png');

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(_currentImage(tester), 'lose_0.png');

    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(_currentImage(tester), 'idle_6.png');
  });
}

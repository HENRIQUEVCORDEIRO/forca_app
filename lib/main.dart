import 'package:flutter/material.dart';

import 'screens/game_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/answer_board.dart';
import 'widgets/hangman_character.dart';

void main() {
  runApp(const ForcaApp());
}

class ForcaApp extends StatelessWidget {
  const ForcaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: const TelaInicial(),
    );
  }
}

class TelaInicial extends StatelessWidget {
  const TelaInicial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset('assets/forca.png', height: 350),
                Text(
                  'HANGMAN',
                  style: AppTextStyles.title.copyWith(fontSize: 48),
                ),
              ],
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.onAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => GameScreen(
                      categoryLabel: 'Animais',
                      difficultyLabel: 'Fácil',
                      mistakes: 0,
                      maxMistakes: 6,
                      status: CharacterStatus.playing,
                      words: const <List<AnswerDisplayChar>>[],
                      usedLetters: const <String>{},
                      hint: null,
                      isHintUsed: false,
                      onLetterSelected: (_) {},
                      onRequestHint: () {},
                      onPlayAgain: () {},
                      onExit: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
              child: Text(
                'JOGAR',
                style: AppTextStyles.title.copyWith(
                  fontSize: 28,
                  color: AppColors.onAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

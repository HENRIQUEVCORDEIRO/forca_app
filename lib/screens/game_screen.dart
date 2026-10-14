import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/answer_board.dart';
import '../widgets/hangman_character.dart';
import '../widgets/hint_panel.dart';
import '../widgets/letter_keyboard.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({
    super.key,
    required this.categoryLabel,
    required this.difficultyLabel,
    required this.mistakes,
    required this.maxMistakes,
    required this.status,
    required this.words,
    required this.usedLetters,
    required this.hint,
    required this.isHintUsed,
    required this.onLetterSelected,
    required this.onRequestHint,
    required this.onPlayAgain,
    this.onExit,
    this.characterAssets,
  });

  final String categoryLabel;
  final String difficultyLabel;
  final int mistakes;
  final int maxMistakes;
  final CharacterStatus status;
  final List<List<AnswerDisplayChar>> words;
  final Set<String> usedLetters;
  final String? hint;
  final bool isHintUsed;
  final ValueChanged<String> onLetterSelected;
  final VoidCallback onRequestHint;
  final VoidCallback onPlayAgain;
  final VoidCallback? onExit;
  final HangmanCharacterAssets? characterAssets;

  bool get _isPlaying => status == CharacterStatus.playing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _isPlaying ? null : onPlayAgain,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: <Widget>[
                _TopBar(
                  categoryLabel: categoryLabel,
                  difficultyLabel: difficultyLabel,
                  onExit: onExit,
                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: !_isPlaying,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: _ResultMessage(won: status == CharacterStatus.won),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: HangmanCharacter(
                    assets:
                        characterAssets ??
                        HangmanCharacterAssets.standard(
                          maxMistakes: maxMistakes,
                        ),
                    mistakes: mistakes,
                    maxMistakes: maxMistakes,
                    status: status,
                  ),
                ),
                const SizedBox(height: 8),
                AnswerBoard(words: words),
                const SizedBox(height: 12),
                HintPanel(
                  hint: hint,
                  isHintUsed: isHintUsed,
                  enabled: _isPlaying,
                  onRequestHint: onRequestHint,
                ),
                const SizedBox(height: 12),
                LetterKeyboard(
                  rows: LetterKeyboard.qwertyRows,
                  usedLetters: usedLetters,
                  enabled: _isPlaying,
                  onLetterSelected: onLetterSelected,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.categoryLabel,
    required this.difficultyLabel,
    this.onExit,
  });

  final String categoryLabel;
  final String difficultyLabel;
  final VoidCallback? onExit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: onExit,
          icon: const Icon(Icons.arrow_back),
          color: AppColors.accent,
          disabledColor: AppColors.accent.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: <Widget>[
              _InfoChip(label: categoryLabel),
              _InfoChip(label: difficultyLabel),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.onAccent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ResultMessage extends StatelessWidget {
  const _ResultMessage({required this.won});

  final bool won;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            won ? 'Você venceu!' : 'Você perdeu!',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.onAccent,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Toque na tela para jogar novamente',
          style: TextStyle(color: AppColors.accent),
        ),
      ],
    );
  }
}

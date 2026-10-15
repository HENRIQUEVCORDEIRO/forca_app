import 'dart:math';

import 'package:flutter/material.dart';

import 'data/hangman_entries_repository.dart';
import 'domain/answer_category.dart';
import 'domain/difficulty.dart';
import 'domain/hangman_entry.dart';
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
                    builder: (BuildContext routeContext) => _GameRoute(
                      onExit: () => Navigator.of(routeContext).pop(),
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

class _GameRoute extends StatefulWidget {
  const _GameRoute({required this.onExit});

  final VoidCallback onExit;

  @override
  State<_GameRoute> createState() => _GameRouteState();
}

class _GameRouteState extends State<_GameRoute> {
  static const int _maxMistakes = 6;

  final AssetHangmanEntriesRepository _repository =
      AssetHangmanEntriesRepository();
  final Random _random = Random();

  AnswerCategory _category = AnswerCategory.animals;
  HangmanEntry? _entry;
  List<HangmanEntry>? _entries;
  Set<String> _usedLetters = <String>{};
  int _mistakes = 0;
  CharacterStatus _status = CharacterStatus.playing;
  String? _hint;
  bool _isHintUsed = false;
  bool _isLoading = true;
  String? _loadError;
  int _loadGeneration = 0;
  int _gameRevision = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFreshGame());
  }

  Future<void> _startFreshGame([AnswerCategory? category]) async {
    if (!mounted) return;
    final AnswerCategory nextCategory = category ?? _category;
    final HangmanEntry? previousEntry = _entry;
    final int loadGeneration = ++_loadGeneration;

    setState(() {
      _category = nextCategory;
      _entry = null;
      _usedLetters = <String>{};
      _mistakes = 0;
      _status = CharacterStatus.playing;
      _hint = null;
      _isHintUsed = false;
      _isLoading = true;
      _loadError = null;
      _gameRevision++;
    });

    try {
      final List<HangmanEntry> entries = _entries ??= await _repository
          .loadEntries();
      final List<HangmanEntry> categoryEntries = entries
          .where((HangmanEntry entry) => entry.category == nextCategory)
          .toList();
      final List<HangmanEntry> easyEntries = categoryEntries
          .where((HangmanEntry entry) => entry.difficulty == Difficulty.easy)
          .toList();
      final List<HangmanEntry> candidates =
          (easyEntries.isEmpty ? categoryEntries : easyEntries).toList();

      if (candidates.isEmpty) {
        throw StateError('Nenhuma palavra disponível para esta categoria.');
      }
      if (previousEntry != null && candidates.length > 1) {
        candidates.removeWhere(
          (HangmanEntry entry) => entry.answer == previousEntry.answer,
        );
      }

      final HangmanEntry selectedEntry =
          candidates[_random.nextInt(candidates.length)];
      if (!mounted || loadGeneration != _loadGeneration) return;

      setState(() {
        _entry = selectedEntry;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || loadGeneration != _loadGeneration) return;
      setState(() {
        _loadError = 'Não foi possível carregar uma palavra.';
        _isLoading = false;
      });
    }
  }

  List<List<AnswerDisplayChar>> get _displayWords {
    final HangmanEntry? entry = _entry;
    if (entry == null) return const <List<AnswerDisplayChar>>[];

    final List<List<AnswerDisplayChar>> words = <List<AnswerDisplayChar>>[
      <AnswerDisplayChar>[],
    ];
    for (final character in entry.characters) {
      if (character.original == ' ') {
        words.add(<AnswerDisplayChar>[]);
        continue;
      }
      words.last.add(
        AnswerDisplayChar(
          text: character.original,
          isRevealed:
              !character.isLetter ||
              _usedLetters.contains(character.baseLetter),
        ),
      );
    }
    return words
        .where((List<AnswerDisplayChar> word) => word.isNotEmpty)
        .toList();
  }

  void _selectLetter(String letter) {
    final HangmanEntry? entry = _entry;
    if (entry == null || _status != CharacterStatus.playing) return;

    setState(() {
      if (!_usedLetters.add(letter)) return;

      if (!entry.requiredLetters.contains(letter)) {
        _mistakes++;
      }
      if (entry.requiredLetters.every(_usedLetters.contains)) {
        _status = CharacterStatus.won;
      } else if (_mistakes >= _maxMistakes) {
        _status = CharacterStatus.lost;
      }
    });
  }

  void _requestHint() {
    final HangmanEntry? entry = _entry;
    if (entry == null || _isHintUsed || _status != CharacterStatus.playing) {
      return;
    }
    setState(() {
      _hint = entry.hints.first;
      _isHintUsed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const SafeArea(child: Center(child: CircularProgressIndicator())),
      );
    }

    if (_loadError != null || _entry == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(_loadError ?? 'Não foi possível carregar uma palavra.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _startFreshGame(),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return GameScreen(
      key: ValueKey<int>(_gameRevision),
      categoryLabel: _category.label,
      difficultyLabel: _entry!.difficulty.label,
      mistakes: _mistakes,
      maxMistakes: _maxMistakes,
      status: _status,
      words: _displayWords,
      usedLetters: _usedLetters,
      hint: _hint,
      isHintUsed: _isHintUsed,
      onLetterSelected: _selectLetter,
      onRequestHint: _requestHint,
      onPlayAgain: () => _startFreshGame(),
      onCategoryChanged: (AnswerCategory category) => _startFreshGame(category),
      onExit: widget.onExit,
    );
  }
}

import 'package:flutter/material.dart';

enum CharacterStatus { playing, won, lost }

String _twoDigits(int value) => value.toString().padLeft(2, '0');

class HangmanCharacterAssets {
  const HangmanCharacterAssets({
    required this.idleImages,
    required this.errorImages,
    this.victoryImages = const <ImageProvider>[],
    this.defeatImages = const <ImageProvider>[],
  });

  final List<ImageProvider> idleImages;
  final Map<int, List<ImageProvider>> errorImages;
  final List<ImageProvider> victoryImages;
  final List<ImageProvider> defeatImages;

  static const Map<int, int> _errorFrameCounts = <int, int>{
    1: 3,
    2: 3,
    3: 4,
    4: 4,
    5: 5,
    6: 5,
  };

  factory HangmanCharacterAssets.standard({int maxMistakes = 6}) {
    return HangmanCharacterAssets(
      idleImages: <ImageProvider>[
        for (var stage = 0; stage <= maxMistakes; stage++)
          AssetImage('assets/images/character/idle_${_twoDigits(stage)}.png'),
      ],
      errorImages: <int, List<ImageProvider>>{
        for (var stage = 1; stage <= maxMistakes; stage++)
          stage: <ImageProvider>[
            for (
              var frame = 0;
              frame < (_errorFrameCounts[stage] ?? 0);
              frame++
            )
              AssetImage(
                'assets/images/character/error_${_twoDigits(stage)}/frame_${_twoDigits(frame)}.png',
              ),
          ],
      },
      victoryImages: <ImageProvider>[
        for (var frame = 0; frame < 5; frame++)
          AssetImage(
            'assets/images/character/victory/frame_${_twoDigits(frame)}.png',
          ),
      ],
      defeatImages: <ImageProvider>[
        for (var frame = 0; frame < 6; frame++)
          AssetImage(
            'assets/images/character/defeat/frame_${_twoDigits(frame)}.png',
          ),
      ],
    );
  }
}

class HangmanCharacter extends StatefulWidget {
  const HangmanCharacter({
    super.key,
    required this.assets,
    required this.mistakes,
    required this.maxMistakes,
    required this.status,
    this.frameDuration = const Duration(milliseconds: 100),
  });

  final HangmanCharacterAssets assets;
  final int mistakes;
  final int maxMistakes;
  final CharacterStatus status;
  final Duration frameDuration;

  @override
  State<HangmanCharacter> createState() => _HangmanCharacterState();
}

class _HangmanCharacterState extends State<HangmanCharacter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<List<ImageProvider>> _queue = <List<ImageProvider>>[];
  List<ImageProvider> _frames = const <ImageProvider>[];
  int _frameIndex = 0;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this)
      ..addListener(_handleTick)
      ..addStatusListener(_handleAnimationStatus);
    _showIdle();
  }

  @override
  void didUpdateWidget(covariant HangmanCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mistakes != oldWidget.mistakes) {
      _enqueue(widget.assets.errorImages[_stage] ?? const <ImageProvider>[]);
    }
    if (widget.status != oldWidget.status) {
      if (widget.status == CharacterStatus.won) {
        _enqueue(widget.assets.victoryImages);
      } else if (widget.status == CharacterStatus.lost) {
        _enqueue(widget.assets.defeatImages);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int get _stage {
    if (widget.mistakes < 0) {
      return 0;
    }
    if (widget.mistakes > widget.maxMistakes) {
      return widget.maxMistakes;
    }
    return widget.mistakes;
  }

  void _showIdle() {
    final List<ImageProvider> idle = widget.assets.idleImages;
    _frames = idle.isEmpty
        ? const <ImageProvider>[]
        : <ImageProvider>[idle[_stage]];
    _frameIndex = 0;
  }

  void _enqueue(List<ImageProvider> frames) {
    if (frames.isEmpty) {
      return;
    }
    _queue.add(frames);
    if (!_playing) {
      _playNext();
    }
  }

  void _playNext() {
    if (_queue.isEmpty) {
      _playing = false;
      setState(_showIdle);
      return;
    }
    _playing = true;
    _frames = _queue.removeAt(0);
    _frameIndex = 0;
    _controller
      ..duration = widget.frameDuration * _frames.length
      ..forward(from: 0);
  }

  void _handleTick() {
    if (_frames.length <= 1) {
      return;
    }
    final int index = (_controller.value * _frames.length).floor();
    final int clamped = index < 0
        ? 0
        : (index >= _frames.length ? _frames.length - 1 : index);
    if (clamped != _frameIndex) {
      setState(() => _frameIndex = clamped);
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _playNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_frames.isEmpty) {
      return const SizedBox.shrink();
    }
    return Image(
      image: _frames[_frameIndex],
      fit: BoxFit.contain,
      gaplessPlayback: true,
      errorBuilder: (
        BuildContext context,
        Object error,
        StackTrace? stackTrace,
      ) => const SizedBox.shrink(),
    );
  }
}

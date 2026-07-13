import 'dart:async';

import 'package:flosu/core/assets.dart';
import 'package:flosu/logic/providers/gameplay_data.dart';
import 'package:flosu/logic/services/file_parser.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/ui/widgets/common/osu_cube_loader.dart';
import 'package:flosu/ui/widgets/common/osu_logo.dart';

/// Transitional screen shown while a beatmap's assets are being prepared.
///
/// Performs the following tasks sequentially:
/// 1. Disposes all previously loaded hitsound samples.
/// 2. Pre-loads the background samples defined in the beatmap's event list.
/// 3. Loads and starts playing the beatmap's audio track.
/// 4. Navigates to the gameplay screen when all assets are ready.
///
/// A short visual delay is inserted at the start so that the page's
/// enter animation completes before heavy I/O begins.
class GameplayLoaderPage extends ConsumerStatefulWidget {
  const GameplayLoaderPage({super.key});

  @override
  ConsumerState<GameplayLoaderPage> createState() => _GameplayLoaderPageState();
}

class _GameplayLoaderPageState extends ConsumerState<GameplayLoaderPage> {
  bool _showInfo = false;
  bool _isLoaded = false, _isValid = false;

  @override
  initState() {
    _load();
    super.initState();
  }

  /// Runs the full asset-loading sequence and navigates to `/gameplay`.
  void _load() async {
    ref.listenManual(gameplayDataProvider, (_, details) {
      _isValid = details.validForGameplay;
      _startGameplay();
    }, fireImmediately: true);

    const songselectConfirm = AppSamples.songselectConfirmSelection;

    final beatmap = ref.read(audioProvider)!;
    final samples = ref.read(sampleService);
    final audio = ref.read(audioProvider.notifier);
    final details = ref.read(gameplayDataProvider);

    // Ensure feedback at loading screen
    samples.play(songselectConfirm);

    if (!details.validForGameplay) {
      ref
          .read(fileParserService)
          .parseFile(beatmap.filePath, data: details.metadata);
    }

    await audio.load(beatmap);

    // Pause before animation
    await Future.delayed(Durations.medium1);
    if (mounted) setState(() => _showInfo = true);

    _isLoaded = true;
    _startGameplay();
  }

  void _startGameplay() async {
    if (!_isValid || !_isLoaded) return;

    final audio = ref.read(audioProvider.notifier);
    final beatmap = ref.read(audioProvider)!;

    await audio.play(beatmap);
    if (mounted) context.go("/gameplay");
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.read(gameplayDataProvider);

    return Column(
      mainAxisAlignment: .center,
      children: [
        const OsuLogo(scale: 1 / 12),
        TweenAnimationBuilder(
          tween: Tween(end: _showInfo ? 1.0 : 0.0),
          duration: Durations.medium1,
          curve: Curves.easeOut,
          builder: (_, t, child) => Align(
            alignment: .topCenter,
            heightFactor: t,
            child: Opacity(opacity: t, child: child),
          ),
          child: Column(
            mainAxisSize: .min,
            children: [
              const SizedBox(height: 12),
              Text(
                details.metadata?.info.title ?? "Loading beatmap...",
                maxLines: 1,
                overflow: .ellipsis,
                style: const TextStyle(
                  fontWeight: .w600,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              Text(
                details.metadata?.info.artist ?? "",
                maxLines: 1,
                overflow: .ellipsis,
                style: const TextStyle(fontSize: 12, height: 1),
              ),
              const SizedBox(height: 12),
              const OsuCubeLoader(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                scale: .5,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

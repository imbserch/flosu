import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/gameplay_service.dart';
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

  @override
  initState() {
    _load();
    super.initState();
  }

  /// Runs the full asset-loading sequence and navigates to `/gameplay`.
  void _load() async {
    final audio = ref.read(audioProvider.notifier);

    // Short pause so the page enter animation completes before I/O begins.
    await Future.delayed(Durations.long2);

    if (mounted) setState(() => _showInfo = true);

    final beatmap = ref.read(gameplayService).beatmap!;

    // Pre-load all background samples defined in the beatmap's event list.
    // TODO: Load samples in memory

    // Load and start the beatmap's audio track.
    await audio.load(beatmap);
    await audio.play(beatmap);

    if (mounted) context.go("/gameplay");
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.read(gameplayService);

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
                details.beatmap!.info.title,
                maxLines: 1,
                overflow: .ellipsis,
                style: const TextStyle(
                  fontWeight: .w600,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              Text(
                details.beatmap!.info.artist,
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

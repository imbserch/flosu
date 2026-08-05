import 'dart:async';

import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/domain/mod/mod_selector.dart';
import 'package:flosu/shared/domain/replay/replay_selector.dart';
import 'package:flosu/shared/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/shared/widgets/osu_cube_loader.dart';
import 'package:flosu/shared/widgets/osu_logo.dart';

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
    Future.microtask(_load);
    super.initState();
  }

  /// Runs the full asset-loading sequence and navigates to `/gameplay`.
  void _load() async {
    Beatmap? beatmap = ref.read(beatmapSelector);
    final replay = ref.read(replaySelector);

    if (beatmap == null) {
      throw StateError(
        "Beatmap must be selected before selecting GameplayLoaderPage",
      );
    }

    if (replay != null && replay.hash != beatmap.hash) {
      throw StateError("Ensure the Replay hash matches the current Beatmap");
    }

    // Pause before animation
    await Future.delayed(Durations.medium1);
    if (mounted) setState(() => _showInfo = true);

    if (replay != null) ref.read(modSelector.notifier).setMods(replay.mods);

    if (!beatmap.canPlay) {
      // Beatmap is updated in-place so it can be re-used
      final result = await ref
          .read(ioProvider)
          .parse(beatmap.filePath!, data: beatmap);

      assert(result.data is Beatmap);
      beatmap = result.data as Beatmap;
    }

    await Future.delayed(const Duration(seconds: 2));
    ref.read(beatmapSelector.notifier).selectBeatmap(beatmap);

    if (mounted) context.go("/gameplay");
  }

  @override
  Widget build(BuildContext context) {
    final beatmap = ref.read(beatmapSelector);

    assert(
      beatmap != null,
      'Beatmap must be selected before selecting GameplayLoaderPage',
    );

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
                beatmap!.title,
                maxLines: 1,
                overflow: .ellipsis,
                style: const TextStyle(
                  fontWeight: .w600,
                  fontSize: 18,
                  height: 1,
                ),
              ),
              Text(
                beatmap.artist,
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

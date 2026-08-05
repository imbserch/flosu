import 'dart:async';
import 'dart:math';

import 'package:flosu/features/settings/data/repositories/settings_repository.dart';
import 'package:flosu/features/song_select/data/repositories/beatmap_repository.dart';
import 'package:flosu/features/song_select/domain/beatmap_library.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/layout/main_layout_provider.dart';
import 'package:flosu/shared/input.dart';
import 'package:flosu/shared/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/shared/widgets/osu_cube_loader.dart';
import 'package:flosu/features/audio/audio.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _ready = false;
  Timer? _timer;

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Setups services that need async initialization
  Future<void> _setup(WidgetRef ref) async {
    // Setup repositories
    await ref.read(settingsRepository).init();
    await ref.read(beatmapRepository).init();

    // Setup I/O provider
    await ref.read(ioProvider).init();

    // Setup audio provider
    await ref.read(audioProvider).init();

    // Setup input provider
    await ref.read(inputProvider).init();

    // Load library until database is loaded
    ref.read(beatmapLibrary);
    await Future.delayed(Durations.medium1);
  }

  // Updated flow of loading
  // This is posible because of local database
  void _init() async {
    await _setup(ref);

    final layout = ref.read(mainLayoutProvider.notifier);

    final selector = ref.read(beatmapSelector.notifier);
    final track = ref.read(trackProvider.notifier);

    // Await for audio and layout
    await Future.microtask(() {
      track.stop();
      layout.setTopBarLocked(true);
    });

    /* await samples.loadMultipleFromAsset([
      AppSamples.songselectConfirmSelection,
      AppSamples.uiCursorTap,
      AppSamples.uiSettingsPopIn,
      AppSamples.uiMenuClose,
      AppSamples.introSeeya,
      welcomeSample,
    ]);
 */
    const delay = Duration(seconds: 2);
    final random = ref.read(beatmapLibrary).random;

    if (random != null) {
      await selector.loadTrack(random);
      selector.selectBeatmap(random, usePreview: false, startPaused: true);
      track.volume(0);
      track.resume();
      track.volume(1, over: delay);
    }

    if (mounted) setState(() => _ready = true);
    // samples.play(welcomeSample);

    Future.delayed(delay, () {
      // Set Top Bar unlocked
      final topBarOpen = ref.read(mainLayoutProvider).isTopBarOpen;
      layout.setTopBarLocked(false);
      if (!topBarOpen) layout.toggleTopBar();

      // Start playing random song
      // The main menu will handle shuffle mode like osu!lazer main menu

      // Go to main
      if (mounted) context.go("/main");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(24),
      child: Center(
        child: _ready
            ? TweenAnimationBuilder(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Durations.extralong4,
                curve: Curves.easeOut,
                builder: (_, t, _) => Text(
                  "Welcome",
                  style: TextStyle(
                    fontWeight: .bold,
                    letterSpacing: 1 + t,
                    fontSize: 20 + pow(t / 4, 2).toDouble(),
                    color: Colors.white.withValues(alpha: pow(t, 2) as double),
                  ),
                ),
              )
            : const OsuCubeLoader(),
      ),
    );
  }
}

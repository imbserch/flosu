import 'dart:async';
import 'dart:math';

import 'package:flosu/core/assets.dart';
import 'package:flosu/logic/providers/beatmap.dart';
import 'package:flosu/logic/providers/main_layout.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flosu/shared/services/io/io_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/features/audio/data/audio_provider.dart' as legacy_audio;
import 'package:flosu/shared/widgets/osu_cube_loader.dart';
import 'package:flosu/features/audio_experimental/audio.dart';

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
    // Setup audio provider
    await ref.read(audioProvider).init();

    // Setup I/O provider
    await ref.read(ioProvider).init();
  }

  // Updated flow of loading
  // This is posible because of local database
  void _init() async {
    await _setup(ref);

    final layout = ref.read(mainLayoutProvider.notifier);

    // Load library until database is loaded
    ref.read(beatmapProvider);

    const welcomeSample = AppSamples.introWelcome;

    final audio = ref.read(legacy_audio.audioProvider.notifier);
    final samples = ref.read(sampleService);

    // Await for audio and layout
    await Future.microtask(() {
      audio.stop();
      layout.setTopBarLocked(true);
    });

    await samples.loadMultipleFromAsset([
      AppSamples.songselectConfirmSelection,
      AppSamples.uiCursorTap,
      AppSamples.uiSettingsPopIn,
      AppSamples.uiMenuClose,
      AppSamples.introSeeya,
      welcomeSample,
    ]);

    final random = ref.read(beatmapProvider.notifier).getRandom();
    if (random != null) await audio.load(random);

    if (mounted) setState(() => _ready = true);
    samples.play(welcomeSample);

    Future.delayed(const Duration(seconds: 2), () {
      // Set Top Bar unlocked
      final topBarOpen = ref.read(mainLayoutProvider).isTopBarOpen;
      layout.setTopBarLocked(false);
      if (!topBarOpen) layout.toggleTopBar();

      // Start playing random song
      if (random != null) audio.preview(random);

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

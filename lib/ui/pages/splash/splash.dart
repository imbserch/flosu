import 'dart:async';
import 'dart:math';

import 'package:flosu/core/assets.dart';
import 'package:flosu/logic/providers/beatmap.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/ui/widgets/common/osu_cube_loader.dart';

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

  // Updated flow of loading
  // This is posible because of local database
  void _init() async {
    // Load library until database is loaded
    ref.read(beatmapProvider);

    const welcomeSample = AppSamples.introWelcome;

    final audio = ref.read(audioProvider.notifier);
    final samples = ref.read(sampleService);

    Future.microtask(audio.stop);

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
      if (random != null) audio.preview(random);
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

import 'dart:async';
import 'dart:isolate';
import 'dart:math' hide log;

import 'package:flosu/features/audio/audio.dart';
import 'package:flosu/features/song_select/domain/beatmap_library.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/input.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/shared/layout/animatable_page.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';
import 'package:flosu/shared/widgets/osu_logo.dart';

class MainSelectPage extends AnimatablePage {
  const MainSelectPage({super.key, required super.uri});

  @override
  AnimatablePageState<MainSelectPage> createState() => _MainSelectPageState();
}

class _MainSelectPageState extends AnimatablePageState<MainSelectPage>
    with Logging, KeyboardHandler {
  final _osuKey = GlobalKey();
  StreamSubscription<void>? _audioEndSubscription;

  Timer? _exitTimer, _setupTimer;
  bool _requestedExit = false, _canChangeSong = false;

  @override
  void initState() {
    super.initState();
    requestLogger();

    // Prevent other sources from modifying the sound
    _setTimer();
    _setupAudio();
  }

  @override
  bool input() {
    if (!keyboard.pressed) return false;

    switch (keyboard.key) {
      case .f1:
        _playPrevious();
        return true;
      case .f3:
        final handle = ref.read(trackProvider);
        if (handle == null) return false;

        final playing = ref.read(audioProvider).isPlaying(handle);
        final track = ref.read(trackProvider.notifier);

        playing ? track.pause() : track.resume();
        return true;
      case .f5:
        _playNext();
        return true;
      default:
        return false;
    }
  }

  void _playPrevious() async {
    _setTimer();

    //  No-op, wait until library works fine again
  }

  void _playNext() async {
    _setTimer();
    //  No-op, wait until library works fine again
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _setupTimer?.cancel();
    _audioEndSubscription?.cancel();
    removeLogger();
    super.dispose();
  }

  void _setTimer() {
    _canChangeSong = false;
    _setupTimer?.cancel();
    _setupTimer = Timer(
      const Duration(seconds: 10),
      () => _canChangeSong = true,
    );
  }

  void _setupAudio() {
    final handle = ref.read(trackProvider);
    final service = ref.read(audioProvider);

    if (handle != null) service.loop(handle);
  }

  void _playRandomAudio() async {
    if (!_canChangeSong) return;
    _setTimer();

    final random = ref.read(beatmapLibrary).random;

    if (random != null) {
      final selector = ref.read(beatmapSelector.notifier);
      await selector.loadTrack(random);
      selector.selectBeatmap(random);
    }
  }

  void _exit() {
    // App is already quitting
    if (_requestedExit) return;

    if (mounted) setState(() => _requestedExit = true);

    const exitDuration = Duration(seconds: 2, milliseconds: 500);

    final track = ref.read(trackProvider.notifier);

    track.stop(after: exitDuration);
    track.volume(0, over: exitDuration);
    // Sample is already loaded in splash
    // ref.read(sampleProvider).play(AppSamples.introSeeya);

    _exitTimer?.cancel();
    _exitTimer = Timer(exitDuration, () async {
      final result = await ServicesBinding.instance.exitApplication(.required);

      // App can't be closed in a safe way: kill process
      if (result == .cancel) Isolate.current.kill();
    });
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
    if (_requestedExit) {
      return Center(
        child: TweenAnimationBuilder(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(seconds: 2, milliseconds: 500),
          builder: (_, t, child) => Opacity(
            opacity: max(0, 1 - t * 1.25),
            child: Transform.rotate(angle: t * pi / 16, child: child!),
          ),
          child: OsuLogo(key: _osuKey, scale: 1 / 2),
        ),
      );
    }

    return Center(
      child: Stack(
        alignment: .center,
        children: [
          Container(
            width: double.maxFinite,
            height: 80,
            color: Colors.grey.shade800,
          ),
          Transform.translate(
            offset: Offset(-context.screenScaled.width * (1 - animProgress), 0),
            child: Row(
              mainAxisSize: .min,
              children: [
                SkewedBox(
                  height: 80,
                  width: 144,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: .zero,
                  ),
                  padding: const .only(right: 20),
                  onTap: _requestedExit
                      ? null
                      : () => Scaffold.of(context).openDrawer(),
                  child: const Column(
                    spacing: 4,
                    mainAxisAlignment: .center,
                    children: [
                      Icon(Icons.settings_outlined),
                      Text("settings", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                const SizedBox.square(dimension: 104),
                SkewedBox(
                  height: 80,
                  width: 144,
                  decoration: const BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: .zero,
                  ),
                  padding: const .only(left: 20),
                  onTap: _requestedExit ? null : () => context.go("/songs"),
                  child: const Column(
                    spacing: 4,
                    mainAxisAlignment: .center,
                    children: [
                      Icon(Icons.play_circle_outline),
                      Text("play", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
                SkewedBox(
                  height: 80,
                  width: 112,
                  decoration: const BoxDecoration(
                    color: Colors.pink,
                    borderRadius: .zero,
                  ),
                  onTap: _exit,
                  child: Column(
                    spacing: 4,
                    mainAxisAlignment: .center,
                    children: [
                      Transform.rotate(
                        angle: pi / 4,
                        child: const Icon(Icons.add_circle_outline),
                      ),
                      const Text("quit", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: .min,
            children: [
              const SizedBox(width: 72),
              Transform.translate(
                offset: Offset(
                  -context.screenScaled.width * (1 - animProgress),
                  0,
                ),
                child: OsuLogo(
                  key: _osuKey,
                  scale: (1 / 3) * animProgress,
                  onTap: _requestedExit ? null : () => context.go("/songs"),
                ),
              ),
              const SizedBox(width: 184),
            ],
          ),
        ],
      ),
    );
  }
}

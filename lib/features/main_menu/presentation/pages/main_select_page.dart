import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import 'package:flosu/core/assets.dart';
import 'package:flosu/features/audio/data/audio_provider.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/shared/widgets/skewed_box.dart';
import 'package:flosu/shared/widgets/osu_logo.dart';

class MainSelectPage extends AnimatablePage {
  const MainSelectPage({super.key, required super.uri});

  @override
  AnimatablePageState<MainSelectPage> createState() => _MainSelectPageState();
}

class _MainSelectPageState extends AnimatablePageState<MainSelectPage> {
  final _osuKey = GlobalKey();

  Timer? _exitTimer;
  bool _requestedExit = false;

  @override
  dispose() {
    super.dispose();
    _exitTimer?.cancel();
  }

  void _exit() {
    // App is already quitting
    if (_requestedExit) return;

    if (mounted) setState(() => _requestedExit = true);

    ref.read(audioProvider.notifier).stop();
    // Sample is already loaded in splash
    ref.read(sampleService).play(AppSamples.introSeeya);

    _exitTimer?.cancel();
    _exitTimer = Timer(const Duration(seconds: 2, milliseconds: 500), () async {
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

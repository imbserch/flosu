import 'dart:math';

import 'package:flosu/logic/providers/library.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/ui/shared/animatable_page.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flosu/ui/widgets/common/osu_logo.dart';

class MainSelectPage extends AnimatablePage {
  const MainSelectPage({super.key, required super.uri});

  @override
  AnimatablePageState<MainSelectPage> createState() => _MainSelectPageState();
}

class _MainSelectPageState extends AnimatablePageState<MainSelectPage> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) => _playMusic());
    super.initState();
  }

  void _playMusic() async {
    final audio = ref.read(audioProvider.notifier);
    if (audio.playing) return;

    final beatmap = ref.read(libraryProvider.notifier).getRandom();

    if (beatmap != null) await audio.preview(beatmap);
  }

  @override
  Widget buildPage(BuildContext context, double animProgress) {
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
                  onTap: () => Scaffold.of(context).openDrawer(),
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
                  onTap: () => context.go("/songs"),
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
                  onTap: () {},
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
                  scale: (1 / 3) * animProgress,
                  onTap: () => context.go("/songs"),
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

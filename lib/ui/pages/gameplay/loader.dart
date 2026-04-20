import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/gameplay_service.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/providers/sample_service.dart';
import 'package:flosu/ui/widgets/common/osu_cube_loader.dart';
import 'package:flosu/ui/widgets/common/osu_logo.dart';

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

  void _load() async {
    final samples = ref.read(sampleService);
    final audio = ref.read(audioProvider.notifier);

    await Future.delayed(Durations.long2);

    if (mounted) setState(() => _showInfo = true);

    //Dispose previous samples
    await samples.disposeAll();

    final beatmap = ref.read(gameplayService).beatmap!;

    //Load all samples
    final events = beatmap.events.whereType<BeatmapSample>();
    await Future.wait(events.map((s) => samples.load(s.file, s.volume)));

    //Load and play
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

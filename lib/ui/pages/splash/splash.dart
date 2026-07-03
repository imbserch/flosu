import 'package:flosu/logic/providers/library.dart';
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
  @override
  initState() {
    _initBeatmaps();
    super.initState();
  }

  void _initBeatmaps() async {
    //Only keep this provider waiting for initial update
    ref.read(libraryProvider);

    //Stop audio
    Future.microtask(() {
      ref.read(audioProvider.notifier).stop();
      // TODO: Implement .stopAll()
      // ref.read(sampleService.notifier).dispose();
    });

    //Await for user to read the text
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) context.go("/main");
  }

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: .all(24),
      child: Center(
        child: Column(
          mainAxisSize: .min,
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Text("Welcome to flosu", style: TextStyle(fontWeight: .w900)),
            Text(
              "This is an experimental osu!lazer proyect built with Flutter. May contain bugs.",
              textAlign: .center,
              style: TextStyle(fontSize: 8, fontWeight: .w300),
            ),
            SizedBox(height: 4),
            OsuCubeLoader(scale: .75),
          ],
        ),
      ),
    );
  }
}

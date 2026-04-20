import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/providers/beatmap_service.dart';
import 'package:flosu/ui/widgets/common/osu_cube_loader.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  String? _lastLog;

  @override
  initState() {
    _initBeatmaps();
    super.initState();
  }

  void _initBeatmaps() async {
    //Stop audio
    ref.read(audioProvider.notifier).stop();

    //Await for widget to be ready
    await Future.delayed(const Duration(seconds: 5));

    //Load the beatmaps library and then, redirect to songs
    final beatmapLogs = await ref.read(beatmapService.notifier).initialize();

    if (beatmapLogs != null) {
      beatmapLogs.listen(
        (data) {
          if (mounted) setState(() => _lastLog = data);
        },
        onDone: () {
          if (mounted) context.go("/main");
        },
      );
    } else {
      if (mounted) context.go("/main");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(24),
      child: Stack(
        alignment: .bottomRight,
        children: [
          Column(
            mainAxisSize: .min,
            mainAxisAlignment: .start,
            crossAxisAlignment: .stretch,
            children: [
              Text(
                _lastLog != null ? "Loading" : "Important",
                style: TextStyle(
                  color: _lastLog != null ? AppColors.green : AppColors.red,
                  fontWeight: .w900,
                ),
              ),
              Text(
                _lastLog ??
                    "This is an experimental osu!lazer proyect built with Flutter. It may contain various bugs and unimplemented behaviors\n\nThis game will attempt to run at the highest possible monitor refresh rate",
                style: const TextStyle(fontSize: 8, fontWeight: .w300),
              ),
            ],
          ),
          const OsuCubeLoader(),
        ],
      ),
    );
  }
}

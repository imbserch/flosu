import 'dart:math';
import 'dart:ui';

import 'package:flosu/logic/providers/settings.dart';
import 'package:flosu/logic/services/library.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flosu/repositories/beatmap.dart';
import 'package:flosu/repositories/settings.dart';
import 'package:flosu/ui/widgets/overlay/tooltip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Slider, MouseCursor, Tooltip;
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart' hide MouseCursor;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/logic/services/audio.dart';
import 'package:flosu/shared/navigation/router.dart';
import 'package:flosu/shared/widgets/reescalable.dart';
import 'package:flosu/ui/widgets/debug/frame_stats.dart';
import 'package:flosu/ui/widgets/debug/log_console.dart';
import 'package:flosu/ui/widgets/gameplay/mouse_cursor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SchedulerBinding.instance.requestPerformanceMode(
    DartPerformanceMode.throughput,
  );

  // System Configurations
  await SystemChrome.setEnabledSystemUIMode(.immersiveSticky);
  await SystemChrome.setPreferredOrientations([
    .landscapeLeft,
    .landscapeRight,
  ]);

  // Set a big image cache size for storing all beatmap images
  imageCache
    ..maximumSize = 64
    ..maximumSizeBytes = pow(1024, 3).round();

  // Initialize settings repository
  final settingsRepository = SettingsRepository();
  await settingsRepository.init();

  // Initialize beatmap repository
  final beatmapRepository = BeatmapRepository();
  await beatmapRepository.init();

  // Start services that needs initialization
  await AudioService.instance.init();
  await SampleService.instance.init();
  await LibraryService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settingsRepository),
        beatmapRepositoryProvider.overrideWithValue(beatmapRepository),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    final fpsMonitorEnabled = ref.watch(
      settingsProvider.select((it) => it.fpsMonitorEnabled),
    );
    final logsEnabled = ref.watch(
      settingsProvider.select((it) => it.logsEnabled),
    );

    return MaterialApp.router(
      checkerboardOffscreenLayers: kDebugMode,
      checkerboardRasterCacheImages: kDebugMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Reescalable(
        toSize: const Size(640, 480),
        child: Stack(
          fit: .expand,
          children: [
            (child ?? const SizedBox.shrink()).hiddenCursor,
            const RepaintBoundary(child: MouseCursor()),
            const Tooltip(),

            // Fps counter
            Align(
              alignment: Alignment.bottomRight,
              child: RepaintBoundary(
                child: FrameStats(compact: !fpsMonitorEnabled),
              ),
            ),

            // Logs
            if (logsEnabled)
              const Align(
                alignment: Alignment.bottomLeft,
                child: RepaintBoundary(child: LogConsole()),
              ),
          ],
        ),
      ),
      theme: ThemeData(
        visualDensity: .compact,
        fontFamily: "Torus",
        brightness: Brightness.dark,
        materialTapTargetSize: .shrinkWrap,
        sliderTheme: const SliderThemeData(
          trackHeight: 3,
          trackGap: 12,
          mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.none),
          thumbSize: WidgetStatePropertyAll(Size(30, 9)),
          padding: .zero,
          showValueIndicator: .never,
          valueIndicatorTextStyle: TextStyle(
            fontFamily: "Torus",
            color: Colors.black,
            fontWeight: .bold,
            fontSize: 8,
            height: 1,
          ),
          // ignore: deprecated_member_use
          year2023: false,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            tapTargetSize: .shrinkWrap,
            mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.none),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: .circular(6)),
            ),
            iconSize: const WidgetStatePropertyAll(12),
            iconColor: const WidgetStatePropertyAll(Colors.white),
            minimumSize: const WidgetStatePropertyAll(Size(120, 32)),
            padding: const WidgetStatePropertyAll(.all(4)),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            tapTargetSize: .shrinkWrap,
            mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.none),
            minimumSize: const WidgetStatePropertyAll(Size.square(28)),
            padding: const WidgetStatePropertyAll(.all(4)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: .circular(6)),
            ),
          ),
        ),
      ),
      title: "flosu",
    );
  }
}

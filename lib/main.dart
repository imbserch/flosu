import 'dart:math';
import 'dart:ui';

import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/logic/services/library.dart';
import 'package:flosu/logic/services/sample.dart';
import 'package:flosu/ui/widgets/overlay/tooltip.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Slider, MouseCursor, Tooltip;
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/logic/services/audio.dart';
import 'package:flosu/logic/services/storage.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/ui/widgets/common/reescalable.dart';
import 'package:flosu/ui/widgets/debug/frame_stats.dart';
import 'package:flosu/ui/widgets/debug/log_console.dart';
import 'package:flosu/ui/widgets/gameplay/mouse_cursor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SchedulerBinding.instance.requestPerformanceMode(DartPerformanceMode.latency);

  //Set a big image cache size for storing all beatmap images
  imageCache.maximumSize = 64;
  imageCache.maximumSizeBytes = pow(1024, 3).round();

  //Start services that needs initialization
  await AudioService.instance.init();
  await StorageService.instance.init();
  await LibraryService.instance.init();
  await SampleService.instance.init();

  runApp(const ProviderScope(child: MainApp()));
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

    final showFps = ref.watch(
      storageProvider.select((it) => it.showFpsMonitor),
    );
    final showLogs = ref.watch(storageProvider.select((it) => it.showLogs));

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
            if (showFps)
              const Align(
                alignment: Alignment.bottomRight,
                child: RepaintBoundary(child: FrameStats()),
              ),
            if (showLogs)
              const Align(
                alignment: Alignment.bottomLeft,
                child: RepaintBoundary(child: LogConsole()),
              ),
          ],
        ),
      ),
      theme: ThemeData(
        fontFamily: "Torus",
        brightness: Brightness.dark,
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
            mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.none),
            minimumSize: const WidgetStatePropertyAll(Size.square(28)),
            padding: const WidgetStatePropertyAll(.all(4)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: .circular(6)),
            ),
          ),
        ),
      ),
      title: "Osu! Flutter",
    );
  }
}

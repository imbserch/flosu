import 'dart:async';

import 'package:flosu/core/engine/game_loop.dart';
import 'package:flosu/core/extensions/format.dart';
import 'package:flosu/core/math/interpolation.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/features/audio/audio.dart';
import 'package:flosu/features/settings/domain/settings_provider.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DebugOverlay extends ConsumerStatefulWidget {
  const DebugOverlay({super.key});

  @override
  ConsumerState<DebugOverlay> createState() => _DebugOverlayState();
}

class _DebugOverlayState extends ConsumerState<DebugOverlay>
    with GameLoopListener {
  late Timer _clockDelayTimer;

  double _audioDelay = 0.0;
  double _frameTime = 1, _framesPerSecond = 1000;
  int _tracks = 0, _loadingTracks = 0;

  @override
  void initState() {
    super.initState();
    _clockDelayTimer = Timer.periodic(Durations.long2, (_) {
      final clockStats = ref.read(audioClock.notifier);
      _audioDelay = clockStats.clockDelay;

      if (mounted) setState(() {});
    });
  }

  double get refreshRate => View.maybeOf(context)?.display.refreshRate ?? 60;

  @override
  void dispose() {
    super.dispose();
    _clockDelayTimer.cancel();
  }

  @override
  void process(_) {
    final showFps = ref.read(
      settingsProvider.select((it) => it.fpsMonitorEnabled),
    );

    _frameTime = (frameTiming?.totalSpan.inMicroseconds ?? 1) / 1000;
    _framesPerSecond = 1000 / _frameTime;

    final audioStats = ref.read(audioProvider);
    _tracks = audioStats.tracks;
    _loadingTracks = audioStats.loadingTracks;

    if (mounted && showFps) setState(() {});
  }

  Color _colorForThresholds(double current, double min, double max) {
    final avg = (min + max) / 2;

    if (current > avg) {
      return Color.lerp(
        AppColors.yellow,
        AppColors.red,
        Interpolation.inverseLerp(avg, max, current),
      )!;
    }

    return Color.lerp(
      AppColors.green,
      AppColors.yellow,
      Interpolation.inverseLerp(min, avg, current),
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final showLogs = ref.watch(settingsProvider.select((it) => it.logsEnabled));
    final showFps = ref.watch(
      settingsProvider.select((it) => it.fpsMonitorEnabled),
    );

    return DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 8, fontWeight: .bold, height: 1),

      child: Padding(
        padding: const .all(4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                spacing: 4,
                crossAxisAlignment: .start,
                mainAxisAlignment: .end,
                children: [
                  if (!kReleaseMode) ...[
                    DebugOverlayContainer(
                      label: 'Flosu',
                      children: [
                        DebugOverlayItem(
                          label: GameLoop.time.toPrintableDuration,
                        ),
                      ],
                    ),
                    DebugOverlayContainer(
                      label: 'Audio',
                      color: AppColors.green,
                      children: [
                        DebugOverlayItem(label: "$_tracks loaded"),
                        DebugOverlayItem(
                          label: 'loading',
                          value: _loadingTracks,
                          format: (v) => "${v.round()}",
                          color: (v) => _colorForThresholds(v, 0, 64),
                          reverseOrder: true,
                        ),
                        DebugOverlayItem(
                          label: 'delay',
                          value: _audioDelay,
                          format: (v) {
                            // This is because audio clock is updating his time
                            // during the frame, and the audio is playing.
                            if (v >= 32) return "Re-syncing";

                            if (v >= 10) return "${v.round()} ms";
                            if (v >= 5) return '${v.toStringAsFixed(1)} ms';

                            return '${v.toStringAsFixed(2)} ms';
                          },
                          color: (v) => _colorForThresholds(v, 8, 32),
                          reverseOrder: true,
                        ),
                      ],
                    ),
                  ],
                  if (showFps)
                    DebugOverlayContainer(
                      label: 'Performance',
                      color: AppColors.yellow,
                      children: [
                        DebugOverlayItem(
                          value: _frameTime,
                          format: (v) {
                            if (v >= 10) return "${v.round()} ms";
                            if (v >= 5) return '${v.toStringAsFixed(1)} ms';

                            return '${v.toStringAsFixed(2)} ms';
                          },
                          color: (v) => _colorForThresholds(v, 5, 66),
                        ),
                        DebugOverlayItem(
                          label: 'fps',
                          value: _framesPerSecond,
                          format: (v) => "${v.round()}",
                          color: (_) =>
                              _colorForThresholds(_frameTime, 5, refreshRate),
                          reverseOrder: true,
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: .end,
                children: [
                  if (showLogs)
                    ValueListenableBuilder(
                      valueListenable: Logger.instance.logs,
                      builder: (_, logs, _) => DebugOverlayContainer(
                        label: "Logs",
                        crossAxisAlignment: .end,
                        children: [
                          for (final l in logs)
                            DebugOverlayItem(
                              label: l.message,
                              value: 1,
                              format: (_) => l.tag,
                              color: (v) => l.level.color,
                              minLabelWidth: 192,
                              reverseOrder: true,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DebugOverlayContainer extends StatelessWidget {
  const DebugOverlayContainer({
    super.key,
    required this.label,
    this.color,
    required this.children,
    this.crossAxisAlignment = .start,
  });

  final String label;
  final Color? color;

  final CrossAxisAlignment crossAxisAlignment;

  final List<DebugOverlayItem> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .all(4),
      decoration: BoxDecoration(
        color: AppColors.containerLowest.withValues(alpha: .5),
        borderRadius: .circular(4),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 7, height: 1, fontWeight: .w400),
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 9, color: color, fontWeight: .bold),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class DebugOverlayItem extends StatelessWidget {
  const DebugOverlayItem({
    super.key,
    this.label = "",
    this.minLabelWidth,
    this.value,
    this.format,
    this.color,
    this.reverseOrder = false,
  });

  final String label;
  final double? minLabelWidth;
  final num? value;

  final bool reverseOrder;

  final String Function(double)? format;

  final Color Function(double)? color;

  @override
  Widget build(BuildContext context) {
    assert(
      label.isNotEmpty || (label.isEmpty && value != null),
      "You must provide a non empty label or value",
    );

    final labelWidget = ConstrainedBox(
      constraints: BoxConstraints(minWidth: minLabelWidth ?? 0, maxWidth: 192),
      child: Text(label),
    );

    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      spacing: 3,
      children: [
        const SizedBox.shrink(),
        if (!reverseOrder && label.isNotEmpty) labelWidget,
        if (value != null)
          TweenAnimationBuilder<double>(
            tween: Tween(end: value!.toDouble()),
            duration: Durations.medium2,
            curve: Curves.fastOutSlowIn,
            builder: (_, v, _) => Text(
              format != null ? format!(v) : "$v",
              style: TextStyle(color: color != null ? color!(v) : null),
            ),
          ),
        if (reverseOrder && label.isNotEmpty) labelWidget,
      ],
    );
  }
}

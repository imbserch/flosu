import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flosu/core/constants.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/shared/navigation/router.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FrameStats extends ConsumerStatefulWidget {
  const FrameStats({
    super.key,
    required this.compact,
    this.alignment = .bottomRight,
  });
  final AlignmentGeometry alignment;
  final bool compact;

  @override
  ConsumerState<FrameStats> createState() => _FrameStatsState();
}

class _FrameStatsState extends ConsumerState<FrameStats> {
  final Float32List _buildTimings = Float32List(TIMINGS_SIZE);
  final Float32List _rasterTimings = Float32List(TIMINGS_SIZE);

  final Float32List _inputImmTimings = Float32List(TIMINGS_SIZE);
  final Float32List _inputDelTimings = Float32List(TIMINGS_SIZE);

  final Float32List _audioDelayTimings = Float32List(TIMINGS_SIZE);

  final Map<String, int> timingIndexes = {
    "Build": 0,
    "Raster": 0,
    "Input Imm": 0,
    "Input Del": 0,
    "Audio": 0,
  };

  double get displayRate => View.of(context).display.refreshRate;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => SchedulerBinding.instance.addTimingsCallback(_addFrameTimings),
    );

    ref.read(inputProvider.notifier).addTimingsHandler(_addInputTimings);
    ref.read(audioProvider.notifier).addTimingsHandler(_addAudioTimings);

    super.initState();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_addFrameTimings);
    globalRef
        .read(inputProvider.notifier)
        .removeTimingsHandler(_addInputTimings);
    globalRef
        .read(audioProvider.notifier)
        .removeTimingsHandler(_addAudioTimings);

    super.dispose();
  }

  void _addInputTimings(InputTimings timings) {
    final immDurations = timings.immediateEventsDuration;
    final delDurations = timings.delayedEventsDuration;

    _addDurationTimings(_inputImmTimings, immDurations, "Input Imm");
    _addDurationTimings(_inputDelTimings, delDurations, "Input Del");

    if (mounted) setState(() {});
  }

  void _addFrameTimings(List<FrameTiming> timings) {
    final buildDurations = timings.map((f) => f.buildDuration);
    final rasterDurations = timings.map((f) => f.rasterDuration);

    _addDurationTimings(_buildTimings, buildDurations, "Build");
    _addDurationTimings(_rasterTimings, rasterDurations, "Raster");

    if (mounted) setState(() {});
  }

  void _addAudioTimings(Duration delay) {
    _addDurationTimings(_audioDelayTimings, [delay], "Audio");
    if (mounted) setState(() {});
  }

  void _addDurationTimings(
    Float32List timingsList,
    Iterable<Duration> timings,
    String timingKey,
  ) {
    if (timings.isEmpty) return;

    final initialIndex = timingIndexes[timingKey] ?? 0;

    for (var i = 0; i < timings.length; i++) {
      final index = (initialIndex + i) % TIMINGS_SIZE;

      timingsList[index] = timings.elementAt(i).inMicroseconds / 1000;
    }

    timingIndexes[timingKey] = (initialIndex + timings.length) % TIMINGS_SIZE;
  }

  @override
  Widget build(BuildContext context) {
    final expandedChild = Container(
      width: 300,
      height: 150,
      margin: const .all(4),
      child: Column(
        crossAxisAlignment: .stretch,
        mainAxisSize: .min,
        spacing: 2,
        children: [
          Expanded(
            child: FrameVisualizer(
              timingsType: "Input",
              details: [
                TimingDetails(
                  timingsType: "Inmediate",
                  timings: _inputImmTimings,
                  timingIndex: timingIndexes["Input Imm"]!,
                  timingMaxTime: 1,
                  color: AppColors.lightBlue,
                ),
                TimingDetails(
                  timingsType: "Delayed",
                  timings: _inputDelTimings,
                  timingIndex: timingIndexes["Input Del"]!,
                  timingMaxTime: 3,
                  color: AppColors.purple,
                ),
              ],
            ),
          ),
          Expanded(
            child: FrameVisualizer(
              timingsType: "Audio",
              details: [
                TimingDetails(
                  timingsType: "Delay",
                  timings: _audioDelayTimings,
                  timingIndex: timingIndexes["Audio"]!,
                  timingMaxTime: 16,
                  color: AppColors.pink,
                ),
              ],
            ),
          ),
          Expanded(
            child: FrameVisualizer(
              timingsType: "Draw",
              details: [
                TimingDetails(
                  timingsType: "Raster",
                  timings: _rasterTimings,
                  timingIndex: timingIndexes["Raster"]!,
                  color: AppColors.yellow,
                ),
                TimingDetails(
                  timingsType: "Build",
                  timings: _buildTimings,
                  timingIndex: timingIndexes["Build"]!,
                  color: AppColors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final rasterTime =
        _rasterTimings[(timingIndexes['Raster']! - 1) % TIMINGS_SIZE];
    final buildTime =
        _buildTimings[(timingIndexes['Build']! - 1) % TIMINGS_SIZE];

    final frameTime = rasterTime + buildTime;

    final compactChild = Container(
      width: 48,
      decoration: BoxDecoration(
        color: AppColors.containerLow.withAlpha(128),
        borderRadius: .circular(4),
      ),
      margin: const .all(4),
      padding: const .all(4),
      child: TweenAnimationBuilder(
        duration: Durations.long2,
        curve: Curves.fastOutSlowIn,
        tween: Tween(end: 1000 / max(1, frameTime)),
        builder: (_, t, _) => Text(
          "${t.round()} fps",
          style: const TextStyle(fontSize: 8, height: 1),
        ),
      ),
    );

    return Material(
      type: MaterialType.transparency,
      child: IgnorePointer(
        child: Align(
          alignment: widget.alignment,
          child: widget.compact ? compactChild : expandedChild,
        ),
      ),
    );
  }
}

class TimingDetails {
  TimingDetails({
    required this.timingsType,
    required this.timings,
    required this.timingIndex,
    this.timingMaxTime = 20.0,
    this.color = AppColors.containerHigh,
  });

  final String timingsType;
  final Float32List timings;
  final int timingIndex;
  final double timingMaxTime;
  final Color color;
}

class FrameVisualizer extends StatelessWidget {
  const FrameVisualizer({
    super.key,
    required this.timingsType,
    required this.details,
  });

  final String timingsType;
  final List<TimingDetails> details;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 2,
      children: [
        RotatedBox(
          quarterTurns: -1,
          child: Text(
            timingsType,
            style: const TextStyle(fontSize: 6, fontWeight: .bold, height: 1),
          ),
        ),
        Container(
          clipBehavior: .antiAlias,
          width: 32,
          decoration: BoxDecoration(
            borderRadius: .circular(4),
            color: AppColors.containerLow.withAlpha(128),
          ),
        ),
        //
        Expanded(
          child: Container(
            clipBehavior: .antiAlias,
            decoration: BoxDecoration(
              borderRadius: .circular(4),
              color: AppColors.containerLow.withAlpha(128),
            ),
            child: Stack(
              children: [
                for (final detail in details)
                  CustomPaint(
                    painter: TimingsGraph(
                      timings: detail.timings,
                      timingIndex: detail.timingIndex,
                      timingMaxTime: detail.timingMaxTime,
                      color: detail.color,
                    ),
                    child: const Center(),
                  ),

                Padding(
                  padding: const .all(2),
                  child: Row(
                    mainAxisSize: .min,
                    children: [
                      for (final detail in details) ...[
                        Text(
                          detail.timingsType,
                          style: TextStyle(
                            color: detail.color,
                            fontWeight: .bold,
                            fontSize: 6,
                            height: 1,
                          ),
                        ),
                        Container(
                          width: 32,
                          margin: const .only(left: 2),
                          child: Text(
                            "${detail.timings[(detail.timingIndex - 1) % TIMINGS_SIZE].toStringAsFixed(2)} ms",
                            style: const TextStyle(
                              fontWeight: .bold,
                              fontSize: 6,
                              height: 1,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class TimingsGraph extends CustomPainter {
  TimingsGraph({
    super.repaint,
    required this.timings,
    required this.timingIndex,
    this.timingMaxTime = 20,
    this.color = AppColors.containerHigh,
  });

  final int timingIndex;
  final Float32List timings;
  final double timingMaxTime;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = color.withAlpha(64)
      ..style = .fill;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..strokeJoin = .round
      ..strokeCap = .round
      ..style = .stroke;

    final timingPaint = Paint()
      ..color = Color.lerp(color, Colors.black, 0.25)!
      ..strokeWidth = 1;

    final bgPath = Path();
    final linePath = Path();

    final double stepX = size.width / TIMINGS_SIZE;
    final tX = ((timingIndex - 1) % TIMINGS_SIZE) * stepX;

    for (int i = 1; i < TIMINGS_SIZE; i += 2) {
      final x1 = (i - 1) * stepX;
      final x2 = i * stepX;

      final y1 =
          size.height *
          (1 - (min(timingMaxTime, timings[i - 1])) / timingMaxTime);
      final y2 =
          size.height * (1 - (min(timingMaxTime, timings[i])) / timingMaxTime);

      // Start point
      if (i - 1 == 0) {
        linePath.moveTo(x1, y1);
        bgPath
          ..moveTo(x1, size.height)
          ..lineTo(x1, y1);
      }

      // Path
      linePath.quadraticBezierTo(x1, y1, x2, y2);
      bgPath.quadraticBezierTo(x1, y1, x2, y2);

      // End point
      if (i == TIMINGS_SIZE - 1) {
        linePath.quadraticBezierTo(x2, y2, size.width, y2);
        bgPath
          ..quadraticBezierTo(x2, y2, size.width, y2)
          ..lineTo(size.width, size.height);
      }
    }

    canvas.drawPath(bgPath, bgPaint);
    canvas.drawPath(linePath, linePaint);

    // Draw a line at the current timing index
    canvas.drawLine(Offset(tX, 0), Offset(tX, size.height), timingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FrameStats extends ConsumerStatefulWidget {
  const FrameStats({super.key, this.alignment = .centerLeft});
  final AlignmentGeometry alignment;

  @override
  ConsumerState<FrameStats> createState() => _FrameStatsState();
}

class _FrameStatsState extends ConsumerState<FrameStats> {
  double _avgInputInm = 0, _avgInputDel = 0, _avgBuild = 0, _avgRaster = 0;

  double get displayRate => View.of(context).display.refreshRate;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => SchedulerBinding.instance.addTimingsCallback(_addTimings),
    );

    globalRef.read(inputProvider.notifier).addTimingsHandler(_addInputTimings);

    super.initState();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_addTimings);
    globalRef
        .read(inputProvider.notifier)
        .removeTimingsHandler(_addInputTimings);

    super.dispose();
  }

  void _addInputTimings(InputTimings timings) {
    final durDel = (timings.delayedEventsDuration.firstOrNull ?? .zero);

    _avgInputDel = durDel.inMicroseconds / 1000;

    final durInm = (timings.immediateEventsDuration.firstOrNull ?? .zero);

    _avgInputInm = durInm.inMicroseconds / 1000;

    if (mounted) setState(() {});
  }

  void _addTimings(List<FrameTiming> timings) {
    final timing = timings.firstOrNull;

    _avgBuild = (timing?.buildDuration.inMicroseconds ?? 0) / 1000;
    _avgRaster = (timing?.rasterDuration.inMicroseconds ?? 0) / 1000;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 300,
            height: 150,
            margin: const .all(4),
            child: Column(
              crossAxisAlignment: .stretch,
              mainAxisSize: .min,
              spacing: 2,
              children: [
                Expanded(
                  child: Row(
                    spacing: 2,
                    children: [
                      const RotatedBox(
                        quarterTurns: -1,
                        child: Text("Input", style: TextStyle(fontSize: 8)),
                      ),
                      Container(
                        width: 32,
                        decoration: BoxDecoration(
                          borderRadius: .circular(4),
                          color: AppColors.containerLow.withAlpha(128),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: .circular(4),
                            color: AppColors.containerLow.withAlpha(128),
                          ),
                          child: Stack(
                            fit: .expand,
                            children: [
                              Column(
                                crossAxisAlignment: .end,
                                mainAxisAlignment: .end,
                                mainAxisSize: .min,
                                children: [
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(end: _avgInputDel),
                                    duration: Durations.long1,
                                    builder: (_, t, _) {
                                      return Text(
                                        "${t.toStringAsFixed(2)} ms",
                                        style: const TextStyle(fontSize: 8),
                                      );
                                    },
                                  ),
                                  TweenAnimationBuilder(
                                    tween: Tween<double>(end: _avgInputInm),
                                    duration: Durations.long1,
                                    builder: (_, t, _) {
                                      return Text(
                                        "${t.toStringAsFixed(2)} ms",
                                        style: const TextStyle(fontSize: 8),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    spacing: 2,
                    children: [
                      const RotatedBox(
                        quarterTurns: -1,
                        child: Text("Audio", style: TextStyle(fontSize: 8)),
                      ),
                      Container(
                        width: 32,
                        decoration: BoxDecoration(
                          borderRadius: .circular(4),
                          color: AppColors.containerLow.withAlpha(128),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: .circular(4),
                            color: AppColors.containerLow.withAlpha(128),
                          ),
                          child: Stack(
                            fit: .expand,
                            children: [
                              Align(
                                alignment: .bottomRight,
                                child: TweenAnimationBuilder(
                                  tween: Tween<double>(end: 0),
                                  duration: Durations.long1,
                                  builder: (_, t, _) {
                                    return Text(
                                      "${t.toStringAsFixed(2)} ms",
                                      style: const TextStyle(fontSize: 8),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    spacing: 2,
                    children: [
                      const RotatedBox(
                        quarterTurns: -1,
                        child: Text("Raster", style: TextStyle(fontSize: 8)),
                      ),
                      Container(
                        width: 32,
                        decoration: BoxDecoration(
                          borderRadius: .circular(4),
                          color: AppColors.containerLow.withAlpha(128),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: .circular(4),
                            color: AppColors.containerLow.withAlpha(128),
                          ),
                          child: Stack(
                            fit: .expand,
                            children: [
                              Align(
                                alignment: .bottomRight,
                                child: TweenAnimationBuilder(
                                  tween: Tween<double>(end: _avgRaster),
                                  duration: Durations.long1,
                                  builder: (_, t, _) {
                                    return Text(
                                      "${t.toStringAsFixed(2)} ms",
                                      style: const TextStyle(fontSize: 8),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    spacing: 2,
                    children: [
                      const RotatedBox(
                        quarterTurns: -1,
                        child: Text("Draw", style: TextStyle(fontSize: 8)),
                      ),
                      Container(
                        width: 32,
                        decoration: BoxDecoration(
                          borderRadius: .circular(4),
                          color: AppColors.containerLow.withAlpha(128),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: .circular(4),
                            color: AppColors.containerLow.withAlpha(128),
                          ),
                          child: Stack(
                            fit: .expand,
                            children: [
                              Align(
                                alignment: .bottomRight,
                                child: TweenAnimationBuilder(
                                  tween: Tween<double>(end: _avgBuild),
                                  duration: Durations.long1,
                                  builder: (_, t, _) {
                                    return Text(
                                      "${t.toStringAsFixed(2)} ms",
                                      style: const TextStyle(fontSize: 8),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ) /* TweenAnimationBuilder(
          duration: kDebugMode ? Durations.short2 : Durations.extralong4,
          curve: Curves.linearToEaseOut,
          tween: Tween(end: 1000 / _avgTotal),
          builder: (_, t, _) => Container(
            padding: const .all(4),
            margin: const .all(4),
            width: 28,
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: .circular(4),
            ),
            child: Text(
              "${t.toStringAsFixed(1)}\nFPS",
              textAlign: .end,
              style: TextStyle(
                fontSize: 6,
                fontFamily: "Torus",
                fontWeight: .w600,
                color: Color.lerp(Colors.red, Colors.green, t / displayRate),
                height: 1,
              ),
            ),
          ),
        ), */,
      ),
    );
  }
}

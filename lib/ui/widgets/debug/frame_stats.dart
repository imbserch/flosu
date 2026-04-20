import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FrameStats extends StatefulWidget {
  const FrameStats({super.key, this.alignment = .centerLeft});
  final AlignmentGeometry alignment;

  @override
  State<FrameStats> createState() => _FrameStatsState();
}

class _FrameStatsState extends State<FrameStats> {
  double /* _minTotal = 1000, */ _avgTotal = 1000 /* , _maxTotal = 1000 */;

  double get displayRate => View.of(context).display.refreshRate;

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => SchedulerBinding.instance.addTimingsCallback(_addTimings),
    );

    super.initState();
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_addTimings);
    super.dispose();
  }

  void _addTimings(List<FrameTiming> timings) {
    if (timings.isNotEmpty) {
      final total = timings.map((t) => t.totalSpan.inMicroseconds);

      // _minTotal = total.min / 1000;
      _avgTotal = total.average / 1000;
      // _maxTotal = total.max / 1000;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: IgnorePointer(
        child: TweenAnimationBuilder(
          duration: Durations.extralong4,
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
                fontFamily: "Consolas",
                fontWeight: .w900,
                color: Color.lerp(Colors.red, Colors.green, t / displayRate),
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

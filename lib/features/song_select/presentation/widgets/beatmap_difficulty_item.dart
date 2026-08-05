import 'package:flosu/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// A widget that displays the difficulty information of a beatmap like
/// AR, CS, OD, HP, nCircles, nSliders, nSpinners
class BeatmapDifficultyItem extends StatelessWidget {
  const BeatmapDifficultyItem({
    super.key,
    required this.label,
    required this.max,
    required this.value,
    this.width = 48,
    this.color,
  });

  final String label;
  final num max;
  final num value;
  final double width;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TweenAnimationBuilder(
        tween: Tween<double>(end: value.toDouble()),
        curve: Curves.fastOutSlowIn,
        duration: Durations.medium1,
        builder: (_, t, _) => Column(
          crossAxisAlignment: .stretch,
          children: [
            LinearProgressIndicator(
              value: t / max,
              color: color ?? AppColors.yellow,
              backgroundColor: AppColors.containerLowest,
              borderRadius: .circular(2),
              minHeight: 1,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 6, height: 1, fontWeight: .bold),
            ),
            Text(
              "${value is int ? t.round() : t.toStringAsFixed(1)}",
              style: const TextStyle(fontSize: 7.5, height: 1),
            ),
          ],
        ),
      ),
    );
  }
}

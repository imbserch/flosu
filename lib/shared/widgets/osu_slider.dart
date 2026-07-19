import 'package:flutter/material.dart';
import 'package:flosu/core/theme/app_colors.dart';

class OsuSlider extends StatefulWidget {
  const OsuSlider({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
  });

  final double min, max, value;
  final void Function(double value) onChanged;
  final VoidCallback? onChangeEnd;

  @override
  State<OsuSlider> createState() => _OsuSliderState();
}

class _OsuSliderState extends State<OsuSlider> {
  @override
  Widget build(BuildContext context) {
    final difference = widget.max - widget.min;
    final t = (widget.value - widget.min) / difference;

    return LayoutBuilder(
      builder: (_, cons) => GestureDetector(
        onTapDown: (p) {
          final pos = (p.localPosition.dx / cons.maxWidth).clamp(0.0, 1.0);

          final value = (pos * difference) + widget.min;

          widget.onChanged(value);
        },
        onHorizontalDragUpdate: (p) {
          final pos = (p.localPosition.dx / cons.maxWidth).clamp(0.0, 1.0);

          final value = (pos * difference) + widget.min;

          widget.onChanged(value);
        },
        onHorizontalDragEnd: (_) => widget.onChangeEnd?.call(),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.container,
            borderRadius: .circular(4),
          ),
          height: 24,
          clipBehavior: .antiAliasWithSaveLayer,
          child: Stack(
            alignment: .centerLeft,
            children: [
              AnimatedContainer(
                duration: Durations.short2,
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: AppColors.purple.withAlpha(140),
                ),
                width: (cons.maxWidth * t) + ((1 - (2 * t)) * 3),
              ),
              AnimatedAlign(
                duration: Durations.short2,
                curve: Curves.easeOutCubic,
                alignment: Alignment(-1 + (t * 2), .5),
                child: IgnorePointer(
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: .circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

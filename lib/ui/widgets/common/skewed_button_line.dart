import 'package:flutter/material.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';

class SkewedButtonLine extends StatelessWidget {
  const SkewedButtonLine({
    super.key,
    required this.icon,
    required this.label,
    this.color = Colors.white,
    this.offset = .zero,
    this.onTap,
  });

  final Widget icon;
  final Widget label;
  final Color color;

  final Offset offset;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SkewedBox(
      width: 64,
      height: 36,
      offset: offset,
      heroTag: color,
      onTap: onTap,
      margin: const .only(bottom: 4),
      padding: const .all(2),
      decoration: const BoxDecoration(color: AppColors.containerHigh),
      child: Stack(
        alignment: .bottomCenter,
        children: [
          Center(
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .center,
              spacing: 4,
              children: [
                IconTheme(
                  data: IconThemeData(size: 8, color: color),
                  child: icon,
                ),
                DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 7, height: 1),
                  child: label,
                ),
                const SizedBox(height: 1),
              ],
            ),
          ),
          Container(
            height: 1,
            width: 56,
            margin: const .only(right: 8),
            decoration: BoxDecoration(color: color, borderRadius: .circular(1)),
          ),
        ],
      ),
    );
  }
}

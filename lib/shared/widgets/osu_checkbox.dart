import 'package:flutter/material.dart';
import 'package:flosu/core/theme/app_colors.dart';

class OsuCheckbox extends StatelessWidget {
  const OsuCheckbox({super.key, required this.value, required this.onChange});
  final bool value;
  final void Function(bool value) onChange;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.none,
      onTap: () => onChange(!value),
      child: AnimatedContainer(
        duration: Durations.short2,
        curve: Curves.easeOutCubic,
        height: 8,
        width: 28,
        decoration: BoxDecoration(
          color: value ? AppColors.purple : null,
          border: .all(color: AppColors.purple),
          borderRadius: .circular(8),
        ),
      ),
    );
  }
}

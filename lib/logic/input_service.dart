import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/providers/tooltip_service.dart';

class GlobalTooltip extends ConsumerStatefulWidget {
  const GlobalTooltip({super.key});

  @override
  ConsumerState<GlobalTooltip> createState() => _GlobalTooltipState();
}

class _GlobalTooltipState extends ConsumerState<GlobalTooltip> {
  //TODO: REIMPLEMENT POINTER EVENTS HANDLER

  @override
  Widget build(BuildContext context) {
    final tooltip = ref.watch(tooltipService);

    if (tooltip.content == null) return const SizedBox.shrink();

    return AnimatedPositioned(
      left: 0 + 12,
      top: 0 + 12,
      duration: Durations.short1,
      curve: Curves.fastOutSlowIn,
      child: AnimatedOpacity(
        opacity: tooltip.hidden ? 0 : 1,
        duration: Durations.short4,
        curve: Curves.easeIn,
        child: Material(
          color: AppColors.background,
          elevation: 8,
          shadowColor: Colors.black87,
          shape: RoundedRectangleBorder(borderRadius: .circular(4)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Padding(
              padding: const .all(4),
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 8, fontFamily: "Torus"),
                child: IntrinsicWidth(child: tooltip.content!),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

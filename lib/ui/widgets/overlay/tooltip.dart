import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flutter/material.dart' hide Tooltip;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/tooltip.dart';

class Tooltip extends ConsumerStatefulWidget {
  const Tooltip({super.key});

  @override
  ConsumerState<Tooltip> createState() => _TooltipState();
}

class _TooltipState extends ConsumerState<Tooltip> {
  Offset _lastOffset = .zero;

  @override
  initState() {
    ref.read(inputProvider.notifier).addDelayedHandler(_onInput);
    super.initState();
  }

  void _onInput(InputEvents event) {
    if (event.pointer.isEmpty) return;

    _lastOffset = event.pointer.last.position;
    if (mounted) setState(() {});
  }

  @override
  dispose() {
    ref.read(inputProvider.notifier).removeDelayedHandler(_onInput);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tooltip = ref.watch(tooltipProvider);

    if (tooltip.content == null) return const SizedBox.shrink();

    return AnimatedPositioned(
      left: _lastOffset.dx + 12,
      top: _lastOffset.dy + 12,
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

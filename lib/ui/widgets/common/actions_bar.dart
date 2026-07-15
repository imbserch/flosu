import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/ui/widgets/common/skewed_box.dart';
import 'package:flutter/material.dart';

class ActionsBar extends StatelessWidget {
  const ActionsBar({
    super.key,
    this.actions = const [],
    this.actionsPadding = EdgeInsets.zero,
    this.actionsSpacing = 12,
    this.trailing,
    required this.onBack,
  });

  final List<Widget> actions;
  final EdgeInsetsGeometry actionsPadding;
  final double actionsSpacing;
  final Widget? trailing;
  final void Function() onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .bottomCenter,
      children: [
        Container(color: AppColors.background, height: 32),
        Row(
          crossAxisAlignment: .end,
          children: [
            SkewedBox(
              heroTag: "Back button",
              decoration: BoxDecoration(
                borderRadius: .circular(4),
                color: AppColors.fucshia,
              ),
              useGradientBorder: true,
              margin: const .fromLTRB(18, 0, 0, 12),
              padding: const .symmetric(vertical: 9, horizontal: 33),
              onTap: onBack,
              child: const Row(
                spacing: 4,
                children: [
                  Icon(Icons.arrow_back_ios_new, size: 8),
                  Text("Back", style: TextStyle(fontSize: 8)),
                ],
              ),
            ),
            if (actions.isNotEmpty)
              Expanded(
                child: Padding(
                  padding: actionsPadding,
                  child: Row(
                    spacing: actionsSpacing,
                    crossAxisAlignment: .end,
                    children: actions,
                  ),
                ),
              )
            else
              const Spacer(),
            ?trailing,
          ],
        ),
      ],
    );
  }
}

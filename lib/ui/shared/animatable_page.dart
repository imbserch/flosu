import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/extensions/ui.dart';

abstract class AnimatablePage extends ConsumerStatefulWidget {
  const AnimatablePage({super.key, required this.uri});

  final Uri uri;
}

abstract class AnimatablePageState<T extends AnimatablePage>
    extends ConsumerState<T> {
  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) {
      return buildPage(context, 1.0).hiddenCursor;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([route.animation, route.secondaryAnimation]),
      builder: (context, child) {
        final anim = route.animation!;
        final revAnim = route.secondaryAnimation!;

        final segments = widget.uri.pathSegments.length;
        final targetSegments = GoRouterState.of(context).uri.pathSegments.length;

        double t;

        if (segments >= 2) {
          t = Curves.easeOut.transform(anim.value);
        } else {
          final bool isGoingDeeper = targetSegments > segments;

          final bool isReturningFromDeep =
              revAnim.status == AnimationStatus.reverse &&
              targetSegments == segments;

          final double effectiveRevAnim = (isGoingDeeper || isReturningFromDeep)
              ? 0.0
              : revAnim.value;

          final animVal = anim.value * (1.0 - effectiveRevAnim);

          t = Curves.easeOut.transform(animVal);
        }

        return Opacity(
          opacity: t,
          child: buildPage(context, t),
        );
      },
    ).hiddenCursor;
  }

  Widget buildPage(BuildContext context, double t);
}

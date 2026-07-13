import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flutter/material.dart' hide PointerEvent;
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/core/extensions/ui.dart';

/// Base class for all page widgets that support transition animations.
///
/// Ensures page entry and exit animations are coordinated based on routing paths.
abstract class AnimatablePage extends ConsumerStatefulWidget {
  const AnimatablePage({super.key, required this.uri});

  final Uri uri;
}

/// The state implementation for animatable pages.
///
/// Drives the route animations and wraps the built page in standard visibility helpers.
abstract class AnimatablePageState<T extends AnimatablePage>
    extends ConsumerState<T> {
  @override
  void initState() {
    ref.read(inputProvider.notifier).addInmediateHandler(onInput);
    super.initState();
  }

  @override
  void dispose() {
    globalRef.read(inputProvider.notifier).removeInmediateHandler(onInput);
    super.dispose();
  }

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
        final targetSegments = GoRouterState.of(
          context,
        ).uri.pathSegments.length;

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

        return Opacity(opacity: t, child: buildPage(context, t));
      },
    ).hiddenCursor;
  }

  Widget buildPage(BuildContext context, double t);
  bool onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) => false;
}

import 'package:flutter/material.dart';
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
  /// Indicates whether the page is currently transitioning into view (appearing).
  bool get isAppearing {
    final route = ModalRoute.of(context);
    if (route == null) return false;
    final anim = route.animation;
    final revAnim = route.secondaryAnimation;
    return anim?.status == AnimationStatus.forward ||
        revAnim?.status == AnimationStatus.reverse;
  }

  /// Indicates whether the page is currently transitioning out of view (disappearing).
  bool get isDisappearing {
    final route = ModalRoute.of(context);
    if (route == null) return false;
    final anim = route.animation;
    final revAnim = route.secondaryAnimation;
    return anim?.status == AnimationStatus.reverse ||
        revAnim?.status == AnimationStatus.forward;
  }

  /// Returns the current animation progress value `t` (between 0.0 and 1.0).
  double get pageProgress {
    final route = ModalRoute.of(context);
    if (route == null) return 1.0;

    final anim = route.animation;
    final revAnim = route.secondaryAnimation;
    if (anim == null || revAnim == null) return 1.0;

    final segments = widget.uri.pathSegments.length;
    final targetSegments = GoRouterState.of(context).uri.pathSegments.length;

    if (segments >= 2) {
      return Curves.easeOut.transform(anim.value);
    } else {
      final bool isGoingDeeper = targetSegments > segments;

      final bool isReturningFromDeep =
          revAnim.status == AnimationStatus.reverse &&
          targetSegments == segments;

      final double effectiveRevAnim = (isGoingDeeper || isReturningFromDeep)
          ? 0.0
          : revAnim.value;

      final animVal = anim.value * (1.0 - effectiveRevAnim);

      return Curves.easeOut.transform(animVal);
    }
  }

  /// Alias for [pageProgress].
  double get t => pageProgress;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route == null) {
      return buildPage(context).hiddenCursor;
    }

    return AnimatedBuilder(
      animation: Listenable.merge([route.animation, route.secondaryAnimation]),
      builder: (context, child) {
        final progress = pageProgress;
        return Opacity(opacity: progress, child: buildPage(context));
      },
    ).hiddenCursor;
  }

  Widget buildPage(BuildContext context);
}

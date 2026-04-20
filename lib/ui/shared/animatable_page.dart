import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions.dart';
import 'package:flosu/ui/shared/transition_scope.dart';

abstract class AnimatablePage extends ConsumerStatefulWidget {
  const AnimatablePage({super.key, required this.uri});

  final Uri uri;
}

abstract class AnimatablePageState<T extends AnimatablePage>
    extends ConsumerState<T> {
  @override
  Widget build(BuildContext context) {
    final progress = TransitionScope.of(context);

    return ValueListenableBuilder<double>(
      valueListenable: progress,
      builder: (context, t, child) =>
          Opacity(opacity: progress.value, child: buildPage(context, t)),
    ).hiddenCursor;
  }

  Widget buildPage(BuildContext context, double t);
}

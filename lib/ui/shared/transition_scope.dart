import 'package:flutter/material.dart';

class TransitionScope extends InheritedWidget {
  const TransitionScope({
    super.key,
    required this.progress,
    required super.child,
  });

  final ValueNotifier<double> progress;

  static ValueNotifier<double> of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TransitionScope>()!.progress;

  @override
  bool updateShouldNotify(TransitionScope oldWidget) => false; // El valor cambia internamente
}

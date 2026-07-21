import 'package:flosu/shared/input/input.dart';
import 'package:flosu/shared/input/input_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A mixin for handling keyboard input.
///
/// For widgets that only need to handle mouse input, use [MouseHandler].
/// For widgets that need to handle both keyboard and mouse input, use [InputHandler].
mixin KeyboardHandler<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final InputHandlerType _type = InputHandlerType.keyboard;
  late final _inputProvider = ref.read(inputProvider);

  @override
  void initState() {
    _inputProvider.addHandler(_type, input);
    super.initState();
  }

  @override
  void dispose() {
    _inputProvider.removeHandler(_type, input);
    super.dispose();
  }

  bool input();

  InputKeyEvent get keyboard => ref.read(inputProvider).keyboard;
}

/// A mixin for handling mouse input.
///
/// For widgets that only need to handle keyboard input, use [KeyboardHandler].
/// For widgets that need to handle both keyboard and mouse input, use [InputHandler].
mixin MouseHandler<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final InputHandlerType _type = InputHandlerType.mouse;
  late final _inputProvider = ref.read(inputProvider);

  @override
  void initState() {
    _inputProvider.addHandler(_type, input);
    super.initState();
  }

  @override
  void dispose() {
    _inputProvider.removeHandler(_type, input);
    super.dispose();
  }

  bool input();

  InputMouseEvent get mouse => ref.read(inputProvider).mouse;
}

/// A mixin for handling both keyboard and mouse input.
///
/// (This is rarely needed, consider using [KeyboardHandler] or [MouseHandler] instead)
mixin InputHandler<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  final InputHandlerType _type = InputHandlerType.all;
  late final _inputProvider = ref.read(inputProvider);

  @override
  void initState() {
    _inputProvider.addHandler(_type, input);
    super.initState();
  }

  @override
  void dispose() {
    _inputProvider.removeHandler(_type, input);
    super.dispose();
  }

  bool input();

  InputKeyEvent get keyboard => ref.read(inputProvider).keyboard;
  InputMouseEvent get mouse => ref.read(inputProvider).mouse;
}

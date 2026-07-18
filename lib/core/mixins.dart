import 'package:collection/collection.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/logic/providers/input.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/models/inputs/inputs.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' hide PointerEvent;
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A mixin that handles keyboard events for a widget.
mixin KeyboardEventHandler<T extends ConsumerStatefulWidget>
    on ConsumerState<T> {
  @override
  void initState() {
    super.initState();
    ref
        .read(inputProvider.notifier)
        .addInmediateHandler(_onInput, keyboardOnly: true);
  }

  @override
  void dispose() {
    globalRef.read(inputProvider.notifier).removeInmediateHandler(_onInput);
    super.dispose();
  }

  /// The handlers for the keyboard events.
  ///
  /// The key of the map is the [KeysState] and the value is the callback to be executed.
  /// The callbacks should return `true` if the event was handled, `false` otherwise.
  Map<KeysState, VoidCallback> get keyHandlers => {};

  bool _onInput(Set<LogicalKeyboardKey> keys, PointerEvent? pointer) {
    final control = keys.pressed(.controlLeft) || keys.pressed(.controlRight);
    final shift = keys.pressed(.shiftLeft) || keys.pressed(.shiftRight);
    final alt = keys.pressed(.altLeft) || keys.pressed(.altRight);

    final Set<LogicalKeyboardKey> metaKeys = {
      .controlLeft,
      .controlRight,
      .shiftLeft,
      .shiftRight,
      .altLeft,
      .altRight,
    };

    final filtered = keys.whereNot(metaKeys.contains).toSet();

    for (final entry in keyHandlers.entries) {
      final handlerState = entry.key;
      final handlerKeys = handlerState.keys;
      final handlerFiltered = handlerKeys.whereNot(metaKeys.contains).toSet();

      final matchesControlKey = handlerState.control == control;
      final matchesAltKey = handlerState.alt == alt;
      final matchesShiftKey = handlerState.shift == shift;

      final matchesMeta = matchesControlKey && matchesAltKey && matchesShiftKey;
      final matchesKeys = setEquals(handlerFiltered, filtered);

      if (matchesMeta && matchesKeys) {
        final handlerCallback = entry.value;
        handlerCallback();
        return true;
      }
    }

    return false;
  }
}

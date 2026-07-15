import 'package:flosu/core/enums.dart';
import 'package:flutter/services.dart';
import 'package:flosu/models/mods/base.dart';

/// Extension on a [Set<LogicalKeyboardKey>] for concise key-state queries.
extension KeysExtension on Set<LogicalKeyboardKey> {
  /// Returns `true` if [key] is currently in the pressed set.
  bool pressed(LogicalKeyboardKey key) => contains(key);

  /// Returns `true` if the state of [key] differs from [lastKeys].
  bool changed(LogicalKeyboardKey key, Set<LogicalKeyboardKey> lastKeys) =>
      pressed(key) != lastKeys.pressed(key);

  /// Returns `true` if [key] changed state and is now pressed.
  ///
  /// Use this to detect key-down transitions without firing on repeats.
  bool changedAndPressed(
    LogicalKeyboardKey key,
    Set<LogicalKeyboardKey> lastKeys,
  ) => changed(key, lastKeys) && pressed(key);

  /// Returns `true` if either Control key is currently held.
  bool get isCtrlPressed =>
      pressed(LogicalKeyboardKey.controlLeft) ||
      pressed(LogicalKeyboardKey.controlRight);

  /// Returns `true` if either Alt key is currently held.
  bool get isAltPressed =>
      pressed(LogicalKeyboardKey.altLeft) ||
      pressed(LogicalKeyboardKey.altRight);
}

/// Extension adding an absolute-value helper to [Offset].
extension OffsetExtension on Offset {
  /// Returns an [Offset] with both components made non-negative.
  Offset abs() => Offset(dx.abs(), dy.abs());
}

/// Extension on [Iterable<ConfigurableMod>] for mod-set queries.
extension ConfigurableModFinder on Iterable<ConfigurableMod> {
  /// Returns `true` if a mod with the same data as [mod] is present.
  bool containsMod(Mod mod) => any((m) => m.mod == mod);
}

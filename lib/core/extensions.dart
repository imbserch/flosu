import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flosu/models/mods/base.dart';

/// Utility extension for quick logging and debugging of any object.
extension PrintExtension<T> on T {
  /// Prints the object to the console and returns it, allowing for inline logging.
  T get log {
    // ignore: avoid_print
    print(this);
    return this;
  }

  /// Prints a specific property of the object to the console and returns the original object.
  T logProperty(dynamic Function(T) prop) {
    // ignore: avoid_print
    print(prop(this));
    return this;
  }
}

/// Extension on [BuildContext] to provide shorthand access to common theme and layout properties.
extension BCExtension on BuildContext {
  /// Shorthand for `Theme.of(context)`.
  ThemeData get theme => Theme.of(this);

  /// Shorthand for `Theme.of(context).textTheme`.
  TextTheme get tStyle => theme.textTheme;

  /// Shorthand for `Theme.of(context).colorScheme`.
  ColorScheme get scheme => theme.colorScheme;

  /// Returns the current screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Horizontal scale factor based on the original osu! 640x480 resolution.
  double get scaleX => screenSize.width / 640;

  /// Vertical scale factor based on the original osu! 640x480 resolution.
  double get scaleY => screenSize.height / 480;

  /// The uniform scale factor (minimum of X and Y) to maintain aspect ratio.
  double get scale => scaleX < scaleY ? scaleX : scaleY;

  /// Returns the screen size adjusted by the current scale factor.
  Size get screenScaled => screenSize / scale;
}

/// Extension to format [Duration] into a human-readable string (HH:MM:SS).
extension DurationExtension on Duration {
  String get formatted => "$this".split(".").first;
}

/// Extension to format [DateTime] into a time string (HH:MM:SS).
extension DateTimeExtension on DateTime {
  String get formatted => "$this".split(" ").last.substring(0).split(".").first;
}

/// Extension to format numbers to a fixed decimal string.
extension DoubleExtensions on num {
  String get format => toStringAsFixed(2);
}

/// Extension for [LogicalKeyboardKey] sets to simplify key state checks.
extension KeysExtension on Set<LogicalKeyboardKey> {
  /// Checks if a key with the given label is currently in the set.
  bool pressed(String key) => any((st) => st.keyLabel == key);

  ///Checks if some key has changed since last keys event
  bool changed(String key, Set<LogicalKeyboardKey> lastKeys) =>
      pressed(key) != lastKeys.pressed(key);

  ///Checks if some key, after updated, is pressed
  bool changedAndPressed(String key, Set<LogicalKeyboardKey> lastKeys) =>
      changed(key, lastKeys) && pressed(key);

  bool get isCtrlPressed => pressed("Control Left") || pressed("Control Right");
  bool get isAltPressed => pressed("Alt Left") || pressed("Alt Right");
}

extension OffsetExtension on Offset {
  Offset abs() => Offset(dx.abs(), dy.abs());
}

/// Helper to find mods within a collection of [ConfigurableMod].
extension ConfigurableModFinder on Iterable<ConfigurableMod> {
  /// Returns true if a mod with the same acronym exists in the collection.
  bool containsMod(ConfigurableMod mod) => any((m) => m.acronym == mod.acronym);
}

extension ClickableCursor on Widget {
  Widget get hiddenCursor {
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      opaque: false,
      child: this,
    );
  }
}

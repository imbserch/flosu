import 'package:collection/collection.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flosu/models/mods/base.dart';

/// Utility extension for quick logging and debugging of any object.
extension PrintExtension<T> on T {
  /// Prints the object to the console using [print] and returns it.
  ///
  /// Only produces output in [kDebugMode], making it safe to leave call sites
  /// in production code without performance impact.
  T get log {
    if (kDebugMode) {
      // ignore: avoid_print
      print(this);
    }
    return this;
  }

  /// Prints a specific property of the object and returns the original value.
  ///
  /// Useful for logging inside method chains without breaking them.
  T logProperty(dynamic Function(T) prop) {
    if (kDebugMode) {
      // ignore: avoid_print
      print(prop(this));
    }
    return this;
  }
}

/// Extension on [BuildContext] to provide shorthand access to common
/// theme and layout properties.
extension BCExtension on BuildContext {
  /// Shorthand for `Theme.of(context)`.
  ThemeData get theme => Theme.of(this);

  /// Shorthand for `Theme.of(context).textTheme`.
  TextTheme get tStyle => theme.textTheme;

  /// Shorthand for `Theme.of(context).colorScheme`.
  ColorScheme get scheme => theme.colorScheme;

  /// The current physical screen size in logical pixels.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Horizontal scale factor relative to the base osu! resolution (640 px wide).
  double get scaleX => screenSize.width / 640;

  /// Vertical scale factor relative to the base osu! resolution (480 px tall).
  double get scaleY => screenSize.height / 480;

  /// Uniform scale factor — the minimum of [scaleX] and [scaleY].
  ///
  /// Preserves the 4:3 aspect ratio when the screen does not match exactly.
  double get scale => scaleX < scaleY ? scaleX : scaleY;

  /// The device pixel ratio reported by the OS.
  double get pixelRatio => MediaQuery.devicePixelRatioOf(this);

  /// The screen size divided by [scale] and [pixelRatio].
  ///
  /// Gives the effective logical size of the 640×480 viewport as seen by
  /// widgets placed in the root [Reescalable] transform.
  Size get screenScaled => screenSize / scale / pixelRatio;
}

/// Extension to format a [Duration] as a human-readable HH:MM:SS string.
extension DurationExtension on Duration {
  String get formatted => "$this".split(".").first;
}

/// Extension to format a [DateTime] as a HH:MM:SS time string.
extension DateTimeExtension on DateTime {
  String get formatted => "$this".split(" ").last.substring(0).split(".").first;
}

/// Extension to format numbers with exactly two decimal places.
extension DoubleExtensions on num {
  String get format => toStringAsFixed(2);
}

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

/// Extension on [Iterable<Beatmap>] for grouping beatmaps by song title.
extension BeatmapGroups on Iterable<Beatmap> {
  /// Groups beatmaps into lists sharing the same [BeatmapInfo.title].
  List<List<Beatmap>> get asGroups =>
      groupListsBy((beatmap) => beatmap.info.title).values.toList();
}

/// Extension on [Iterable<ConfigurableMod>] for mod-set queries.
extension ConfigurableModFinder on Iterable<ConfigurableMod> {
  /// Returns `true` if a mod with the same acronym as [mod] is present.
  bool containsMod(ConfigurableMod mod) => any((m) => m.acronym == mod.acronym);
}

/// Extension on [Widget] that wraps it in a [MouseRegion] hiding the cursor.
extension ClickableCursor on Widget {
  /// Returns this widget wrapped in a transparent [MouseRegion] that forces
  /// the cursor to be invisible, used to let the custom cursor widget take over.
  Widget get hiddenCursor {
    return MouseRegion(
      cursor: SystemMouseCursors.none,
      opaque: false,
      child: this,
    );
  }
}

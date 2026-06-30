import 'package:flutter/material.dart';

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

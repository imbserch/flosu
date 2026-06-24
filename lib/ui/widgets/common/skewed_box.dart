import 'dart:math';

import 'package:flutter/material.dart';

class SkewedBox extends StatelessWidget {
  const SkewedBox({
    super.key,
    this.heroTag,
    this.inverted = false,
    this.useGradientBorder = false,
    this.gradientBorderWidth,
    this.height,
    this.width,
    this.skew = 3 / 16,
    this.opacity = 1,
    this.offset = Offset.zero,
    this.margin,
    this.padding,
    this.constraints,
    this.onTap,
    this.decoration,
    this.animDuration,
    this.child,
  }) : isContainer = false,
       ignoreParenSkew = false;

  const SkewedBox.ignoreParentSkew({
    super.key,
    this.heroTag,
    this.inverted = false,
    this.useGradientBorder = false,
    this.gradientBorderWidth,
    this.height,
    this.width,
    this.skew = 3 / 16,
    this.offset = Offset.zero,
    this.margin,
    this.padding,
    this.constraints,
    this.onTap,
    this.decoration,
    this.animDuration,
    this.child,
  }) : isContainer = false,
       opacity = 1,
       ignoreParenSkew = true;

  const SkewedBox.container({
    super.key,
    this.inverted = false,
    this.skew = 3 / 16,
    this.offset = Offset.zero,
    this.child,
  }) : useGradientBorder = false,
       gradientBorderWidth = null,
       isContainer = true,
       opacity = 1,
       margin = .zero,
       padding = .zero,
       height = null,
       width = null,
       decoration = null,
       constraints = null,
       onTap = null,
       animDuration = null,
       ignoreParenSkew = false,
       heroTag = null;
  final bool inverted;
  final bool useGradientBorder;

  final double? height;
  final double? width;

  final double skew;
  final double opacity;
  final double? gradientBorderWidth;

  final Offset offset;

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  final BoxConstraints? constraints;

  final VoidCallback? onTap;
  final BoxDecoration? decoration;

  final Duration? animDuration;

  final Widget? child;
  final Object? heroTag;

  final bool isContainer;
  final bool ignoreParenSkew;

  static Color contrastColor(Color color) {
    final convColor = HSVColor.fromColor(color);

    return convColor.value >= .5
        ? Color.lerp(color, Colors.black, 2 / 3)!
        : Color.lerp(color, Colors.white, 2 / 3)!;
  }

  @override
  Widget build(BuildContext context) {
    final resSkew = skew * (inverted ? -1 : 1);

    Widget result = const SizedBox.shrink();

    if (opacity == 0) return result;

    if (isContainer) {
      result = Transform(
        alignment: FractionalOffset.center,
        transform: .skewX(-resSkew),
        child: Transform.translate(key: key, offset: offset, child: child),
      );
    } else {
      result = Transform(
        alignment: FractionalOffset.center,
        transform: .skewX(resSkew),
        child: Padding(key: key, padding: padding ?? .zero, child: child),
      );

      if (onTap != null) {
        result = Material(
          type: .transparency,
          child: InkWell(
            onTap: onTap,
            mouseCursor: SystemMouseCursors.none,
            borderRadius: .circular(4),
            child: result,
          ),
        );
      }

      result = Transform.translate(
        offset: offset,
        child: AnimatedContainer(
          width: width,
          height: height,
          constraints: constraints,
          curve: Curves.easeOut,
          duration: animDuration ?? Durations.medium1,
          margin: margin,
          clipBehavior: useGradientBorder ? .antiAlias : .none,
          decoration: useGradientBorder
              ? BoxDecoration(
                  border: useGradientBorder ? null : decoration?.border,
                  color: decoration?.color,
                  borderRadius: decoration?.borderRadius ?? .circular(4),
                  gradient: decoration?.gradient,
                )
              : decoration?.copyWith(
                  borderRadius: decoration?.borderRadius ?? .circular(4),
                ),
          child: CustomPaint(
            painter: useGradientBorder
                ? SkewedBoxGradientBorderPainter(
                    decoration: decoration,
                    width: gradientBorderWidth ?? 1.0,
                  )
                : null,
            child: result,
          ),
        ),
      );

      if (!ignoreParenSkew) {
        result = Transform(
          alignment: FractionalOffset.center,
          transform: .skewX(-resSkew),
          child: result,
        );
      }

      if (opacity < 1) result = Opacity(opacity: opacity, child: result);
      if (heroTag != null) result = Hero(tag: heroTag!, child: result);
    }

    return result;
  }
}

class SkewedBoxGradientBorderPainter extends CustomPainter {
  SkewedBoxGradientBorderPainter({
    super.repaint,
    required this.decoration,
    required this.width,
  });

  final BoxDecoration? decoration;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final BorderRadius radius = (decoration?.borderRadius ?? .circular(4))
        .resolve(.ltr);

    final rect = Rect.fromLTWH(
      width / 2,
      width / 2,
      size.width - width,
      size.height - width,
    );

    final color = decoration?.color ?? Colors.transparent;

    final border = Paint()
      ..filterQuality = .low
      ..style = .stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        colors: [Color.lerp(color, Colors.white, 1 / 12)!, color],
        stops: [0, 1.1],
        begin: .bottomCenter,
        end: .topCenter,
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        rect,
        topLeft: nonNegative(radius.topLeft),
        topRight: nonNegative(radius.topRight),
        bottomLeft: nonNegative(radius.bottomLeft),
        bottomRight: nonNegative(radius.bottomRight),
      ),
      border,
    );
  }

  Radius nonNegative(Radius radius) {
    // Prevent negative radii when subtracting half the border width.
    final radX = radius.x - (width / 2);
    final radY = radius.y - (width / 2);

    return .elliptical(max(radX, 0), max(radY, 0));
  }

  @override
  bool shouldRepaint(covariant SkewedBoxGradientBorderPainter old) =>
      decoration != old.decoration || width != old.width;
}

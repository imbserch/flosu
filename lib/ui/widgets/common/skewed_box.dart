import 'dart:math';

import 'package:flutter/material.dart';

class SkewedBox extends StatefulWidget {
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
  State<SkewedBox> createState() => _SkewedBoxState();
}

class _SkewedBoxState extends State<SkewedBox> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final resSkew = widget.skew * (widget.inverted ? -1 : 1);

    Widget result = const SizedBox.shrink();

    if (widget.opacity == 0) return result;

    if (widget.isContainer) {
      result = Transform(
        alignment: FractionalOffset.center,
        transform: .skewX(-resSkew),
        child: Transform.translate(
          key: widget.key,
          offset: widget.offset,
          child: widget.child,
        ),
      );
    } else {
      result = Transform(
        alignment: FractionalOffset.center,
        transform: .skewX(resSkew),
        child: Padding(
          key: widget.key,
          padding: widget.padding ?? .zero,
          child: widget.child,
        ),
      );

      if (widget.onTap != null) {
        result = Material(
          type: .transparency,
          child: InkWell(
            onTapDown: widget.onTap != null
                ? (_) {
                    if (mounted) setState(() => _pressed = true);
                  }
                : null,
            onTapUp: widget.onTap != null
                ? (_) {
                    if (mounted) setState(() => _pressed = false);
                  }
                : null,
            onTapCancel: widget.onTap != null
                ? () {
                    if (mounted) setState(() => _pressed = false);
                  }
                : null,
            onTap: widget.onTap,
            mouseCursor: SystemMouseCursors.none,
            borderRadius:
                widget.decoration?.borderRadius?.resolve(.ltr) ?? .circular(4),
            child: result,
          ),
        );
      }

      result = Transform.translate(
        offset: widget.offset,
        child: AnimatedScale(
          scale: _pressed ? .95 : 1,
          duration: Durations.long2,
          curve: Curves.easeOut,
          child: AnimatedContainer(
            width: widget.width,
            height: widget.height,
            constraints: widget.constraints,
            curve: Curves.easeOut,
            duration: widget.animDuration ?? Durations.medium1,
            margin: widget.margin,
            clipBehavior: widget.useGradientBorder ? .antiAlias : .none,
            decoration: widget.useGradientBorder
                ? BoxDecoration(
                    border: widget.useGradientBorder
                        ? null
                        : widget.decoration?.border,
                    color: widget.decoration?.color,
                    borderRadius:
                        widget.decoration?.borderRadius ?? .circular(4),
                    gradient: widget.decoration?.gradient,
                  )
                : widget.decoration?.copyWith(
                    borderRadius:
                        widget.decoration?.borderRadius ?? .circular(4),
                  ),
            child: CustomPaint(
              painter: widget.useGradientBorder
                  ? SkewedBoxGradientBorderPainter(
                      decoration: widget.decoration,
                      width: widget.gradientBorderWidth ?? 1.0,
                    )
                  : null,
              child: result,
            ),
          ),
        ),
      );

      if (!widget.ignoreParenSkew) {
        result = Transform(
          alignment: FractionalOffset.center,
          transform: .skewX(-resSkew),
          child: result,
        );
      }

      if (widget.opacity < 1) {
        result = Opacity(opacity: widget.opacity, child: result);
      }
      if (widget.heroTag != null) {
        result = Hero(tag: widget.heroTag!, child: result);
      }
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
        colors: [Color.lerp(color, Colors.white, 1 / 8)!, color],
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

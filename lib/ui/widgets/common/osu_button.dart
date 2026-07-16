import 'package:flutter/material.dart';

class OsuButton extends StatelessWidget {
  const OsuButton({
    super.key,
    this.onPressed,
    required this.child,
    this.borderRadius,
    this.color = Colors.pink,
    this.useMinimumSize = true,
  }) : icon = null;

  const OsuButton.icon({
    super.key,
    this.onPressed,
    required this.child,
    required this.icon,
    this.borderRadius,
    this.color = Colors.pink,
    this.useMinimumSize = true,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;

  final BorderRadiusGeometry? borderRadius;
  final Color color;

  final bool useMinimumSize;

  @override
  Widget build(BuildContext context) {
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: ButtonStyle(
          mouseCursor: const WidgetStatePropertyAll(SystemMouseCursors.none),
          backgroundColor: WidgetStatePropertyAll(color),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: borderRadius ?? .circular(6)),
          ),
          iconSize: const WidgetStatePropertyAll(12),
          iconColor: const WidgetStatePropertyAll(Colors.white),
          minimumSize: WidgetStatePropertyAll(
            useMinimumSize ? const Size(120, 32) : const Size.square(24),
          ),
          padding: const WidgetStatePropertyAll(.all(4)),
        ),
      ),
      child: icon != null
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: icon,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(color),
              ),
              label: DefaultTextStyle.merge(
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Torus",
                  fontSize: 8,
                  fontWeight: .w600,
                  height: 1,
                ),
                child: child,
              ),
            )
          : FilledButton(
              onPressed: onPressed,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(color),
              ),
              child: DefaultTextStyle.merge(
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: "Torus",
                  fontSize: 8,
                  fontWeight: .w600,
                  height: 1,
                ),
                child: child,
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';

class OsuButton extends StatelessWidget {
  const OsuButton({
    super.key,
    this.onPressed,
    required this.child,
    this.color = Colors.pink,
  }) : icon = null;

  const OsuButton.icon({
    super.key,
    this.onPressed,
    required this.child,
    required this.icon,
    this.color = Colors.pink,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Widget? icon;

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(color),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: .circular(6)),
          ),
          iconSize: const WidgetStatePropertyAll(12),
          iconColor: const WidgetStatePropertyAll(Colors.white),
          minimumSize: const WidgetStatePropertyAll(Size(120, 32)),
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

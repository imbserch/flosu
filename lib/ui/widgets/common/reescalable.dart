import 'package:flutter/material.dart';

class Reescalable extends StatelessWidget {
  const Reescalable({
    super.key,
    required this.child,
    this.toSize = const Size(640, 480),
  });
  final Size toSize;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    final scaleX = screen.width / toSize.width;
    final scaleY = screen.height / toSize.height;

    final scale = scaleX < scaleY ? scaleX : scaleY;

    final screenScaled = screen / scale / pixelRatio;

    //Envolve the screen in a [SizedBox] with the size of the window,
    //[FittedBox] scales the resolution
    //and the internal [SizedBox] sets the new size based on the scale
    //(Reduce/expand the screen)
    return Material(
      type: .transparency,
      child: SizedBox.fromSize(
        size: screen,
        child: AspectRatio(
          aspectRatio: screen.aspectRatio,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              padding: .zero,
              viewInsets: .zero,
              viewPadding: .zero,
              textScaler: TextScaler.noScaling,
              // size: screenScaled,
            ),
            child: FittedBox(
              key: const Key("Reescalable key"),
              child: SizedBox.fromSize(size: screenScaled, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

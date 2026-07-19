import 'dart:math';
import 'package:flutter/material.dart';

class OsuCubeLoader extends StatefulWidget {
  const OsuCubeLoader({
    super.key,
    this.backgroundColor,
    this.foregroundColor,
    this.scale = 1,
  });

  final Color? backgroundColor;
  final Color? foregroundColor;

  final double scale;
  @override
  State<OsuCubeLoader> createState() => _OsuCubeLoaderState();
}

class _OsuCubeLoaderState extends State<OsuCubeLoader>
    with TickerProviderStateMixin {
  late final AnimationController containerController, loadingController;
  late final Animation<double> containerAnim, loadingAnim;

  @override
  initState() {
    _setAnimations();
    super.initState();
  }

  @override
  dispose() {
    containerController.dispose();
    loadingController.dispose();
    super.dispose();
  }

  void _setAnimations() {
    containerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    containerAnim =
        Tween<double>(begin: 0, end: pi).animate(
          CurvedAnimation(
            parent: containerController,
            curve: Curves.easeInOutCubic,
          ),
        )..addListener(() {
          if (mounted) setState(() {});
        });
    loadingAnim =
        Tween<double>(begin: 0, end: 2 * pi).animate(loadingController)
          ..addListener(() {
            if (mounted) setState(() {});
          });

    containerController.repeat();
    loadingController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      filterQuality: .low,
      scale: widget.scale,
      child: SizedBox.square(
        dimension: 36,
        child: Stack(
          fit: .expand,
          children: [
            Transform.rotate(
              angle: containerAnim.value,
              child: Container(
                height: 36,
                width: 36,
                decoration: BoxDecoration(
                  borderRadius: .circular(12),
                  color: widget.backgroundColor ?? Colors.white70,
                ),
                child: const Center(),
              ),
            ),
            Container(
              height: 36,
              width: 36,
              padding: const .all(2),
              child: Transform.rotate(
                angle: (pi / 5) + loadingAnim.value,
                child: CircularProgressIndicator(
                  value: .8,
                  strokeWidth: 3,
                  color: widget.foregroundColor ?? Colors.black,
                  // ignore: deprecated_member_use
                  year2023: false,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

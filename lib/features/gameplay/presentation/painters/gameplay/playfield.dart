import 'package:flosu/features/gameplay/presentation/painters/gameplay/base.dart';
import 'package:flutter/widgets.dart';

class PlayfieldPainter extends CustomPainter {
  PlayfieldPainter({required this.position, required this.drawables})
    : super(repaint: Listenable.merge([position, drawables]));

  final ValueNotifier<double> position;
  final ValueNotifier<List<PlayfieldDrawable>> drawables;

  @override
  void paint(Canvas canvas, _) {
    final double pos = position.value;

    for (final drawable in drawables.value) {
      drawable.paint(canvas, pos);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

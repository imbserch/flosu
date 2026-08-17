import 'package:flosu/core/constants.dart';
import 'package:flosu/core/extensions/models.dart';
import 'package:flosu/features/gameplay/presentation/painters/gameplay/base.dart';
import 'package:flosu/shared/domain/mod/mod.dart';
import 'package:flutter/widgets.dart';

class PlayfieldPainter extends CustomPainter {
  PlayfieldPainter({
    required this.position,
    required this.drawables,
    required this.mods,
  }) : super(repaint: Listenable.merge([position, drawables]));

  final ValueNotifier<double> position;
  final ValueNotifier<List<PlayfieldDrawable>> drawables;
  final Set<Mod> mods;

  @override
  void paint(Canvas canvas, _) {
    final isHardRock = mods.containsMod(.hardRock);
    final double pos = position.value;

    if (isHardRock) {
      canvas.save();
      canvas.translate(0, SPINNER_CENTRE.dy * 2);
      canvas.scale(1, -1);
    }

    for (final drawable in drawables.value) {
      drawable.paint(canvas, pos);
    }

    if (isHardRock) canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

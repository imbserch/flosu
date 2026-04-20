part of 'base.dart';

class HitCirclePainter extends HitObjectPainter {
  HitCirclePainter(this.object, super.position, super.difficulty, super.mods);

  final HitObject object;

  @override
  void paint(Canvas canvas, Size s) {
    final tween = Tween(begin: 0.0, end: 1.0);

    final textStyle = TextStyle(
      fontFamily: "Torus",
      fontWeight: .w700,
      color: Colors.white,
      fontSize: difficulty.circleRadius * (2 / 3),
      height: 1,
    );

    final hitCircleBody = Paint()
      ..filterQuality = .none
      ..strokeWidth = (28 / 16) * difficulty.circleRadius
      ..strokeCap = .round;
    final hitCircleRing1 = Paint()
      ..filterQuality = .none
      ..strokeWidth = difficulty.circleRadius / 3
      ..strokeCap = .round
      ..style = .stroke;
    final hitCircleRing2 = Paint()
      ..filterQuality = .none
      ..strokeWidth = difficulty.circleRadius / 6
      ..strokeCap = .round
      ..style = .stroke;
    final hitCircleBorder = Paint()
      ..filterQuality = .none
      ..strokeCap = .round
      ..style = .stroke;

    final isHidden = mods.containsMod(Hidden());

    //FadeIn curve
    final objectPreempt = isHidden
        ? difficulty.preempt * (2 / 3)
        : difficulty.preempt;

    final fadeInStart = object.hitTime - objectPreempt;
    final fadeInEnd = object.hitTime - difficulty.preemptFullOp;

    final fadeIn = ((position - fadeInStart) / (fadeInEnd - fadeInStart)).clamp(
      0.0,
      1.0,
    );

    //FadeOut curve (For hidden)
    final fadeOutStart = object.hitTime - difficulty.preemptFullOp;
    final fadeOutEnd = object.hitTime;

    final fadeOut =
        1 -
        ((position - fadeOutStart) / (fadeOutEnd - fadeOutStart)).clamp(
          0.0,
          1.0,
        );

    final opacity = mods.containsMod(Hidden())
        ? (position > object.hitTime - difficulty.preemptFullOp)
              ? fadeOut
              : fadeIn
        : fadeIn;

    //Don't draw hidden objects
    if (opacity == 0) return;

    final timeLeft = object.hitTime - position;

    //TODO: CHANGE: Don't draw after hitHime
    if (timeLeft < 0) return;

    final stackOffset = Offset(4.0 * object.stackIdx, 4.0 * object.stackIdx);

    final center = object.pos + stackOffset;

    // Size curve
    final sizeStart = object.hitTime - difficulty.preempt;
    final sizeEnd = object.hitTime;

    final sizeProgress = ((position - sizeStart) / (sizeEnd - sizeStart)).clamp(
      0.0,
      1.0,
    );

    final sizeCurve = Curves.linear.transform(sizeProgress);
    final sizeFinalProgress = 4 - (3 * tween.transform(sizeCurve));

    saveLayer(canvas, opacity);

    //Base
    canvas.drawPoints(.points, [
      center,
    ], hitCircleBody..color = Color.lerp(object.color, Colors.black, .75)!);

    //First ring
    canvas.drawArc(
      .fromCenter(
        center: center,
        width: (17 / 12) * difficulty.circleRadius,
        height: (17 / 12) * difficulty.circleRadius,
      ),
      0,
      2 * pi,
      false,
      hitCircleRing1..color = Color.lerp(object.color, Colors.black, .5)!,
    );

    //Second ring
    canvas.drawArc(
      .fromCenter(
        center: center,
        width: (19 / 12) * difficulty.circleRadius,
        height: (19 / 12) * difficulty.circleRadius,
      ),
      0,
      2 * pi,
      false,
      hitCircleRing2..color = object.color,
    );

    //Border
    canvas.drawArc(
      .fromCenter(
        center: center,
        width: 2 * difficulty.circleRadius,
        height: 2 * difficulty.circleRadius,
      ),
      0,
      2 * pi,
      false,
      hitCircleBorder
        ..color = Colors.white
        ..strokeWidth = difficulty.circleRadius / 16,
    );

    //Approach circle (drawn if hit time > position)
    if (timeLeft > 0 && !isHidden) {
      canvas.drawArc(
        .fromCenter(
          center: center,
          width: sizeFinalProgress * (2 * difficulty.circleRadius),
          height: sizeFinalProgress * (2 * difficulty.circleRadius),
        ),
        0,
        2 * pi,
        false,
        hitCircleBorder
          ..color = object.color
          ..strokeWidth = sizeFinalProgress * (difficulty.circleRadius / 16),
      );
    }

    //Text
    final textSpan = TextSpan(text: "${object.comboIdx}", style: textStyle);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: .ltr, // Use ui.TextDirection.ltr (left-to-right) or rtl
    )..layout();

    final textOffset = Offset(textPainter.width / 2, textPainter.height / 2);

    textPainter.paint(canvas, center - textOffset);

    restoreLayer(canvas, opacity);
  }
}

part of 'base.dart';

/// Renders a [HitCircle] or the head of a [Slider] onto the playfield canvas.
///
/// Drawing order (back to front):
/// 1. Dark base disc (filled circle).
/// 2. Inner color ring (medium ring).
/// 3. Outer color ring (thin ring).
/// 4. White border ring.
/// 5. Approach circle (shrinks toward the hit time; hidden when using [Hidden]).
/// 6. Combo number text.
class HitCirclePainter extends HitObjectPainter {
  HitCirclePainter(this.object, super.position, super.difficulty, super.mods);

  /// The hit object to render (may be a [HitCircle] or a [Slider]).
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

    // Paint objects — created once per paint call.
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

    // --- Opacity calculation ---------------------------------------------------

    // With Hidden, the preempt window is shortened to 2/3 of the normal value.
    final objectPreempt = isHidden
        ? difficulty.preempt * (2 / 3)
        : difficulty.preempt;

    final fadeInStart = object.hitTime - objectPreempt;
    final fadeInEnd = object.hitTime - difficulty.preemptFullOp;

    // Fade-in progress (0 → 1).
    final fadeIn = ((position - fadeInStart) / (fadeInEnd - fadeInStart)).clamp(
      0.0,
      1.0,
    );

    // With Hidden the object fades out before it would normally be hit.
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

    if (opacity == 0) return;

    final timeLeft = object.hitTime - position;

    // Do not draw circle body after the hit time (explosion is handled elsewhere).
    if (timeLeft < 0) return;

    // --- Stack offset ---------------------------------------------------------
    final stackOffset = Offset(4.0 * object.stackIdx, 4.0 * object.stackIdx);

    // For sliders, use the first computed path point instead of the raw position.
    final center = object is Slider
        ? (object as Slider).points.first
        : object.pos + stackOffset;

    // --- Approach circle size -------------------------------------------------
    // The approach circle shrinks from 4× radius at first appearance to
    // exactly 1× radius at hit time.
    final sizeStart = object.hitTime - difficulty.preempt;
    final sizeEnd = object.hitTime;

    final sizeProgress = ((position - sizeStart) / (sizeEnd - sizeStart)).clamp(
      0.0,
      1.0,
    );

    final sizeCurve = Curves.linear.transform(sizeProgress);
    final sizeFinalProgress = 4 - (3 * tween.transform(sizeCurve));

    // --- Rendering ------------------------------------------------------------
    saveLayer(canvas, opacity);

    // 1. Dark base disc.
    canvas.drawPoints(.points, [
      center,
    ], hitCircleBody..color = Color.lerp(object.color, Colors.black, .75)!);

    // 2. Inner color ring (medium weight).
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

    // 3. Outer color ring (thin weight).
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

    // 4. White border.
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

    // 5. Approach circle (not drawn after hit time, or when using Hidden mod).
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

    // 6. Combo number.
    final textSpan = TextSpan(text: "${object.comboIdx}", style: textStyle);

    final textPainter = TextPainter(text: textSpan, textDirection: .ltr)
      ..layout();

    final textOffset = Offset(textPainter.width / 2, textPainter.height / 2);

    textPainter.paint(canvas, center - textOffset);

    restoreLayer(canvas, opacity);
  }
}

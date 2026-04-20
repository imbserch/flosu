part of "base.dart";

class SliderPainter extends HitObjectPainter {
  SliderPainter(
    this.object,
    this.canSnake,
    super.position,
    super.difficulty,
    super.mods,
  );

  final Slider object;
  final bool canSnake;

  final tween = Tween(begin: 0.0, end: 1.0);

  double get slideDuration => object.duration / object.slides;

  double get sliderProgress =>
      ((position - object.hitTime) / object.duration).clamp(0.0, 1.0);

  List<Offset> pathFromStart(double t) {
    final end = (t * object.points.length).floor();

    return object.points.sublist(0, end);
  }

  List<Offset> pathFromEnd(double t) {
    final start = (t * object.points.length).floor();

    return object.points.sublist(start);
  }

  void drawSliderBody(Canvas canvas) {
    final sliderBorder = Paint()
      ..filterQuality = .none
      ..style = .stroke
      ..strokeWidth = (24 / 16) * difficulty.circleRadius
      ..strokeCap = .round;

    final sliderBody = Paint()
      ..filterQuality = .none
      ..style = .stroke
      ..strokeWidth = (18 / 16) * difficulty.circleRadius
      ..strokeCap = .round;

    final currentSlides = (position - object.hitTime) / slideDuration;

    //Stats from currentSlides
    final slideCount = currentSlides.truncate();
    final slidePortion = currentSlides.remainder(1.0);
    final isSlideForward = slideCount.isEven;

    List<Offset> sliderPart = [];

    if (!canSnake) {
      //If can't snake, don't reprocess sliders
      //Draw entire slider
      sliderPart = object.points;
    } else if (object.hitTime > position) {
      // Grow length curve
      final empty = object.hitTime - difficulty.preempt;
      final full = object.hitTime - difficulty.preemptFullOp;

      final relativeLen = ((position - empty) / (full - empty)).clamp(0.0, 1.0);

      final len = Curves.easeOut.transform(relativeLen);

      //Draw from start to slidePortion (len)
      sliderPart = pathFromStart(len);
    } else {
      //Edge cases: prevent drawing after last slider end
      if (slideCount > object.slides - 1) return;

      //Draw snaking slider
      if (slideCount == object.slides - 1) {
        sliderPart = isSlideForward
            ? pathFromEnd(slidePortion)
            : pathFromStart(1 - slidePortion);
      } else {
        //Draw entire slider (not last slide)
        sliderPart = object.points;
      }
    }

    //Draw slider part
    canvas.drawPoints(.points, sliderPart, sliderBorder..color = object.color);
    canvas.drawPoints(
      .points,
      sliderPart,
      sliderBody..color = Color.lerp(object.color, Colors.black, .75)!,
    );
  }

  void drawSliderBall(Canvas canvas) {
    final arrowPaint = Paint()
      ..filterQuality = .none
      ..color = Colors.white
      ..style = .stroke
      ..strokeWidth = difficulty.circleRadius / 6
      ..strokeJoin = .round
      ..strokeCap = .round;

    final sliderBallBody = Paint()
      ..filterQuality = .none
      ..style = .stroke
      ..strokeWidth = (9 / 8) * difficulty.circleRadius
      ..color = object.color
      ..strokeJoin = .round
      ..strokeCap = .round;

    final sliderBallBorder = Paint()
      ..filterQuality = .none
      ..style = .stroke
      ..strokeWidth = (3 / 16) * difficulty.circleRadius
      ..color = Colors.white
      ..strokeJoin = .round
      ..strokeCap = .round;

    final sliderBallThreshold = Paint()
      ..filterQuality = .none
      ..style = .stroke
      ..color = object.color.withAlpha(64)
      ..strokeJoin = .round
      ..strokeCap = .round;

    final sliderBallThresholdBorder = Paint()
      ..style = .stroke
      ..strokeWidth = difficulty.circleRadius / 8
      ..color = object.color.withAlpha(192)
      ..strokeJoin = .round
      ..strokeCap = .round;

    final double arrowSize = difficulty.circleRadius / 4;
    final arrowPath = Path();

    // Una punta de flecha simple (triángulo)
    arrowPath
      ..moveTo(-arrowSize * 0.5, -arrowSize * 0.8)
      ..lineTo(arrowSize * 0.7, 0)
      ..lineTo(-arrowSize * 0.5, arrowSize * 0.8);

    final currentSlides = (position - object.hitTime) / slideDuration;

    //Stats from currentSlides
    final slideCount = currentSlides.truncate();
    final slidePortion = currentSlides.remainder(1.0);
    final isSlideForward = slideCount.isEven;

    //Only draw sliderBall after hitTime
    if (object.hitTime > position) return;
    //Edge cases: draw sliderBall only in slider duration
    if (object.hitTime + object.duration < position) return;

    final pointDistance = isSlideForward ? slidePortion : 1 - slidePortion;
    final pointIdx = pointDistance * (object.points.length - 1);

    final ballT = pointIdx.remainder(1.0);

    final offsetA = object.points[pointIdx.floor()];
    final offsetB = object.points[pointIdx.ceil()];

    final ballOffset = Line.getPoint(offsetA, offsetB, ballT);

    final angleDirection = isSlideForward ? pi : 0;
    final angle = (offsetA - offsetB).direction + angleDirection;

    // Grow size curve
    final mini = object.hitTime;
    final normal = object.hitTime + 100;

    final size = ((position - mini) / (normal - mini)).clamp(0.0, 1.0);

    //Draw sliderball threshold
    canvas.drawPoints(
      .points,
      [ballOffset],
      sliderBallThreshold
        ..strokeWidth = (2 + 2 * size) * difficulty.circleRadius,
    );

    //Draw sliderball threshold border
    canvas.drawArc(
      .fromCircle(
        center: ballOffset,
        radius: (1 + size) * difficulty.circleRadius,
      ),
      0,
      2 * pi,
      false,
      sliderBallThresholdBorder,
    );

    //Draw sliderball border
    canvas.drawArc(
      .fromCircle(
        center: ballOffset,
        radius: (10 / 16) * difficulty.circleRadius,
      ),
      0,
      2 * pi,
      false,
      sliderBallBorder,
    );

    canvas.drawPoints(.points, [ballOffset], sliderBallBody);

    //Adjust canvas for drawing slider arrow
    canvas.translate(ballOffset.dx, ballOffset.dy);
    canvas.rotate(angle);

    canvas.drawPath(arrowPath, arrowPaint);

    //Reset canvas
    canvas.rotate(-angle);
    canvas.translate(-ballOffset.dx, -ballOffset.dy);
  }

  void drawSliderTicks(Canvas canvas) {
    final tickPoint = Paint()
      ..filterQuality = .none
      ..strokeWidth = difficulty.circleRadius / 15
      ..style = .stroke;

    //Only draw if after hitTime
    if (object.hitTime > position) return;

    //No-op for now
  }

  void drawSliderEnds(Canvas canvas) {
    final sliderEnd = Paint()
      ..filterQuality = .none
      ..style = .stroke
      ..strokeWidth = (3 / 16) * difficulty.circleRadius
      ..strokeJoin = .round
      ..strokeCap = .round;

    final sliderReverse = Paint()
      ..filterQuality = .none
      ..style = .stroke
      ..strokeWidth = (3 / 8) * difficulty.circleRadius
      ..strokeJoin = .round
      ..strokeCap = .round;

    //No-op for now
  }

  @override
  void paint(Canvas canvas, Size s) {
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
    final fadeOutEnd = object.hitTime + object.duration;

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

    saveLayer(canvas, opacity);

    drawSliderBody(canvas);
    drawSliderTicks(canvas);

    restoreLayer(canvas, opacity);

    drawSliderEnds(canvas);
    drawSliderBall(canvas);

    if (object.hitTime > position) {
      //Draw hit circle before hitTime
      HitCirclePainter(object, position, difficulty, mods).paint(canvas, s);
    }
  }
}

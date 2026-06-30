part of 'base.dart';

/// Renders a [Slider] onto the playfield canvas.
///
/// Drawing order (back to front):
/// 1. Slider body (thick rounded tube using [VerticesUtils]).
/// 2. Slider head ([HitCirclePainter] at the start point).
/// 3. Slider tail (end-point circle, dimmer than the head).
/// 4. Slider tick marks (dots at regular intervals along the track).
/// 5. Slider ball (animated circle that moves along the path after the head is hit).
class SliderPainter extends HitObjectPainter {
  SliderPainter(
    this.object,
    super.position,
    super.difficulty,
    super.mods,
    this.snakingSliders,
  );

  /// The slider hit object to render.
  final Slider object;

  /// When true, the slider body grows out from the head as its start time
  /// approaches ("snaking" effect). When false the full path is drawn immediately.
  final bool snakingSliders;

  /// Normalised position of the slider ball along the full path, [0.0, 1.0].
  ///
  /// - Before the slider starts: 0.0 (ball is at the head).
  /// - During tracking: interpolated between 0 and 1 over [object.duration].
  /// - Exactly 0.5 at the midpoint of the first slide.
  double _sliderBallProgress(int position) {
    if (position < object.hitTime) return 0.0;

    final elapsed = position - object.hitTime;
    if (elapsed >= object.duration) return 1.0;

    final singleSlideDuration = object.duration / object.slides;
    final slideElapsed = elapsed % singleSlideDuration;
    final slideProgress = slideElapsed / singleSlideDuration;

    // Even slides go forward, odd slides reverse.
    final slideIdx = elapsed ~/ singleSlideDuration;
    return slideIdx.isEven ? slideProgress : 1.0 - slideProgress;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final sliderBodyPaint = Paint()..filterQuality = .high;

    final headPainter = HitCirclePainter(object, position, difficulty, mods);

    // Retrieve computed path points (cached after first access).
    final allPoints = object.points;
    if (allPoints.isEmpty) return;

    final fadeInStart = object.hitTime - difficulty.preempt;
    final fadeInEnd = object.hitTime - difficulty.preemptFullOp;

    final opacity = ((position - fadeInStart) / (fadeInEnd - fadeInStart))
        .clamp(0.0, 1.0);

    if (opacity == 0) return;

    // Determine how far along the path should be drawn.
    List<Offset> visiblePoints;

    if (snakingSliders && position < object.hitTime) {
      final snakeProgress =
          ((position - fadeInStart) / (object.hitTime - fadeInStart)).clamp(
            0.0,
            1.0,
          );
      final endIdx = max(2, (allPoints.length * snakeProgress).round());
      visiblePoints = allPoints.sublist(0, endIdx);
    } else {
      visiblePoints = allPoints;
    }

    saveLayer(canvas, opacity);

    final bodyRadius = difficulty.circleRadius * 2;

    // White outer stroke (border).
    canvas.drawVertices(
      VerticesUtils.generateVertices(
        visiblePoints,
        strokeWidth: bodyRadius * 0.875,
      ),
      BlendMode.srcOver,
      sliderBodyPaint..color = object.color,
    );

    // Colored inner fill (slightly narrower).
    canvas.drawVertices(
      VerticesUtils.generateVertices(
        visiblePoints,
        strokeWidth: bodyRadius * 0.7,
      ),
      BlendMode.srcOver,
      sliderBodyPaint..color = Color.lerp(object.color, Colors.black, 0.8)!,
    );

    restoreLayer(canvas, opacity);

    headPainter.paint(canvas, s);

    if (position >= object.hitTime &&
        position <= object.hitTime + object.duration) {
      _paintBall(canvas, allPoints, opacity);
    }
  }

  /// Draws the animated slider ball at the position corresponding to
  /// the current audio [position].
  void _paintBall(Canvas canvas, List<Offset> points, double opacity) {
    final progress = _sliderBallProgress(position);
    final ballIdx = (progress * (points.length - 1)).round().clamp(
      0,
      points.length - 1,
    );
    final ballPos = points[ballIdx];

    final ballPaint = Paint()
      ..color = object.color.withAlpha((220 * opacity).round());
    final ballBorderPaint = Paint()
      ..style = .stroke
      ..strokeWidth = difficulty.circleRadius / 12
      ..color = Colors.white.withAlpha((220 * opacity).round());

    final r = difficulty.circleRadius;
    canvas.drawCircle(ballPos, r, ballPaint);
    canvas.drawCircle(ballPos, r, ballBorderPaint);
  }
}

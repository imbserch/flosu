import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:flosu/core/enums.dart';
import 'package:flosu/core/math/geometry.dart';
import 'package:flosu/models/beatmap/beatmap.dart';

/// Base class for all playable hit objects in an osu! standard beatmap.
///
/// The three concrete subtypes are [HitCircle], [Slider], and [Spinner].
/// This class is `sealed` so that exhaustive `switch` expressions are possible
/// without a default case.
sealed class HitObject {
  HitObject({
    required this.pos,
    required this.hitTime,
    required this.color,
    required this.comboIdx,
  });

  /// Position of the object in osu! playfield coordinates (512×384 space).
  ///
  /// Ignored by [Spinner], which is always centred at (256, 192).
  final Offset pos;

  /// Timestamp (in ms) at which the player must interact with this object.
  final int hitTime;

  /// Combo color assigned to this object.
  ///
  /// Calculated during map loading based on combo breaks and [BeatmapColors].
  /// See [BeatmapParser.scanBeatmap] and [BeatmapParser.loadBeatmap].
  final Color color;

  /// Index of this object within its current combo sequence (1-based).
  ///
  /// Displayed as a number inside the [HitCircle] to help players read combos.
  final int comboIdx;

  /// Stack offset index applied when multiple objects overlap at the same position.
  ///
  /// Each step shifts the rendered object by `(4 * stackIdx, 4 * stackIdx)` pixels.
  int stackIdx = 0;

  /// Parses a single hit-object row from the `.osu` `[HitObjects]` section.
  ///
  /// Returns `null` if the object cannot be constructed (e.g. malformed data).
  ///
  /// [row]              — comma-split fields of one hit-object line.
  /// [color]            — the combo color assigned externally.
  /// [index]            — the combo index for this object.
  /// [timing]           — the active timing point at [hitTime].
  /// [baseBeatLength]   — beat length from the last uninherited timing point.
  /// [sliderMultiplier] — the beatmap's global slider speed multiplier.
  /// [sliderTickRate]   — the beatmap's slider tick rate.
  static HitObject? fromList(
    List<String> row,
    Color color,
    int index,
    TimingPoint timing,
    double baseBeatLength,
    double sliderMultiplier,
    double sliderTickRate,
  ) {
    final double x = double.tryParse(row[0]) ?? 0;
    final double y = double.tryParse(row[1]) ?? 0;
    final Offset pos = Offset(x, y);
    final int hitTime = int.tryParse(row[2]) ?? 0;
    final int typeBitmask = int.tryParse(row[3]) ?? 0;

    if (HitObjectType.slider.existsIn(typeBitmask)) {
      final sliderData = row[5].split('|');
      final double length = double.tryParse(row[7]) ?? 0;
      final int repeats = int.tryParse(row[6]) ?? 1;

      // Determine the slider velocity multiplier (SV) from the timing point.
      double velocityMult = 1.0;
      if (timing is ITimingPoint) {
        velocityMult = timing.beatMultiplier;
      }

      // Duration formula: (length / (multiplier * 100 * SV)) * BPM * slides
      final pixelsPerBeat = 100 * sliderMultiplier * velocityMult;
      final beats = length / pixelsPerBeat;
      final duration = beats * baseBeatLength * repeats;

      final tickDistance = pixelsPerBeat / sliderTickRate;
      final ticksPerSlide = ((length - 0.01) / tickDistance).ceil() - 1;

      return Slider(
        pos: pos,
        hitTime: hitTime,
        color: color,
        comboIdx: index,
        duration: duration,
        slides: repeats,
        ticksPerSlide: ticksPerSlide,
        props: SliderProps(
          curveType: SliderCurve.parse(sliderData[0]),
          points: [pos, ..._parseControlPoints(sliderData.sublist(1))],
          length: length,
        ),
      );
    }

    if (HitObjectType.spinner.existsIn(typeBitmask)) {
      final int endTime = int.tryParse(row[5]) ?? hitTime;

      return Spinner(
        pos: const Offset(256, 192),
        hitTime: hitTime,
        color: color,
        comboIdx: index,
        duration: endTime - hitTime,
      );
    }

    return HitCircle(pos: pos, hitTime: hitTime, color: color, comboIdx: index);
  }

  /// Parses the control-point list from a slider's curve definition string.
  ///
  /// Each control point is encoded as `"x:y"` in the `.osu` format.
  static List<Offset> _parseControlPoints(List<String> points) {
    return points.map((p) {
      final coords = p.split(':');
      if (coords.length < 2) return Offset.zero;
      return Offset(
        double.tryParse(coords[0]) ?? 0,
        double.tryParse(coords[1]) ?? 0,
      );
    }).toList();
  }

  /// Returns `true` when this object should be rendered at the given
  /// audio [position] (in ms) and beatmap [diff]iculty settings.
  bool canShow(int position, BeatmapDifficulty diff);
}

// =============================================================================
// HitCircle
// =============================================================================

/// A circular element the player must aim at and click within a timing window.
class HitCircle extends HitObject {
  HitCircle({
    required super.pos,
    required super.hitTime,
    required super.color,
    required super.comboIdx,
  });

  /// Constructs a [HitCircle] representing the head of a [Slider].
  ///
  /// The head shares the slider's position, hit time, color, and combo index,
  /// and is rendered on top of the slider body by [HitCirclePainter].
  HitCircle.fromSlider(Slider slider)
    : this(
        pos: slider.pos,
        hitTime: slider.hitTime,
        color: slider.color,
        comboIdx: slider.comboIdx,
      );

  @override
  bool canShow(int position, BeatmapDifficulty difficulty) =>
      (hitTime - position) < difficulty.preempt &&
      (position - hitTime) < difficulty.hit50;

  @override
  String toString() =>
      "Circle: $pos with hitTime at $hitTime ($comboIdx -> ${color.toARGB32()})";
}

// =============================================================================
// Slider
// =============================================================================

/// A path the player must follow by holding a key while tracking a moving ball.
///
/// The slider consists of:
/// - A **head** (rendered as a [HitCircle]) that must be hit first.
/// - A **body** (the track) that the player must hold through.
/// - A **ball** that travels along the path after the head is hit.
/// - Optional **ticks** at regular intervals that award bonus score.
class Slider extends HitObject {
  Slider({
    required super.pos,
    required super.hitTime,
    required this.duration,
    required super.color,
    required super.comboIdx,
    required this.slides,
    required this.ticksPerSlide,
    required this.props,
  });

  /// Total duration of all slider repeats combined, in milliseconds.
  final double duration;

  /// Number of times the slider ball traverses the track (1 = no repeat).
  final int slides;

  /// Number of tick checkpoints per single slide pass.
  final int ticksPerSlide;

  /// Curve definition (type and control points).
  final SliderProps props;

  /// Returns the computed path points for this slider.
  ///
  /// On first access the points are computed and cached in [_cachedPoints].
  /// Subsequent calls return the cached list.
  List<Offset> get points =>
      _cachedPoints.isEmpty ? _getSliderPoints() : _cachedPoints;

  final List<Offset> _cachedPoints = [];

  /// Computes and caches the world-space points that define the slider path.
  ///
  /// The algorithm varies by [SliderCurve] type:
  /// - **Catmull**: uses Flutter's [CatmullRomSpline].
  /// - **Other types**: splits control points into segments at duplicate
  ///   points, then processes each segment as a bezier, arc, or line.
  List<Offset> _getSliderPoints() {
    List<Offset> points = [];

    final stackOffset = Offset(4.0 * stackIdx, 4.0 * stackIdx);

    final resPoints = props.points.map((off) => off + stackOffset).toList();

    // Catmull curves are processed as a single continuous spline.
    if (props.curveType == .catmull) {
      final spline = CatmullRomSpline.precompute(resPoints, tension: 0.25);

      // Tolerance: minimum distance between consecutive sampled points.
      final samples = spline.generateSamples(tolerance: 4);
      return samples.map((s) => s.value).toList();
    }

    // All other curve types are split into segments at duplicated anchor points.
    final segments = CurveUtils.toSegments(resPoints);

    final List<Offset> curvePoints = [];

    for (final spline in segments) {
      List<Offset> splinePoints = _processSpline(
        spline,
        props.curveType,
        curvePoints.lastOrNull,
      );

      if (splinePoints.isEmpty) continue;

      // Remove the first point if it duplicates the last of the previous segment.
      if (curvePoints.isNotEmpty && splinePoints.isNotEmpty) {
        splinePoints.removeAt(0);
      }

      curvePoints.addAll(splinePoints);
    }

    final filtered = CurveUtils.removeNaN(curvePoints);
    points.addAll(filtered);

    _cachedPoints.addAll(points);
    return _cachedPoints;
  }

  /// Processes a single segment of control points into a series of world-space
  /// positions, selecting the appropriate curve algorithm.
  ///
  /// Fallbacks are applied for very long bezier segments to maintain performance:
  /// - > 80 points: returns the raw control points.
  /// - > 20 points: uses a [Polyline] approximation.
  /// - ≤ 20 points: computes the full Bézier curve.
  List<Offset> _processSpline(
    List<Offset> spline,
    SliderCurve curveType,
    Offset? lastPoint,
  ) {
    final len = spline.length;

    if (len == 0) return [];

    // A single point is either a standalone control point or part of a line.
    if (len == 1) {
      if (lastPoint == null) return [spline.first];
      return Line.getSpline([lastPoint, spline.first]);
    }

    // Two points always define a straight line.
    if (len == 2) {
      return Line.getSpline(spline);
    }

    // Three points with a "perfect" curve type define a circular arc.
    if (len == 3 && curveType == .perfect) {
      final arcLength = Arc.getLength(spline);

      if (arcLength == null) {
        // Points are collinear — fall back to a straight line.
        return Line.getSpline(spline);
      }

      return Arc.getSpline(spline);
    }

    // Very complex bezier segments are approximated for performance.
    if (spline.length > 80) {
      return spline;
    }

    if (spline.length > 20) {
      return Polyline.getSpline(spline);
    }

    return Bezier.getSpline(spline);
  }

  @override
  bool canShow(int position, BeatmapDifficulty difficulty) {
    final remain = hitTime - position;
    final endSliderAt = hitTime + duration;

    return (remain <= difficulty.preempt && endSliderAt >= position);
  }

  @override
  String toString() =>
      "Slider: $pos with hitTime at $hitTime and $duration ms of duration ($comboIdx -> ${color.toARGB32()})";
}

// =============================================================================
// Spinner
// =============================================================================

/// A full-screen element the player must rotate the cursor around to complete.
///
/// Spinners are always centred at (256, 192) in the playfield. The [pos] field
/// is inherited but ignored.
class Spinner extends HitObject {
  Spinner({
    // pos is ignored because this element is always centred.
    super.pos = Offset.zero,
    required super.hitTime,
    required this.duration,
    required super.color,
    required super.comboIdx,
  });

  /// Duration the player must spin for, in milliseconds.
  final int duration;

  @override
  bool canShow(int position, BeatmapDifficulty difficulty) {
    final remain = hitTime - position;
    final endSpinAt = hitTime + duration;

    // Show during the preempt (fade-in) window and until the spinner ends.
    return remain <= difficulty.preempt && endSpinAt >= position;
  }

  @override
  String toString() =>
      "Spinner: HitTime at $hitTime and $duration ms of duration";
}

// =============================================================================
// SliderProps
// =============================================================================

/// Stores the raw curve definition for a [Slider], as parsed from the `.osu`
/// file format.
class SliderProps {
  SliderProps({
    required this.curveType,
    required this.points,
    required this.length,
  });

  /// The curve algorithm that should be used to interpolate the slider path.
  ///
  /// Bezier-typed sliders may still contain linear sub-segments defined by
  /// duplicate anchor points.
  final SliderCurve curveType;

  /// The raw control points of the slider curve, including the starting point.
  final List<Offset> points;

  /// Nominal length of the slider in osu! pixels.
  ///
  /// Used to calculate tick positions and total duration. Partially overridden
  /// by [SliderPainter] which trims the path to this length.
  final double length;
}

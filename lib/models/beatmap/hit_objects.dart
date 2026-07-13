import 'dart:core';
import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flosu/core/math/circular_arc.dart';
import 'package:flosu/core/math/path_approximator.dart';

import 'package:flosu/core/enums.dart';
import 'package:flosu/core/math/geometry.dart';
import 'package:flosu/models/beatmap/timing_points.dart';
import 'package:flosu/models/storage/beatmap_metadata.dart';

// ignore: constant_identifier_names
const Offset STACK_OFFSET = Offset(4.0, 4.0);

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
        props: /* <SliderProps> */ (
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
  /// audio [position] (in ms) and beatmap [metadata] settings.
  bool canShow(int position, BeatmapMetadata metadata);
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
  bool canShow(int position, BeatmapMetadata metadata) =>
      (hitTime - position) < metadata.preempt &&
      (position - hitTime) < metadata.hit50;

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
  }) {
    _precompute();
  }

  /// Total duration of all slider repeats combined, in milliseconds.
  final double duration;

  /// Number of times the slider ball traverses the track (1 = no repeat).
  final int slides;

  /// Number of tick checkpoints per single slide pass.
  final int ticksPerSlide;

  /// Curve definition (type and control points).
  final SliderProps props;

  /// Returns the computed path points for this slider.
  List<Offset> get points => _cachedPoints;

  /// Returns the relative accumulated lengths of the path segments.
  ///
  /// Relative to the slider length (1.0 at the end).
  List<double> get relativeAccLengths => _cachedRelativeAccLengths;

  /// The end time of the slider.
  double get endTime => hitTime + duration;

  /// The duration of one slide.
  double get slideDuration => duration / slides;

  /// Stores the computed path points for this slider.
  List<Offset> _cachedPoints = [];

  /// Stores the relative accumulated lengths of the path segments.
  List<double> _cachedRelativeAccLengths = [];

  List<Offset> _processPath() {
    final path = <Offset>[];

    final stackedPath = List<Offset>.from(
      props.points.map((p) => p + (STACK_OFFSET * stackIdx.toDouble())),
    );

    final subPaths = CurveUtils.toSegments(stackedPath);

    for (final subPath in subPaths) {
      final res = _processSubPath(subPath, props.curveType);

      // Skip the first point of the subpath if it is the same as the last point of the path to avoid duplicates.
      if (path.isNotEmpty && path.last == res.first) res.removeAt(0);

      path.addAll(res);
    }

    return path;
  }

  List<Offset> _processSubPath(List<Offset> subPath, SliderCurve curveType) {
    switch (curveType) {
      // Return points as is
      case SliderCurve.lineal:
        return PathApproximator.linearToPiecewiseLinear(subPath);

      // Use circular arc to approximate the curve
      case SliderCurve.perfect:
        if (subPath.length != 3) break;

        final arcProps = CircularArcProperties.fromControlPoints(subPath);
        if (!arcProps.isValid) break;

        // taken from https://github.com/ppy/osu-framework/blob/1201e641699a1d50d2f6f9295192dad6263d5820/osu.Framework/Utils/PathApproximator.cs#L181-L186
        final subPoints = (2 * arcProps.radius <= 0.1)
            ? 2
            : max(
                2,
                arcProps.thetaRange /
                    (2.0 * acos(1 - (0.1 / arcProps.radius))).ceil(),
              );

        if (subPoints >= 1000) break;

        final res = PathApproximator.circularArcToPiecewiseLinear(subPath);
        if (res.isEmpty) break;

        return res;
      // Use simplification of catmull curve
      case SliderCurve.catmull:
        final path = PathApproximator.catmullToPiecewiseLinear(subPath);
        List<Offset> optimizedPath = [];

        // Optimize path like osu!stable (ignoring optimizePath used in original sliderPath implementation)

        Offset? lastStart;

        for (int i = 0; i < path.length; i++) {
          if (lastStart == null) {
            optimizedPath.add(path[i]);
            lastStart = path[i];
            continue;
          }

          final distFromStart = (path[i] - lastStart).distance;

          if (distFromStart > 6 ||
              (i + 1) % PathApproximator.CATMULL_SEGMENT_LENGTH == 0 ||
              i == path.length - 1) {
            optimizedPath.add(path[i]);
            lastStart = null;
          }
        }

        return optimizedPath;
      // Use default B-Spline to approximate the curve
      default:
        break;
    }

    return PathApproximator.bSplineToPiecewiseLinear(subPath, subPath.length);
  }

  Offset pointAt(double t) {
    final clamped = t.clamp(0.0, 1.0);
    final index = indexAt(t);

    if (index == 0) return _cachedPoints.first;

    final double prevLength = _cachedRelativeAccLengths[index - 1];
    final double nextLength = _cachedRelativeAccLengths[index];
    final double segmentLength = nextLength - prevLength;

    final double tSegment = segmentLength == 0
        ? 0.0
        : (clamped - prevLength) / segmentLength;

    return LineUtils.getPoint(
      _cachedPoints[index - 1],
      _cachedPoints[index],
      tSegment,
    );
  }

  int indexAt(double t) {
    final clamped = t.clamp(0.0, 1.0);

    if (clamped == 0.0) return 0;
    if (clamped >= 1.0) return _cachedPoints.length - 1;

    return _cachedRelativeAccLengths.lowerBound(
      clamped,
      (a, b) => a.compareTo(b),
    );
  }

  /// Precomputes and caches the path points and relative accumulated lengths.
  ///
  /// This method should be called before using the slider's path points.
  void _precompute() {
    if (_cachedPoints.isNotEmpty && _cachedRelativeAccLengths.isNotEmpty) {
      return;
    }

    _cachedPoints = _processPath();

    List<double> accumulatedLengths = [0];

    for (int i = 1; i < _cachedPoints.length; i++) {
      accumulatedLengths.add(
        accumulatedLengths.last +
            (_cachedPoints[i] - _cachedPoints[i - 1]).distance,
      );
    }

    final totalLength = accumulatedLengths.last;
    _cachedRelativeAccLengths = accumulatedLengths
        .map((l) => l / totalLength)
        .toList();
  }

  @override
  bool canShow(int position, BeatmapMetadata metadata) {
    final remain = hitTime - position;
    final endSliderAt = hitTime + duration;

    return (remain <= metadata.preempt && endSliderAt >= position);
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
  bool canShow(int position, BeatmapMetadata metadata) {
    final remain = hitTime - position;
    final endSpinAt = hitTime + duration;

    // Show during the preempt (fade-in) window and until the spinner ends.
    return remain <= metadata.preempt && endSpinAt >= position;
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
typedef SliderProps = ({
  /// The curve algorithm that should be used to interpolate the slider path.
  /// Bezier-typed sliders may still contain linear sub-segments defined by
  /// duplicate anchor points.
  SliderCurve curveType,

  /// The raw control points of the slider curve, including the starting point.
  List<Offset> points,

  /// Nominal length of the slider in osu! pixels.
  /// Used to calculate tick positions and total duration. Partially overridden
  /// by [SliderPainter] which trims the path to this length.
  double length,
});

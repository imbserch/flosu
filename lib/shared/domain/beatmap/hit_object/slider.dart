part of "hit_object.dart";

/// A slidable object with [HitCircle] as its head.
class Slider extends HitObjectWithEndTime {
  Slider() : super();

  /// Slides of slider.
  int slides = 1;

  /// Pixel length of slider.
  int pixelLength = 0;

  /// Type of slider curve.
  SliderCurve curveType = .lineal;

  /// Points of slider path.
  final List<Offset> _points = [];

  final List<NestedHitObject> _nestedHitObjects = [];

  void clearNestedHitObjects() => _nestedHitObjects.clear();

  void addNestedHitObject(NestedHitObject nestedHitObject) {
    _nestedHitObjects.insert(0, nestedHitObject);
  }

  List<NestedHitObject> get nestedHitObjects =>
      .unmodifiable(_nestedHitObjects);

  /// Cached path points.
  List<Offset>? _cachedPathPoints;

  /// Cached path points lengths.
  List<double>? _cachedPathLengths;

  /// Control points of slider path.
  /// Includes the first point (the same as [HitObject.position]).
  List<Offset> get controlPoints => .unmodifiable([position, ..._points]);

  /// Add a point to the slider path.
  void addPoint(Offset point) => _points.add(point);

  /// The path points of the slider. Includes the first point.
  List<Offset> get pathPoints =>
      _cachedPathPoints ??= SliderPath.getPath(controlPoints, curveType);

  /// The length of each path segment.
  List<double> get pathLengths => _cachedPathLengths ??=
      SliderPath.getPathLengths(pathPoints, _cachedPathLengths);

  /// Length of slider path.
  double get length => pathLengths.lastOrNull ?? 0.0;

  /// Duration of one slide.
  double get slideDuration => (endTime - time) / slides;

  Offset get endPosition {
    if (pathPoints.isEmpty) return position;
    return (slides % 2 == 0) ? pathPoints.first : pathPoints.last;
  }

  /// Returns the position of the slider at the given normalized time.
  Offset positionAt(double t) => SliderPath.pointAt(pathPoints, pathLengths, t);

  /// Returns the index of the path segment at the given normalized time.
  int indexAt(double t) => SliderPath.indexAt(pathPoints, pathLengths, t);
}

import 'package:flosu/shared/domain/beatmap/hit_object/hit_object.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Slider", () {
    final slider = Slider()
      ..position = .zero
      ..time = 1000
      ..endTime = 2000
      ..curveType = .bezier
      ..addPoint(const Offset(100, 100))
      ..addPoint(const Offset(0, 100));

    test("Has the defined number of points (position + controlPoints)", () {
      expect(slider.controlPoints.length, 3);
    });
    test("Has the same or more controlPoints than pathPoints", () {
      expect(
        slider.pathPoints.length,
        greaterThanOrEqualTo(slider.controlPoints.length),
      );
    });
  });
}

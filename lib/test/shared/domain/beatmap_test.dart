import 'dart:ui' show Color;

import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import "package:flutter_test/flutter_test.dart";

void main() {
  final beatmap = Beatmap();

  group("Beatmap", () {
    test('Has default colors at inicialization', () {
      const green = Color(0xff00ca00);
      expect(beatmap.colors[0], green);
    });
    test('Adding a color replaces the default colors', () {
      const white = Color(0xffffffff);
      beatmap.rawColors = [...beatmap.rawColors, white.toARGB32()];

      expect(beatmap.colors.length, 1);
      expect(beatmap.colors[0], white);
    });
  });
}

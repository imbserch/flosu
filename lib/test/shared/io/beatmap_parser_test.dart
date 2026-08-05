import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/io/parsers/beatmap_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Beatmap parser', () {
    test("An empty path fails the parser", () async {
      final parser = BeatmapParser("");

      expect(() async => await parser.parse(), throwsException);
    });
    test("An invalid path fails the parser", () async {
      final parser = BeatmapParser("C:/invalid/path");
      expect(() async => await parser.parse(), throwsException);
    });

    Beatmap? beatmap;

    test("First parse pass should return a beatmap", () async {
      final parser = BeatmapParser("./lib/test/shared/io/osu_test_file.osu");

      // First parse pass
      beatmap = await parser.parse();

      // Ensure the beatmap is a Beatmap
      expect(beatmap!, isA<Beatmap>());

      // Expect the .osu file is legitimized and hash is not empty
      // if hash is empty: the file was loaded from another source
      expect(beatmap!.hash, isNotEmpty);

      // Expect the artist is filled as other properties.
      expect(beatmap!.artist, isNotEmpty);

      // Expect first parse pass parse only metadata and general section
      expect(beatmap!.hitObjects, isEmpty);
    });

    test("Second parse pass should parse hitobjects", () async {
      // Second parse
      final parser = BeatmapParser.fromBeatmap(beatmap!);

      beatmap = await parser.parse();

      expect(beatmap!.hitObjects, isNotEmpty);
    });

    test("Other parse passes shouldn't overwrite the beatmap data", () async {
      // Third parse pass
      final parser = BeatmapParser.fromBeatmap(beatmap!);

      final contents = await parser.parse();

      expect(contents.difficulty, beatmap!.difficulty);
      expect(contents.hitObjects.length, beatmap!.hitObjects.length);
    });
  });
}

import 'dart:io' show File;
import 'dart:ui' show Color;

import 'package:flosu/shared/domain/beatmap/hit_object/hit_object.dart';
import 'package:isar_community/isar.dart';

part 'difficulty.dart';
part 'event.dart';
part 'timing.dart';
part "beatmap.g.dart";

// Set to mutable class for allow I/O operations on it.
@collection
class Beatmap {
  // Id is already used
  final Id index = Isar.autoIncrement;

  // This is used by the repository to check if
  // the database schema needs to be updated.
  //
  // The beatmap will updated with new data
  // if this value is different from the stored one.
  late int dbVersion;

  late String hash;

  // Default song properties of beatmap.
  String title = "", artist = "", creator = "", version = "";

  // Aditional song properties.
  String source = "", tags = "";

  int id = -1, setId = -1;

  // File paths
  @Index(unique: true, replace: true)
  String? filePath;
  String? backgroundPath;
  String? audioPath;

  int previewTime = -1;

  int hitCircleCount = 0, sliderCount = 0, spinnerCount = 0;

  /// Difficulty settings of the beatmap.
  Difficulty difficulty = Difficulty();

  @ignore
  final List<Timing> timings = [];
  @ignore
  final List<HitObject> hitObjects = [];
  @ignore
  final List<Event> _events = [];

  /// Custom colors of the beatmap.
  ///
  /// If beatmap has custom colors, it will used instead.
  List<int> rawColors = [];

  @ignore
  List<Color> get _defaultColors => [
    const Color(0xff00ca00),
    const Color(0xff127cff),
    const Color(0xfff21839),
    const Color(0xffffc000),
  ];

  /// Colors of the beatmap.
  ///
  /// If beatmap has no custom colors, it will return the default colors.
  @ignore
  List<Color> get colors {
    return rawColors.isEmpty
        ? _defaultColors
        : rawColors.map((e) => Color(e)).toList();
  }

  /// Returns the number of hit circles in the beatmap.
  ///
  /// If beatmap has no objects, will use the expected value instead.
  @ignore
  int get hitCircles => hitObjects.isEmpty
      ? hitCircleCount
      : hitObjects.whereType<HitCircle>().length;

  /// Returns the number of sliders in the beatmap.
  ///
  /// If beatmap has no objects, will use the expected value instead.
  @ignore
  int get sliders =>
      hitObjects.isEmpty ? sliderCount : hitObjects.whereType<Slider>().length;

  /// Returns the number of spinners in the beatmap.
  ///
  /// If beatmap has no objects, will use the expected value instead.
  @ignore
  int get spinners => hitObjects.isEmpty
      ? spinnerCount
      : hitObjects.whereType<Spinner>().length;

  @ignore
  int get hitObjectsCount => hitCircles + sliders + spinners;

  /// Events of the beatmap.
  @ignore
  List<Event> get events => _events;

  /// Adds an event to the beatmap.
  void addEvent(Event event) => _events.add(event);

  /// Check if beatmap can be used for gameplay
  /// false if the beatmap does not have enough information to be played
  @ignore
  bool get canPlay =>
      timings.isNotEmpty && hitObjects.isNotEmpty && filePath != null;
}

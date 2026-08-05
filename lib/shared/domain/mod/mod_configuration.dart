import 'package:flosu/shared/domain/beatmap/beatmap.dart';

class ModConfiguration {
  int? extraLives;
  bool? adjustPitch;
  double? speedDecrease;
  double? speedIncrease;
  bool? restartOnFail;
  bool? failOnFailSliderTail;
  bool? onlyFadeApproachCircles;
  int? followDelay;
  double? flashlightSize;
  bool? changeSizeOnCombo;
  double? minimumAccuracy;
  Difficulty difficulty = Difficulty();
}

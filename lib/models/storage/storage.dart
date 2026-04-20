class Storage {
  Storage({
    required this.audioCompensation,
    required this.globalVolume,
    required this.musicVolume,
    required this.osuK1,
    required this.osuK2,
    required this.snakingSliders,
    required this.parallax,
    required this.backgroundDim,
    required this.backgroundBlur,
    required this.showCursorTrail,
    required this.beatmapsPath,
  });

  final int audioCompensation;
  final double globalVolume;
  final double musicVolume;
  final int osuK1;
  final int osuK2;
  final bool snakingSliders;
  final bool parallax;
  final double backgroundDim;
  final double backgroundBlur;
  final bool showCursorTrail;
  final String? beatmapsPath;

  Storage copyWith({
    int? audioCompensation,
    double? globalVolume,
    double? musicVolume,
    int? osuK1,
    int? osuK2,
    bool? snakingSliders,
    bool? parallax,
    double? backgroundDim,
    double? backgroundBlur,
    bool? showCursorTrail,
    String? beatmapsPath,
  }) => Storage(
    audioCompensation: audioCompensation ?? this.audioCompensation,
    globalVolume: globalVolume ?? this.globalVolume,
    musicVolume: musicVolume ?? this.musicVolume,
    osuK1: osuK1 ?? this.osuK1,
    osuK2: osuK2 ?? this.osuK2,
    snakingSliders: snakingSliders ?? this.snakingSliders,
    parallax: parallax ?? this.parallax,
    backgroundDim: backgroundDim ?? this.backgroundDim,
    backgroundBlur: backgroundBlur ?? this.backgroundBlur,
    showCursorTrail: showCursorTrail ?? this.showCursorTrail,
    beatmapsPath: beatmapsPath ?? this.beatmapsPath,
  );
}

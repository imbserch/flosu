class Settings {
  Settings._({
    required this.beatmapsPath,
    required this.audioCompensation,
    required this.globalVolume,
    required this.musicVolume,
    required this.backgroundDim,
    required this.backgroundBlur,
    required this.osuKeys,
    required this.snakingSlidersEnabled,
    required this.parallaxEnabled,
    required this.cursorTrailEnabled,
    required this.logsEnabled,
    required this.fpsMonitorEnabled,
  });

  Settings()
    : beatmapsPath = null,
      audioCompensation = 0,
      globalVolume = 1,
      musicVolume = 0.8,
      backgroundDim = 0.8,
      backgroundBlur = 0.2,
      osuKeys = const [0x0000000007a, 0x00000000078] /* Z, X */,
      snakingSlidersEnabled = true,
      parallaxEnabled = true,
      cursorTrailEnabled = true,
      logsEnabled = false,
      fpsMonitorEnabled = false;

  Settings copyWith({
    String? beatmapsPath,
    int? audioCompensation,
    double? globalVolume,
    double? musicVolume,
    double? backgroundDim,
    double? backgroundBlur,
    List<int>? osuKeys,
    bool? snakingSlidersEnabled,
    bool? parallaxEnabled,
    bool? cursorTrailEnabled,
    bool? logsEnabled,
    bool? fpsMonitorEnabled,
    bool keepLastBeatmapsPath = true,
  }) => Settings._(
    audioCompensation: audioCompensation ?? this.audioCompensation,
    globalVolume: globalVolume ?? this.globalVolume,
    musicVolume: musicVolume ?? this.musicVolume,
    osuKeys: osuKeys ?? this.osuKeys,
    snakingSlidersEnabled: snakingSlidersEnabled ?? this.snakingSlidersEnabled,
    parallaxEnabled: parallaxEnabled ?? this.parallaxEnabled,
    backgroundDim: backgroundDim ?? this.backgroundDim,
    backgroundBlur: backgroundBlur ?? this.backgroundBlur,
    cursorTrailEnabled: cursorTrailEnabled ?? this.cursorTrailEnabled,
    logsEnabled: logsEnabled ?? this.logsEnabled,
    fpsMonitorEnabled: fpsMonitorEnabled ?? this.fpsMonitorEnabled,
    beatmapsPath:
        beatmapsPath ?? (keepLastBeatmapsPath ? this.beatmapsPath : null),
  );

  final String? beatmapsPath;
  final int audioCompensation;
  final double globalVolume;
  final double musicVolume;
  final double backgroundDim;
  final double backgroundBlur;
  final List<int> osuKeys;
  final bool snakingSlidersEnabled;
  final bool parallaxEnabled;
  final bool cursorTrailEnabled;
  final bool logsEnabled;
  final bool fpsMonitorEnabled;
}

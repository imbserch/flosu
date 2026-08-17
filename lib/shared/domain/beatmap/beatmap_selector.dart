import 'dart:async';

import 'package:flosu/features/audio/audio.dart';
import 'package:flosu/shared/domain/beatmap/beatmap.dart';
import 'package:flosu/shared/domain/mod/mod.dart';
import 'package:flosu/shared/domain/mod/mod_selector.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter/material.dart' show Durations, ValueNotifier;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';

class BeatmapSelector extends Notifier<Beatmap?> with Logging {
  late final TrackNotifier _trackProvider;

  double _pitch = 1.0, _rate = 1.0;

  // Used by another provider
  final difficulty = ValueNotifier(Difficulty());

  @override
  Beatmap? build() {
    _trackProvider = ref.read(trackProvider.notifier);

    ref.listen(
      trackProvider,
      (_, handle) => _applyAudioModifications(handle),
      weak: true,
    );

    ref.listen(modSelector, (_, mods) => _listenMods(mods), weak: true);

    return null;
  }

  void _applyAudioModifications(SoundHandle? handle) {
    if (handle == null) return;

    ref.read(audioProvider)
      ..setRate(handle, _rate)
      ..setPitch(handle, _pitch / _rate);
  }

  void _listenMods(Set<Mod> mods) {
    difficulty.value = state?.difficulty ?? Difficulty();

    final audioMod = mods.whereType<AudioModificableMod>().lastOrNull;

    if (audioMod == null) {
      _pitch = 1.0;
      _rate = 1.0;

      return _applyAudioModifications(ref.read(trackProvider));
    }

    _pitch = audioMod.pitch;
    _rate = audioMod.rate;

    _applyAudioModifications(ref.read(trackProvider));
  }

  Future<void> loadTrack(Beatmap beatmap) async {
    final path = beatmap.audioPath;

    if (path == null) {
      return log("Beatmap has no audio path", level: .error);
    }

    await _trackProvider.loadTrack(path);
  }

  void selectBeatmap(
    Beatmap beatmap, {
    bool usePreview = false,
    bool startPaused = false,
    bool onlySet = false,
  }) {
    state = beatmap;
    _listenMods(ref.read(modSelector));

    if (onlySet) return;

    final path = beatmap.audioPath;
    final previewTime = beatmap.previewTime;

    if (path == null) {
      return log("Beatmap has no audio path", level: .error);
    }

    final stopDuration = usePreview ? Durations.long2 : null;

    final currentHandle = ref.read(trackProvider);

    final handle = _trackProvider.playTrack(
      path,
      startPaused: usePreview ? true : startPaused,
    );

    if (handle == null) {
      return log(
        "Could not play beatmap track. Ensure the track is already loaded",
        level: .error,
      );
    }

    if (currentHandle != null) {
      // Interact with core audio service
      final audioService = ref.read(audioProvider);

      audioService.setVolume(currentHandle, 0, over: stopDuration);
      audioService.stop(currentHandle, after: stopDuration);
    }

    _trackProvider.loop(to: usePreview ? previewTime : null);

    if (usePreview) {
      _trackProvider.volume(0);
      _trackProvider.seek(previewTime);
      _trackProvider.resume();
      _trackProvider.volume(1, over: stopDuration);
    }
  }
}

final beatmapSelector = NotifierProvider(() => BeatmapSelector());

final difficultyProvider = Provider<Difficulty>((ref) {
  final beatmap = ref.watch(beatmapSelector);
  final mods = ref.watch(modSelector);

  if (beatmap == null) return Difficulty();

  Difficulty modsDiff = beatmap.difficulty;

  for (final mod in mods) {
    modsDiff = mod.applyTo(modsDiff);
  }

  return modsDiff;
});

final scoreMultiplierProvider = Provider<double>((ref) {
  final mods = ref.watch(modSelector);
  return mods.fold(1, (sm, mod) => sm * mod.scoreMultiplier);
});

final modsRankedProvider = Provider<bool>((ref) {
  final mods = ref.watch(modSelector);
  return mods.every((mod) => mod.ranked);
});

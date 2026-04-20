import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flosu/logic/providers/library.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/io/replay_parser.dart';
import 'package:flosu/logic/providers/router.dart';

class GameplayService extends StateNotifier<GameplayData> {
  GameplayService(Ref ref) : super(GameplayData()) {
    _init(ref);
  }

  void _init(Ref ref) async {
    ref.listen(audioProvider, (_, beatmap) {
      state = state.copyWith(
        beatmap: beatmap,
        replay: state.replay,
        mods: state.mods,
      );
    }, fireImmediately: true);
  }

  void toggleMod(ConfigurableMod mod) {
    Set<ConfigurableMod> remainMods = {};

    final storedMod = state.mods.firstWhereOrNull(
      (m) => m.acronym == mod.acronym,
    );

    if (storedMod != null) {
      remainMods = state.mods..remove(storedMod);
    } else {
      final modsWithoutIncompatibles = state.mods.where(
        (m) => !mod.incompatibleMods.any((im) => im.acronym == m.acronym),
      );

      remainMods = {...modsWithoutIncompatibles, mod};
    }

    final ordered = Set.of(ConfigurableMod.allOrdered);

    final result = ordered
        .where((m) => remainMods.any((r) => r.acronym == m.acronym))
        .toSet();

    state = state.copyWith(replay: state.replay, mods: result);
  }

  void clearMods() => state = state.copyWith(replay: state.replay, mods: {});

  void clearAll() => state = state.copyWith(replay: null, mods: {});

  void clearReplay() => state = state.copyWith(replay: null);

  Future<void> loadReplay() async {
    final res = await FilePicker.pickFiles(
      type: .custom,
      allowedExtensions: ["osr"],
      lockParentWindow: true,
      dialogTitle: "Select .osr file",
    );

    if (res == null) return;
    if (res.count == 0) return;

    final parser = ReplayParser(File(res.files[0].path!));

    if (!await parser.init()) {
      throw StateError("Error reading replay");
    }

    final replay = parser.parse();

    if (replay == null) return;

    //Widget is unsafe, calling from root navigator
    final beatmap = globalRef
        .read(libraryProvider)
        .firstWhereOrNull((bm) => bm.hash == replay.hash);

    if (beatmap == null) return;

    state = state.copyWith(replay: replay, beatmap: beatmap, mods: replay.mods);

    //Widget is unsafe, calling from root navigator
    globalRef.read(audioProvider.notifier).preview(beatmap);

    if (mounted) {
      rootNavigatorKey.currentContext?.go("/scoring");
    }
  }
}

final gameplayService = StateNotifierProvider((ref) => GameplayService(ref));

class GameplayData {
  GameplayData({this.beatmap, this.replay, this.mods = const {}});

  final Beatmap? beatmap;
  final Replay? replay;
  final Set<ConfigurableMod> mods;

  GameplayData copyWith({
    Beatmap? beatmap,
    Replay? replay,
    Set<ConfigurableMod>? mods,
  }) => GameplayData(
    beatmap: beatmap ?? this.beatmap,
    replay: replay,
    mods: mods ?? this.mods,
  );

  BeatmapDifficulty? get difficultyWithMods => beatmap?.difficulty;

  double get modMultiplier =>
      mods.fold<double>(1.0, (t, m) => t * m.scoreMultiplier);

  bool get isRanked => mods.every((m) => m.ranked);

  String get modsName => mods.fold("", (str, mod) => str += mod.acronym);
}

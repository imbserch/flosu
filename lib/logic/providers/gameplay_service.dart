import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flosu/logic/providers/library.dart';
import 'package:flosu/logic/services/file_parser.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/models/gameplay/gameplay_data.dart';
import 'package:go_router/go_router.dart';

export 'package:flosu/models/gameplay/gameplay_data.dart';

/// Manages the pre-gameplay session configuration.
///
/// [GameplayService] bridges song selection and actual gameplay. It stores:
/// - The [Beatmap] the player has chosen to play.
/// - Any [Replay] the player loaded for review.
/// - The [Set<ConfigurableMod>] selected by the player.
///
/// It does **not** manage live gameplay state (score, health, combo). For that,
/// see [GameplayController].
class GameplayService extends StateNotifier<GameplayData> {
  GameplayService(Ref ref) : super(GameplayData()) {
    _init(ref);
  }

  final ScopedLogger _logger = Logger.requestLogger("GameplayService");

  void _init(Ref ref) {
    // Mirror the currently loaded beatmap from the audio provider so that
    // GameplayData always knows which beatmap is queued for play.
    ref.listen(audioProvider, (_, beatmap) {
      state = state.copyWith(
        beatmap: beatmap,
        replay: state.replay,
        mods: state.mods,
      );
    }, fireImmediately: true);

    final StreamSubscription replaySubs = ref
        .read(fileParserService)
        .resultStream
        .where((r) => r is ParseResult<Replay>)
        .listen(_handleParserResult);

    ref.onDispose(() {
      _logger.dispose();
      replaySubs.cancel();
    });
  }

  void _handleParserResult(ParseResult result) {
    if (result.hasError) {
      return _logger.error(result.error!);
    }

    final replay = result.data;
    if (replay is! Replay) return;

    _logger.debug(
      "Replay parsed. Played with mods: ${replay.mods.map((mod) => mod.acronym).join("")}",
    );

    _addReplayToState(replay);
  }

  void _addReplayToState(Replay replay) {
    final beatmap = globalRef
        .read(libraryProvider)
        .expand((g) => g.beatmaps)
        .firstWhereOrNull((bm) => bm.hash == replay.hash);

    if (beatmap == null) {
      return _logger.error(
        "Beatmap not found for replay played with mods ${replay.mods.map((mod) => mod.acronym).join("")}",
      );
    }

    state = state.copyWith(replay: replay, beatmap: beatmap);

    // This allows the mods to be enabled and
    // modifications to be applied in the correct order.
    clearMods();

    for (final mod in replay.mods) {
      toggleMod(mod);
    }

    globalRef.read(audioProvider.notifier).preview(beatmap);

    if (mounted) {
      rootNavigatorKey.currentContext?.go("/scoring");
    }
  }

  /// Toggles a mod on or off.
  ///
  /// If [mod] is already active, it is removed. Otherwise, all mods that are
  /// incompatible with [mod] are removed first, then [mod] is added.
  /// The resulting set is re-ordered to match [ConfigurableMod.allOrdered].
  void toggleMod(ConfigurableMod mod) {
    Set<ConfigurableMod> remainMods = {};

    final storedMod = state.mods.firstWhereOrNull(
      (m) => m.acronym == mod.acronym,
    );

    if (storedMod != null) {
      // Deactivate mod
      storedMod.deactivate(globalRef);

      remainMods = state.mods..remove(storedMod);
    } else {
      final incompatibles = <ConfigurableMod>[];
      final remaining = <ConfigurableMod>[];

      // Single pass: separate incompatible mods from remaining ones
      for (final m in state.mods) {
        if (mod.incompatibleMods.any((im) => im.acronym == m.acronym)) {
          incompatibles.add(m);
        } else {
          remaining.add(m);
        }
      }

      // Deactivate mods removed by incompatibility
      for (final incompatible in incompatibles) {
        incompatible.deactivate(globalRef);
      }

      remainMods = {...remaining, mod};

      // Activate mod
      mod.activate(globalRef);
    }

    // Re-order to the canonical display order defined in ConfigurableMod.
    final result = ConfigurableMod.allOrdered
        .where((m) => remainMods.any((r) => r.acronym == m.acronym))
        .toSet();

    state = state.copyWith(replay: state.replay, mods: result);
  }

  /// Removes the active replay while keeping the selected mods.
  void clearReplay() => state = state.copyWith(replay: null);

  /// Removes all active mods.
  void clearMods() {
    // Deactivate all mods
    for (final mod in state.mods) {
      mod.deactivate(globalRef);
    }

    state = state.copyWith(mods: {});
  }

  /// Removes both the active replay and all mods.
  void clearAll() {
    clearReplay();
    clearMods();
  }

  /// Opens a file picker dialog to load an `.osr` replay file.
  ///
  /// After loading, matches the replay to the corresponding beatmap in the
  /// library, sets both as the active session data, and navigates to the
  /// scoring screen.
  ///
  /// This method it's obsolete and will be replaced with the [FileParser.pickFile] service
  /* Future<void> loadReplay() async {
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

    // Match the replay hash to a beatmap in the loaded library.
    // Widget is unsafe at this point; use globalRef to bypass context.
    final beatmap = globalRef
        .read(libraryProvider)
        .expand((g) => g.beatmaps)
        .firstWhereOrNull((bm) => bm.hash == replay.hash);

    if (beatmap == null) return;

    state = state.copyWith(replay: replay, beatmap: beatmap, mods: replay.mods);

    // Widget is unsafe; use globalRef for audio preview.
    globalRef.read(audioProvider.notifier).preview(beatmap);

    if (mounted) {
      rootNavigatorKey.currentContext?.go("/scoring");
    }
  }
 */
}

/// Global provider for [GameplayService].
final gameplayService = StateNotifierProvider((ref) => GameplayService(ref));


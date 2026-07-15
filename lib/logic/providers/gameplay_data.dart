import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flosu/logic/providers/audio.dart';
import 'package:flosu/logic/providers/library.dart';
import 'package:flosu/logic/providers/router.dart';
import 'package:flosu/logic/services/file_parser.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flosu/models/beatmap/beatmap_content.dart';
import 'package:flosu/models/gameplay/gameplay_info.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/models/replay/replay.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GameplayData extends Notifier<GameplayInfo> {
  @override
  GameplayInfo build() {
    final parserStream = ref.read(fileParserService).resultStream;
    final changedSources = ref.read(audioProvider.notifier).changedSources;

    changedSources.addListener(() => _applyMods(state.mods));
    final parserSubs = parserStream.listen(_handleResult);

    ref.listen(audioProvider, (_, metadata) {
      final sameContents = state.contents?.md5 == metadata?.md5;
      state = state.copyWith(
        metadata: metadata,
        contents: sameContents ? state.contents : null,
        clearContents: !sameContents,
        clearReplay: true,
      );
    });

    ref.onDispose(() {
      changedSources.removeListener(() => _applyMods(state.mods));
      parserSubs.cancel();
      _logger.dispose();
    });

    final initialMetadata = ref.read(audioProvider);
    return GameplayInfo(metadata: initialMetadata);
  }

  final ScopedLogger _logger = Logger.requestLogger("GameplayService");

  void _handleResult(ParseResult result) async {
    if (result.hasError || result.data == null) return;

    if (result is ParseResult<Replay>) {
      final replay = result.data;

      final contentRelated = ref
          .read(libraryProvider)
          .firstWhereOrNull((b) => b.md5 == replay!.hash);

      if (contentRelated == null) {
        return _logger.error(
          "Beatmap not found for replay with hash ${replay!.hash}",
        );
      }

      await ref.read(audioProvider.notifier).preview(contentRelated);
      _applyMods(result.data!.mods);

      final hasSameContents = state.contents?.md5 == contentRelated.md5;
      state = state.copyWith(
        metadata: contentRelated,
        replay: result.data,
        mods: result.data?.mods ?? {},
        clearContents: !hasSameContents,
      );

      _logger.debug("Loaded replay with hash ${replay!.hash}");
      rootNavigatorKey.currentContext?.go("/scoring");
    }

    if (result is ParseResult<BeatmapContent>) {
      if (state.metadata?.md5 == result.data?.md5) {
        state = state.copyWith(contents: result.data);
      }
    }
  }

  void _applyMods(Set<ConfigurableMod> mods) {
    for (final mod in state.mods) {
      mod.deactivate(globalRef);
    }

    for (final mod in mods) {
      mod.activate(globalRef);
    }
  }

  /// Toggles a mod on or off.
  ///
  /// If [mod] is already active, it is removed. Otherwise, all mods that are
  /// incompatible with [mod] are removed first, then [mod] is added.
  /// The resulting set is re-ordered to match [ConfigurableMod.allOrdered].
  void toggleMod(ConfigurableMod mod) {
    Set<ConfigurableMod> remainMods = {};

    final storedMod = state.mods.firstWhereOrNull((m) => m.mod == mod.mod);

    if (storedMod != null) {
      // Deactivate mod
      storedMod.deactivate(globalRef);

      remainMods = Set.of(state.mods)..remove(storedMod);
    } else {
      final incompatibles = <ConfigurableMod>[];
      final remaining = <ConfigurableMod>[];

      // Single pass: separate incompatible mods from remaining ones
      for (final m in state.mods) {
        if (mod.incompatibleMods.any((im) => im.mod == m.mod)) {
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
        .where((m) => remainMods.any((r) => r.mod == m.mod))
        .toSet();

    state = state.copyWith(mods: result);
  }

  /// Removes the active replay while keeping the selected mods.
  void clearReplay() => state = state.copyWith(clearReplay: true);

  /// Removes all active mods.
  void clearMods() {
    // Deactivate all mods
    _applyMods(<ConfigurableMod>{});
    state = state.copyWith(mods: {});
  }

  /// Removes both the active replay and all mods.
  void clearAll() {
    _applyMods(<ConfigurableMod>{});
    state = state.copyWith(clearReplay: true, mods: {});
  }
}

final gameplayDataProvider = NotifierProvider<GameplayData, GameplayInfo>(
  () => GameplayData(),
);

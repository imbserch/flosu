import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flosu/features/audio/data/audio_provider.dart';
import 'package:flosu/logic/providers/beatmap.dart';
import 'package:flosu/shared/router.dart';
import 'package:flosu/logic/services/logger.dart';
import 'package:flosu/features/gameplay/data/gameplay_info.dart';
import 'package:flosu/models/mods/base.dart';
import 'package:flosu/shared/services/io/io_result.dart';
import 'package:flosu/shared/services/io/io_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class GameplayData extends Notifier<GameplayInfo> {
  @override
  GameplayInfo build() {
    final parserStream = ref.read(ioProvider).resultStream;
    final changedSources = ref.read(audioProvider.notifier).changedSources;

    changedSources.addListener(() => _applyMods(state.mods));
    final parserSubs = parserStream
        .where((res) => res is IoReplayResult || res is IoBeatmapContentResult)
        .listen(_handleResult);

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

  void _handleResult(IoResult result) async {
    switch (result) {
      case IoBeatmapContentResult m:
        final content = m.data;
        if (state.metadata?.md5 == content.md5) {
          state = state.copyWith(contents: result.data);
        }
      case IoReplayResult r:
        final replay = r.data;

        final contentRelated = ref
            .read(beatmapProvider)
            .firstWhereOrNull((b) => b.md5 == replay.hash);

        if (contentRelated == null) {
          return _logger.error(
            "Beatmap not found for replay with hash ${replay.hash}",
          );
        }

        await ref.read(audioProvider.notifier).preview(contentRelated);
        _applyMods(replay.mods);

        final hasSameContents = state.contents?.md5 == contentRelated.md5;
        state = state.copyWith(
          metadata: contentRelated,
          replay: replay,
          mods: replay.mods,
          clearContents: !hasSameContents,
        );

        _logger.debug("Loaded replay with hash ${replay.hash}");
        rootNavigatorKey.currentContext?.go("/scoring");
      default:
        return _logger.error(
          "Received unexpected result type: ${result.runtimeType}",
        );
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

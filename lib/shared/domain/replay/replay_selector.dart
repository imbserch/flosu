import 'package:collection/collection.dart';
import 'package:flosu/features/song_select/domain/beatmap_library.dart';
import 'package:flosu/shared/domain/beatmap/beatmap_selector.dart';
import 'package:flosu/shared/domain/replay/replay.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flosu/shared/router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ReplaySelector extends Notifier<Replay?> with Logging {
  @override
  Replay? build() {
    return null;
  }

  /// Selects a replay and loads the beatmap.
  ///
  /// Returns true if the replay was selected, false otherwise.
  Future<bool> selectReplay(Replay replay) async {
    if (state == replay) return false;

    final beatmaps = ref.read(beatmapLibrary);
    final matching = beatmaps.firstWhereOrNull((b) => b.hash == replay.hash);

    if (matching != null) {
      final selector = ref.read(beatmapSelector.notifier);

      await selector.loadTrack(matching);
      selector.selectBeatmap(matching, usePreview: true);

      state = replay;
      return true;
    }

    log("Could not find beatmap for replay hash ${replay.hash}", level: .error);
    return false;
  }

  /// Views the results of a replay.
  ///
  /// This will open the results screen.
  /// Returns true if the replay was selected, false otherwise.
  Future<bool> viewResults(Replay replay) async {
    final selected = await selectReplay(replay);

    if (!selected) return false;

    // Delay navigation to next screen until the current frame is done
    // to prevent errors from replay and beatmap state being set and then
    // immediately being replaced by the next screen.
    Future.microtask(() {
      rootNavigatorKey.currentContext?.go("/scoring");
    });

    return true;
  }
}

final replaySelector = NotifierProvider(() => ReplaySelector());

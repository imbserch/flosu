import 'package:flosu/features/song_select/data/repositories/replay_repository.dart';
import 'package:flosu/shared/domain/replay/replay.dart';
import 'package:flosu/shared/logging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReplayLibrary extends Notifier<List<Replay>> with Logging {
  late final ReplayRepository _repository = ref.read(replayRepository);

  @override
  List<Replay> build() {
    requestLogger();

    Future.microtask(() {
      final replaySubs = _repository.stream.listen(
        (replays) => state = replays,
      );

      ref.onDispose(() {
        replaySubs.cancel();
      });
    });

    return [];
  }
}

final replayLibrary = NotifierProvider(() => ReplayLibrary());

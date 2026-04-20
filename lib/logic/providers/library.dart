import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:flosu/core/extensions.dart';
import 'package:flosu/logic/providers/notifications.dart';
import 'package:flosu/logic/providers/storage.dart';
import 'package:flosu/logic/services/library.dart';
import 'package:flosu/models/beatmap/beatmap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryProvider extends Notifier<List<Beatmap>> {
  @override
  List<Beatmap> build() {
    _service = ref.read(libraryService);

    ref.listen(
      storageProvider.select((it) => it.beatmapsPath),
      _listenChanges,
      fireImmediately: true,
    );

    return [];
  }

  late final LibraryService _service;
  late final NotificationProvider _notificationProvider = ref.read(
    notificationProvider.notifier,
  );

  void _listenChanges(_, String? path) async {
    if (path == null) {
      "Beatmaps path removed. Cleaning resources".log;
      state = [];
      return;
    }

    try {
      "Beatmaps path changed. Triggering update...".log;

      final dir = Directory(path);

      final files = dir
          .listSync(followLinks: false, recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith(".osu"));

      _notificationProvider.add(
        "Updating beatmaps",
        "Reading files from library...",
      );

      final futures = files.map(_service.getBeatmapFromFile);
      final beatmaps = await Isolate.run(() => Future.wait(futures));

      _notificationProvider.add(
        "Beatmaps updated",
        "Finished reading files from library",
      );

      state = beatmaps.nonNulls.toList();
    } catch (err) {
      "Error reading files from library: $err".log;
    }
  }

  Beatmap? getRandom() {
    if (state.isEmpty) return null;

    int randomGroup = Random().nextInt(state.length);
    //int randomBeatmap = Random().nextInt(state.asGroups[randomGroup].length);

    return state[randomGroup];
  }
}

final libraryProvider = NotifierProvider<LibraryProvider, List<Beatmap>>(
  () => LibraryProvider(),
);

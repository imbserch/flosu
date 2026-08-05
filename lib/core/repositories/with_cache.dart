import 'dart:async';

import 'package:flosu/core/repositories/repository.dart';

/// A [Repository] with cache.
/// Use this when you want to cache the data in memory.
abstract class RepositoryWithCache<T extends Object> extends Repository<T> {
  RepositoryWithCache() {
    controller
      ..onListen = () {
        if (cache != null) controller.add(cache!);
      }
      ..onCancel = () {};
  }

  /// The controller of the cached data stream.
  /// This is used to notify listeners of changes in the cache.
  final controller = StreamController<T>.broadcast();

  /// The stream of the repository.
  /// Use this to listen for changes in the repository.
  Stream<T> get stream => controller.stream;

  /// The cache of the repository.
  T? get cache;

  /// Notifies listeners of changes in the cache.
  void notify() {
    if (cache != null) controller.add(cache!);
  }

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }
}

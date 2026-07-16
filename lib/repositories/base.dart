import 'dart:async';

import 'package:flosu/logic/services/logger.dart';

/// Base class for all repositories.
/// Use this when you need a repository that can be initialized,
/// fetched from an external source, updated, and checked for initialization status.
abstract class Repository<T extends Object> {
  /// Logger for the repository.
  late final ScopedLogger logger = Logger.requestLogger("$runtimeType");

  /// Checks if the repository is initialized.
  bool get isInitialized;

  /// Initializes the repository.
  FutureOr<void> init();

  /// Fetches the repository from an external source.
  FutureOr<void> get();

  /// Updates the repository with the given data.
  FutureOr<void> update(T data);

  void dispose();
}

/// A [Repository] with cache.
/// Use this when you want to cache the data in memory.
abstract class CachedRepository<T extends Object> extends Repository<T> {
  CachedRepository() {
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
  }
}

/// A [Repository] that debounces updates to a cache.
/// This is useful for [Repository] that update their cache frequently.
abstract class DebouncedRepository<T extends Object>
    extends CachedRepository<T> {
  /// The delay between updates.
  Duration get delay;

  /// The pending cache update.
  T? pendingCache;

  /// The commited cache.
  T? _commitedCache;

  /// The debounce timer.
  Timer? _debounceTimer;

  @override
  T? get cache => pendingCache ?? _commitedCache;

  T? get commitedCache => _commitedCache;

  /// Sets the new pending update. Override this if you need to persist cache.
  void setUpdate(T data) {
    _commitedCache = data;
  }

  @override
  FutureOr<void> update(T data) {
    // Set new pending data
    pendingCache = data;

    // Notify listeners of changes in cache
    notify();

    // Debounce the update
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, () {
      final dataToCache = pendingCache;

      pendingCache = null;
      _debounceTimer?.cancel();

      if (dataToCache != null) {
        setUpdate(dataToCache);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

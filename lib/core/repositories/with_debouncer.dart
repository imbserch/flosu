import 'dart:async';

import 'package:flosu/core/repositories/with_cache.dart';

/// A [Repository] that debounces updates to a cache.
/// This is useful for [Repository] that update their cache frequently.
abstract class RepositoryWithDebouncer<T extends Object>
    extends RepositoryWithCache<T> {
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

import 'dart:async';

import 'package:flosu/shared/logging.dart';

/// Base class for all repositories.
/// Use this when you need a repository that can be initialized,
/// fetched from an external source, updated, and checked for initialization status.
abstract class Repository<T extends Object> with Logging {
  /// Checks if the repository is initialized.
  bool get isInitialized;

  /// Initializes the repository.
  FutureOr<void> init() {
    requestLogger();
  }

  void dispose() {
    removeLogger();
  }
}

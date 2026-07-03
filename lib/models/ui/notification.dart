import 'package:flosu/core/enums.dart';

/// Represents a UI notification alert configuration.
class Notification {
  Notification({required this.message, required this.type, this.callback});

  final String message;
  final NotificationType type;
  final void Function()? callback;
}

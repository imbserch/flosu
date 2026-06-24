import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationProvider extends Notifier<List<Notification>> {
  @override
  List<Notification> build() => [];

  void add(
    String message, [
    NotificationType type = .info,
    void Function()? callback,
  ]) {
    Future.microtask(
      () => state = [
        ...state,
        Notification(message: message, type: type, callback: callback),
      ],
    );
  }

  void remove(Notification notification) {
    Future.microtask(
      () => state = state.where((it) => it != notification).toList(),
    );
  }

  void clear() => Future.microtask(() => state = []);
}

final notificationProvider =
    NotifierProvider<NotificationProvider, List<Notification>>(
      () => NotificationProvider(),
    );

//TODO: MOVE OUTSIDE OF LOGIC FOLDER, THIS IS UI RELATED
class Notification {
  Notification({required this.message, required this.type, this.callback});

  final String message;
  final NotificationType type;
  final void Function()? callback;
}

enum NotificationType { info, normal, warning, error }

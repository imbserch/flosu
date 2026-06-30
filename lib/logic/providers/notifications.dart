import 'package:flosu/core/enums.dart';
import 'package:flosu/models/ui/notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:flosu/core/enums.dart' show NotificationType;
export 'package:flosu/models/ui/notification.dart' show Notification;

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

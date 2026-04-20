import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationProvider extends Notifier<List<Notification>> {
  @override
  List<Notification> build() => [];

  void add(String title, String message) {
    Future.microtask(
      () => state = [...state, Notification(title: title, message: message)],
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

//TODO: add type (error, info, success) and maybe an optional action (e.g. open beatmap)
//TODO: MOVE OUTSIDE OF LOGIC FOLDER, THIS IS UI RELATED
class Notification {
  Notification({
    required this.title,
    required this.message,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  final String title;
  final String message;
  final DateTime timestamp;
}

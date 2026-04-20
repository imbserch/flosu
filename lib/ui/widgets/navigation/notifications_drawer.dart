import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/notifications.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsDrawer extends ConsumerWidget {
  const NotificationsDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);

    return Drawer(
      width: 192,
      elevation: 16,
      backgroundColor: AppColors.middle(
        AppColors.background,
        AppColors.container,
      ),
      shape: const RoundedRectangleBorder(),
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverList.separated(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications.reversed.elementAt(index);

                return NotificationWidget(
                  notification: notification,
                  onClose: () => ref
                      .read(notificationProvider.notifier)
                      .remove(notification),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 4),
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({
    super.key,
    required this.notification,
    required this.onClose,
  });

  final Notification notification;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 4,
      children: [
        Container(
          width: 2,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.green,
            boxShadow: [
              BoxShadow(
                color: AppColors.green.withAlpha(128),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
            borderRadius: .circular(1),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: .circular(4),
              color: AppColors.middle(
                AppColors.container,
                AppColors.containerHigh,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              spacing: 8,
              children: [
                Container(
                  width: 16,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.middle(
                      AppColors.container,
                      AppColors.containerLow,
                    ),
                  ),
                  child: const Icon(Icons.notifications, size: 10),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        notification.message,
                        style: const TextStyle(fontSize: 6),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  padding: const .all(4),
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 10),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flosu/core/theme/app_colors.dart';
import 'package:flutter/material.dart' hide Notification;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsDrawer extends ConsumerWidget {
  const NotificationsDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      width: 192,
      elevation: 16,
      backgroundColor: AppColors.middle(
        AppColors.background,
        AppColors.container,
      ),
      shape: const RoundedRectangleBorder(),
      child: const Center(),
    );
  }
}

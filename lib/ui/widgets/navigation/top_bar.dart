import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/extensions.dart';

class TopBar extends ConsumerStatefulWidget {
  const TopBar({super.key, required this.onSettingsTap});

  final VoidCallback onSettingsTap;

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  final _startTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final running = now.difference(_startTime);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });

    return ColoredBox(
      color: const Color(0xff191919),
      child: IconTheme(
        data: context.theme.iconTheme.copyWith(size: 14),
        child: Row(
          children: [
            IconButton(
              onPressed: widget.onSettingsTap,
              icon: const Icon(Icons.settings),
            ),
            const Spacer(),
            IconButton(onPressed: () {}, icon: const Icon(Icons.rss_feed)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.code)),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.class_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.leaderboard_outlined),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.library_music_outlined),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.chat_outlined)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.language)),
            IconButton(
              onPressed: () {},
              icon: Stack(
                alignment: .center,
                children: [
                  const Icon(Icons.queue_music),
                  Transform.translate(
                    offset: const Offset(10, 0),
                    child: Transform.rotate(
                      angle: -pi / 2,
                      child: SizedBox(
                        width: 12,
                        height: 2,
                        child: LinearProgressIndicator(
                          value: .5,
                          borderRadius: .circular(2),
                          stopIndicatorRadius: 0,
                          minHeight: 2,
                          trackGap: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: Row(
                spacing: 4,
                mainAxisSize: .min,
                children: [
                  const Text(
                    "Guest",
                    style: TextStyle(fontSize: 10, height: 1),
                  ),
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: .circular(4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              onPressed: () {},
              icon: SizedBox(
                width: 56,
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    Text(
                      now.formatted,
                      style: const TextStyle(fontSize: 10, height: 1),
                    ),
                    Text(
                      "Running ${running.formatted}",
                      style: const TextStyle(
                        color: Colors.pinkAccent,
                        fontSize: 6,
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Badge(
                isLabelVisible: true,
                smallSize: 4,
                offset: Offset(4, 0),
                backgroundColor: Colors.red,
                child: Icon(Icons.notification_important),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flosu/core/enums.dart';
import 'package:flosu/core/extensions/ui.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/shared/logging/log.dart';
import 'package:flosu/shared/logging/logger.dart';
import 'package:flutter/material.dart';

class LogConsole extends StatelessWidget {
  const LogConsole({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Log>>(
      valueListenable: Logger.instance.logs,
      builder: (context, logsList, _) {
        if (logsList.isEmpty) return const SizedBox.shrink();

        return Align(
          alignment: .bottomLeft,
          child: Container(
            margin: const EdgeInsets.all(4),
            width: 300,
            decoration: BoxDecoration(
              borderRadius: .circular(4),
              color: AppColors.containerLow.withAlpha(128),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.all(4),
              itemCount: logsList.length,
              itemBuilder: (context, index) {
                final log = logsList[index];

                Color levelColor = Colors.white;

                switch (log.level) {
                  case LogLevel.success:
                    levelColor = const Color(0xFF66FF6E);
                    break;
                  case LogLevel.debug:
                    levelColor = const Color(0xff66ccff);
                    break;
                  case LogLevel.info:
                    levelColor = Colors.white70;
                    break;
                  case LogLevel.warning:
                    levelColor = const Color(0xffFDD965);
                    break;
                  case LogLevel.error:
                    levelColor = const Color(0xffff6666);
                    break;
                }

                return Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "${log.level.name.toUpperCase()} (${log.tag}) ",
                        style: TextStyle(
                          fontSize: 6,
                          color: levelColor,
                          fontWeight: .bold,
                        ),
                      ),
                      if (log.message.characters.length > 80)
                        const TextSpan(
                          text: "\n",
                          style: TextStyle(fontSize: 6),
                        ),
                      TextSpan(
                        text: log.message,
                        style: const TextStyle(fontSize: 6, height: 1),
                      ),
                    ],
                  ),
                );

                /* return Row(
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(
                      width: 56,
                      child: Text(
                        log.level.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 6,
                          color: levelColor,
                          fontWeight: .bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        log.message,
                        style: const TextStyle(fontSize: 6),
                      ),
                    ),
                  ],
                ); */
              },
            ),
          ),
        );
      },
    ).hiddenCursor;
  }
}

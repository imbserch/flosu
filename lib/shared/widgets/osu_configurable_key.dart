import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flosu/core/theme/app_colors.dart';

class OsuConfigurableKey extends StatelessWidget {
  const OsuConfigurableKey({super.key, required this.keyId});

  final int keyId;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.containerLow,
        borderRadius: .circular(4),
      ),
      width: 40,
      alignment: .center,
      padding: const .all(2),
      child: Text(
        LogicalKeyboardKey.findKeyByKeyId(keyId)?.keyLabel ?? "",
        textAlign: .center,
        style: const TextStyle(
          fontFamily: "Venera",
          fontSize: 8,
          fontWeight: .bold,
        ),
      ),
    );
  }
}

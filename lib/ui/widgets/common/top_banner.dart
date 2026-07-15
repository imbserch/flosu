import 'package:flutter/material.dart';

class TopBanner extends StatelessWidget {
  const TopBanner({super.key, required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const .symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: .circular(8),
          bottomRight: .circular(8),
        ),
        color: Color(0xff293d2a),
      ),
      child: Container(
        margin: const .only(bottom: 8),
        padding: const .symmetric(horizontal: 64, vertical: 10),
        decoration: BoxDecoration(
          border: BoxBorder.fromLTRB(
            bottom: const BorderSide(color: Color(0xff38543a)),
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: .circular(8),
            bottomRight: .circular(8),
          ),
          color: const Color(0xff334c35),
        ),
        child: Column(
          spacing: 2,
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, height: 1)),
            Text(description, style: const TextStyle(fontSize: 6, height: 1)),
          ],
        ),
      ),
    );
  }
}

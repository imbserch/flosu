import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/logic/providers/storage.dart';

class VolumeBar extends ConsumerStatefulWidget {
  const VolumeBar({super.key});

  @override
  ConsumerState<VolumeBar> createState() => _VolumeBarState();
}

class _VolumeBarState extends ConsumerState<VolumeBar> {
  late ProviderSubscription<double> _volSub;

  late double _volume = ref.read(storageProvider).globalVolume;
  bool _showPanels = false;
  Timer? _panelHideTimer;

  @override
  initState() {
    _volSub = ref.listenManual(
      storageProvider.select((it) => it.globalVolume),
      _triggerVolumeChange,
    );
    super.initState();
  }

  @override
  void dispose() {
    _volSub.close();
    super.dispose();
  }

  void _triggerVolumeChange(double? old, double current) {
    if (current != _volume) {
      _panelHideTimer?.cancel();
      _panelHideTimer = Timer(const Duration(seconds: 1), () {
        if (mounted) setState(() => _showPanels = false);
      });

      _volume = current;
      _showPanels = true;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder(
        curve: Curves.easeOut,
        duration: Durations.medium1,
        tween: Tween(end: _showPanels ? 1.0 : 0.0),
        builder: (_, t, child) => Opacity(opacity: t, child: child),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black87, Colors.transparent],
              stops: [0, .25],
            ),
          ),
          alignment: .centerLeft,
          child: Row(
            spacing: 8,
            children: [
              Container(
                height: 96,
                width: 96,
                margin: const .only(left: 8),
                decoration: BoxDecoration(
                  shape: .circle,
                  color: Color.lerp(Colors.black, Colors.pink, .15),
                  boxShadow: [
                    const BoxShadow(
                      color: Colors.pink,
                      blurRadius: 2,
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: TweenAnimationBuilder(
                  curve: Curves.easeOut,
                  duration: Durations.medium1,
                  tween: Tween(end: _volume),
                  builder: (_, t, child) => Stack(
                    fit: .expand,
                    children: [
                      Padding(
                        padding: const .all(12),
                        child: Transform.rotate(
                          angle: pi,
                          child: CircularProgressIndicator(
                            value: .75 * t,
                            color: Colors.pink.shade100,
                            strokeWidth: 1,
                            strokeCap: .round,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          (t * 100).ceil().toStringAsFixed(0),
                          style: const TextStyle(fontFamily: "Venera"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const .symmetric(horizontal: 22, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: .circular(6),
                ),
                child: const Text(
                  "MASTER",
                  style: TextStyle(fontSize: 8, fontWeight: .bold, height: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

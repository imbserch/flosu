import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flosu/core/theme/app_colors.dart';
import 'package:flosu/logic/providers/storage.dart';
//import 'package:flosu/providers/tooltip_service.dart';
import 'package:flosu/ui/widgets/common/osu_button.dart';
import 'package:flosu/ui/widgets/common/osu_checkbox.dart';
import 'package:flosu/ui/widgets/common/osu_configurable_key.dart';
import 'package:flosu/ui/widgets/common/osu_slider.dart';

class SettingsDrawer extends ConsumerWidget {
  const SettingsDrawer({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.read(storageProvider.notifier);
    final config = ref.watch(storageProvider);

    //final tooltipManager = ref.read(tooltipService.notifier);

    return Drawer(
      width: 352,
      elevation: 16,
      backgroundColor: AppColors.middle(
        AppColors.background,
        AppColors.container,
      ),
      shape: const RoundedRectangleBorder(),
      child: Row(
        children: [
          Container(
            width: 112,
            height: double.maxFinite,
            decoration: BoxDecoration(
              color: AppColors.middle(
                AppColors.containerLow,
                AppColors.background,
              ),
            ),
          ),
          Expanded(
            child: ScrollConfiguration(
              behavior: const MaterialScrollBehavior().copyWith(
                dragDevices: PointerDeviceKind.values.toSet(),
                physics: const BouncingScrollPhysics(),
              ),
              child: CustomScrollView(
                slivers: [
                  SliverList.list(
                    children: [
                      SettingsSection(
                        label: "Input",
                        groups: [
                          SettingsGroup(
                            label: "Osu! bindings",
                            items: [
                              SettingsItem(
                                label: "Key 1",
                                control: OsuConfigurableKey(
                                  keyId: config.osuK1,
                                ),
                              ),
                              SettingsItem(
                                label: "Key 2",
                                control: OsuConfigurableKey(
                                  keyId: config.osuK2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SettingsDivider(),
                      SettingsSection(
                        label: "Graphics",
                        groups: [
                          SettingsGroup(
                            label: "Layout",
                            items: [
                              SettingsItem(
                                label: "Parallax",
                                control: OsuCheckbox(
                                  value: config.parallax,
                                  onChange: storage.setParallax,
                                ),
                              ),
                            ],
                          ),
                          SettingsGroup(
                            label: "Background",
                            items: [
                              SettingsItem(
                                label: "Background Dim",
                                valueLabel:
                                    "${(config.backgroundDim * 100).round()}%",
                                control: Expanded(
                                  child: OsuSlider(
                                    min: 0,
                                    max: 1,
                                    value: config.backgroundDim,
                                    onChanged: storage.setBackgroundDim,
                                  ),
                                ),
                              ),
                              SettingsItem(
                                label: "Background Blur",
                                valueLabel:
                                    "${(config.backgroundBlur * 100).round()}%",
                                control: Expanded(
                                  child: OsuSlider(
                                    min: 0,
                                    max: 1,
                                    value: config.backgroundBlur,
                                    onChanged: storage.setBackgroundBlur,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SettingsGroup(
                            label: "Gameplay",
                            items: [
                              SettingsItem(
                                label: "Snaking Sliders",
                                control: OsuCheckbox(
                                  value: config.snakingSliders,
                                  onChange: storage.setSnakingSliders,
                                ),
                              ),
                              SettingsItem(
                                label: "Cursor Trail",
                                control: OsuCheckbox(
                                  value: config.showCursorTrail,
                                  onChange: storage.setCursorTrail,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SettingsDivider(),
                      SettingsSection(
                        label: "Audio",
                        groups: [
                          SettingsGroup(
                            label: "Volume",
                            items: [
                              SettingsItem(
                                label: "General",
                                valueLabel:
                                    "${(config.globalVolume * 100).round()}%",
                                control: Expanded(
                                  child: OsuSlider(
                                    min: 0,
                                    max: 1,
                                    value: config.globalVolume,
                                    onChanged: storage.setGlobalVolume,
                                  ),
                                ),
                              ),
                              SettingsItem(
                                label: "Music",
                                valueLabel:
                                    "${(config.musicVolume * 100).round()}%",
                                control: Expanded(
                                  child: OsuSlider(
                                    min: 0,
                                    max: 1,
                                    value: config.musicVolume,
                                    onChanged: storage.setMusicVolume,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SettingsGroup(
                            label: "Compensation",
                            items: [
                              SettingsItem(
                                label: "Global compensation",
                                valueLabel: "${config.audioCompensation} ms",
                                control: Expanded(
                                  child: OsuSlider(
                                    min: -200,
                                    max: 200,
                                    value: config.audioCompensation.toDouble(),
                                    onChanged: (comp) => storage
                                        .setAudioCompensation(comp.round()),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SettingsDivider(),
                      SettingsSection(
                        label: "Maintenance",
                        groups: [
                          SettingsGroup(
                            label: "Beatmaps",
                            items: [
                              OsuButton(
                                onPressed: () {
                                  storage.setBeatmapsPath();
                                  onClose();
                                },

                                child: const Text("Import beatmaps"),
                              ),
                              OsuButton(
                                onPressed: () {
                                  storage.clearBeatmapsPath();
                                  onClose();
                                },

                                child: const Text("Reset beatmaps folder"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 4, thickness: 4, color: AppColors.background);
  }
}

//TODO: MODIFY
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.label,
    this.groups = const [],
  });

  final String label;
  final List<SettingsGroup> groups;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 8,
        children: [
          Padding(
            padding: const .symmetric(horizontal: 12),
            child: Text(label),
          ),
          const SizedBox.shrink(),
          ...groups,
        ],
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.label, this.items = const []});

  final String label;
  final List<Widget> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .stretch,
      spacing: 4,
      children: [
        Padding(
          padding: const .symmetric(horizontal: 12),
          child: Text(label, style: const TextStyle(fontSize: 10)),
        ),
        const SizedBox.shrink(),
        for (final item in items)
          if (item is SettingsItem)
            item
          else
            Padding(padding: const .symmetric(horizontal: 12), child: item),
      ],
    );
  }
}

class SettingsItem extends StatelessWidget {
  const SettingsItem({
    super.key,
    required this.label,
    this.valueLabel,
    this.control,
  });

  final String label;
  final String? valueLabel;
  final Widget? control;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: .circular(8),
      ),
      margin: const .symmetric(horizontal: 12),
      padding: const .fromLTRB(8, 6, 6, 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: 2,
              children: [
                Text(label, style: const TextStyle(fontSize: 8, height: 1)),
                if (valueLabel != null)
                  Text(
                    "$valueLabel",
                    style: const TextStyle(
                      fontSize: 7,
                      height: 1,
                      fontWeight: .bold,
                    ),
                  ),
              ],
            ),
          ),
          ?control,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_browser/core/components/toggle_button.dart';
import 'package:github_browser/features/settings_theme_switch/providers/theme_mode_provider.dart';
import 'package:github_browser/l10n/app_localizations.dart';

class ThemeSettingToggle extends ConsumerStatefulWidget {
  const ThemeSettingToggle({super.key});

  @override
  ConsumerState<ThemeSettingToggle> createState() => _ThemeSettingToggleState();
}

class _ThemeSettingToggleState extends ConsumerState<ThemeSettingToggle> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(AppLocalizations.of(context).settings_toggle_darkMode),
        ToggleButton(
          isActive: themeMode == ThemeMode.light ? false : true,
          isToggledCallback: (bool isToggled) {
            ref.read(themeModeProvider.notifier).setThemeMode(
              isToggled
              ? ThemeMode.dark 
              : ThemeMode.light
            );
          },
        )
      ],
    );
  }
}

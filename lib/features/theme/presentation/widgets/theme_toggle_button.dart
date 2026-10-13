// Path: features/theme/presentation/widgets/theme_toggle_button.dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:infinite_image_gallery_pixabay/features/theme/presentation/bloc/theme_cubit.dart";

/// One AppBar button used by gallery, detail and favorites (DRY).
/// Icon mirrors the current mode; tap cycles system → light → dark.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeMode mode = context.select<ThemeCubit, ThemeMode>(
      (ThemeCubit c) => c.state,
    );
    return IconButton(
      tooltip: "Theme: ${mode.name}",
      icon: Icon(
        switch (mode) {
          ThemeMode.light => Icons.light_mode_outlined,
          ThemeMode.dark => Icons.dark_mode_outlined,
          ThemeMode.system => Icons.brightness_auto_outlined,
        },
      ),
      onPressed: () => context.read<ThemeCubit>().cycleTheme(),
    );
  }
}

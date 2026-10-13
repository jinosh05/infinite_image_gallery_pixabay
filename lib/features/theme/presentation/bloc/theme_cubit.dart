// Path: features/theme/presentation/bloc/theme_cubit.dart
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:shared_preferences/shared_preferences.dart";

/// App theme mode. State IS the [ThemeMode] (no wrapper needed for a single
/// enum). Persisted as its name; unknown/missing values fall back to system.
/// Provided globally above `MaterialApp`, so `themeMode` rebuilds the app.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit({required this.prefs}) : super(ThemeMode.system) {
    _load();
  }

  final SharedPreferences prefs;

  static const String storageKey = "theme_mode_v1";

  Future<void> _load() async {
    final String? raw = prefs.getString(storageKey);
    final ThemeMode mode = ThemeMode.values.firstWhere(
      (ThemeMode m) => m.name == raw,
      orElse: () => ThemeMode.system,
    );
    if (mode != state) emit(mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    if (mode == state) return;
    await prefs.setString(storageKey, mode.name);
    emit(mode);
  }

  /// Cycles system → light → dark → system (single AppBar entry point).
  Future<void> cycleTheme() => setTheme(
        switch (state) {
          ThemeMode.system => ThemeMode.light,
          ThemeMode.light => ThemeMode.dark,
          ThemeMode.dark => ThemeMode.system,
        },
      );
}

// Path: test/features/theme/presentation/bloc/theme_cubit_test.dart
import "package:bloc_test/bloc_test.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:infinite_image_gallery_pixabay/features/theme/presentation/bloc/theme_cubit.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  late SharedPreferences prefs;

  Future<void> seedPrefs(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    prefs = await SharedPreferences.getInstance();
  }

  setUp(() async {
    await seedPrefs(<String, Object>{});
  });

  group("ThemeCubit loading", () {
    test("starts in system mode with empty prefs", () async {
      final ThemeCubit cubit = ThemeCubit(prefs: prefs);
      expect(cubit.state, ThemeMode.system);
      await cubit.close();
    });

    test("loads the persisted mode synchronously", () async {
      await seedPrefs(<String, Object>{ThemeCubit.storageKey: "dark"});
      final ThemeCubit cubit = ThemeCubit(prefs: prefs);
      expect(cubit.state, ThemeMode.dark);
      await cubit.close();
    });

    test("unknown stored value falls back to system", () async {
      await seedPrefs(<String, Object>{ThemeCubit.storageKey: "neon"});
      final ThemeCubit cubit = ThemeCubit(prefs: prefs);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(cubit.state, ThemeMode.system);
      await cubit.close();
    });
  });

  group("ThemeCubit mutations", () {
    blocTest<ThemeCubit, ThemeMode>(
      "setTheme persists and emits",
      build: () => ThemeCubit(prefs: prefs),
      act: (ThemeCubit cubit) => cubit.setTheme(ThemeMode.dark),
      expect: () => <ThemeMode>[ThemeMode.dark],
      verify: (_) {
        expect(prefs.getString(ThemeCubit.storageKey), "dark");
      },
    );

    blocTest<ThemeCubit, ThemeMode>(
      "duplicate setTheme emits nothing",
      build: () => ThemeCubit(prefs: prefs),
      act: (ThemeCubit cubit) => cubit.setTheme(ThemeMode.system),
      expect: () => <ThemeMode>[],
    );

    blocTest<ThemeCubit, ThemeMode>(
      "cycles system → light → dark → system",
      build: () => ThemeCubit(prefs: prefs),
      act: (ThemeCubit cubit) async {
        await cubit.cycleTheme();
        await cubit.cycleTheme();
        await cubit.cycleTheme();
      },
      expect: () => <ThemeMode>[
        ThemeMode.light,
        ThemeMode.dark,
        ThemeMode.system,
      ],
    );
  });
}

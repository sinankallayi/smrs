import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'theme_provider.g.dart';

// Keys for SharedPreferences
const String kThemeModeKey = 'theme_mode';
const String kColorKey = 'theme_color';

@riverpod
class ThemeController extends _$ThemeController {
  @override
  Future<ThemeState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final modeIndex = prefs.getInt(kThemeModeKey) ?? ThemeMode.light.index;
    final colorValue = prefs.getInt(kColorKey) ?? Colors.blue.value;

    return ThemeState(
      themeMode: ThemeMode.values[modeIndex],
      seedColor: Color(colorValue),
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kThemeModeKey, mode.index);
  }

  Future<void> updateColor(Color color) async {
    state = AsyncData(state.requireValue.copyWith(seedColor: color));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(kColorKey, color.value);
  }
}

class ThemeState {
  final ThemeMode themeMode;
  final Color seedColor;

  ThemeState({required this.themeMode, required this.seedColor});

  ThemeState copyWith({ThemeMode? themeMode, Color? seedColor}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }
}

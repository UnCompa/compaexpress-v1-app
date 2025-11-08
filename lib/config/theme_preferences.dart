import 'package:flutter/material.dart';

class ThemePreferences {
  final ThemeMode themeMode;
  final Color seedColor;

  ThemePreferences({required this.themeMode, required this.seedColor});

  ThemePreferences copyWith({ThemeMode? themeMode, Color? seedColor}) {
    return ThemePreferences(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
    );
  }

  Map<String, dynamic> toJson() {
    return {'themeMode': themeMode.index, 'seedColor': seedColor.value};
  }

  factory ThemePreferences.fromJson(Map<String, dynamic> json) {
    return ThemePreferences(
      themeMode: ThemeMode.values[json['themeMode'] ?? 0],
      seedColor: Color(json['seedColor'] ?? Colors.blue.value),
    );
  }
}

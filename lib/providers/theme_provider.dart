import 'dart:convert';

import 'package:compaexpress/config/theme_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemePreferences> {
  static const _prefsKey = 'theme_preferences';

  ThemeNotifier()
    : super(
        ThemePreferences(themeMode: ThemeMode.light, seedColor: Colors.blue),
      ) {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_prefsKey);

    if (jsonString != null) {
      try {
        // 1. Decodificar la cadena JSON a un Map<String, dynamic>
        final jsonMap = json.decode(jsonString) as Map<String, dynamic>;

        // 2. Usar el mapa decodificado para crear ThemePreferences
        state = ThemePreferences.fromJson(jsonMap);
      } catch (e) {
        // Opcional: Manejar errores de decodificación o datos corruptos
        print('Error al cargar preferencias de tema: $e');
      }
    }
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. Codificar el Map a una cadena JSON
    final jsonString = json.encode(state.toJson());

    // 2. Guardar la cadena JSON
    await prefs.setString(_prefsKey, jsonString);
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _savePreferences();
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    _savePreferences();
  }

  void toggleTheme() {
    final newMode = state.themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    setThemeMode(newMode);
  }
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemePreferences>((
  ref,
) {
  return ThemeNotifier();
});

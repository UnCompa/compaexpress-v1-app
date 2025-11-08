import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData lightTheme(Color seedColor) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.light,
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.mulishTextTheme(baseTheme.textTheme).copyWith(
        // Mejora legibilidad con pesos de fuente consistentes
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // APPBAR: Usa color primario en lugar de surface
      appBarTheme: AppBarTheme(
        backgroundColor: baseTheme.colorScheme.primary,
        foregroundColor: baseTheme.colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.mulish(
          color: baseTheme.colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: baseTheme.colorScheme.onPrimary),
        actionsIconTheme: IconThemeData(color: baseTheme.colorScheme.onPrimary),
      ),

      // NAVIGATION BAR: Personalizada
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: baseTheme.colorScheme.surface,
        indicatorColor: baseTheme.colorScheme.primary.withOpacity(0.2),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.mulish(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),

      // ELEVATED BUTTON: Mejorado
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: baseTheme.colorScheme.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // CARDS: Usa esquinas redondeadas y borde sutil
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: baseTheme.colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: baseTheme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),

      // FLOATING ACTION BUTTON: Personalizado
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: baseTheme.colorScheme.primary,
        foregroundColor: baseTheme.colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  static ThemeData darkTheme(Color seedColor) {
    final baseTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
        brightness: Brightness.dark,
      ),
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.mulishTextTheme(baseTheme.textTheme).copyWith(
        titleLarge: baseTheme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleMedium: baseTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        titleSmall: baseTheme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),

      // APPBAR: Usa color primario en tema oscuro
      appBarTheme: AppBarTheme(
        backgroundColor: baseTheme.colorScheme.primary,
        foregroundColor: baseTheme.colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.mulish(
          color: baseTheme.colorScheme.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: baseTheme.colorScheme.onPrimary),
        actionsIconTheme: IconThemeData(color: baseTheme.colorScheme.onPrimary),
      ),

      // NAVIGATION BAR: Para tema oscuro
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: baseTheme.colorScheme.surface,
        indicatorColor: baseTheme.colorScheme.primary.withOpacity(0.3),
        labelTextStyle: WidgetStateProperty.all(
          GoogleFonts.mulish(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ),

      // ELEVATED BUTTON: Para tema oscuro
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          shadowColor: baseTheme.colorScheme.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // CARDS: Para tema oscuro
      cardTheme: CardThemeData(
        elevation: 2,
        shadowColor: baseTheme.colorScheme.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: baseTheme.colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),

      // FLOATING ACTION BUTTON: Para tema oscuro
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: baseTheme.colorScheme.primary,
        foregroundColor: baseTheme.colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

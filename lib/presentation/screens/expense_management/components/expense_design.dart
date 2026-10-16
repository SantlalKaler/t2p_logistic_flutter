import 'package:flutter/material.dart';

/// Shared visual language for expense forms and receipt attachments.
class ExpenseDesign {
  static const accent = Color(0xFFB42332);
  static const ink = Color(0xFF182230);
  static const muted = Color(0xFF667085);
  static ThemeData theme(BuildContext context) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
        ).copyWith(
          primary: accent,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: ink,
          onSurfaceVariant: muted,
          outlineVariant: const Color(0xFFE5E7EB),
        );
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Roboto',
    );
    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: width),
        );
    return theme.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      textTheme: theme.textTheme.copyWith(
        titleLarge: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleMedium: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ink,
          height: 1.4,
        ),
        bodyMedium: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: ink,
          height: 1.5,
        ),
        bodySmall: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          color: muted,
          height: 1.5,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFAFBFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 13,
          color: muted,
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          color: muted,
        ),
        floatingLabelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 13,
          color: accent,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: border(const Color(0xFFE4E7EC)),
        enabledBorder: border(const Color(0xFFE4E7EC)),
        focusedBorder: border(accent, 1.5),
        errorBorder: border(scheme.error),
        focusedErrorBorder: border(scheme.error, 1.5),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFAFBFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: Color(0xFFE4E7EC)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(0, 48),
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFD0D5DD)),
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: const TextStyle(
            fontFamily: 'Roboto',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(contentPadding: EdgeInsets.zero),
    );
  }
}

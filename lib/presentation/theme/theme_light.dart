import 'package:flutter/material.dart';

import 'app_design.dart';

class LightTheme {
  static ThemeData getTheme() {
    final theme = AppDesign.theme();
    return theme.copyWith(
      primaryColor: AppDesign.accent,
      primaryColorDark: const Color(0xFF8E1B28),
      primaryColorLight: const Color(0xFFFDF0F1),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppDesign.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFEAECF0),
          disabledForegroundColor: AppDesign.muted,
          elevation: 0,
          minimumSize: const Size(double.infinity, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        style: theme.outlinedButtonTheme.style!.copyWith(
          minimumSize: const WidgetStatePropertyAll(Size(double.infinity, 48)),
        ),
      ),
      cardTheme: theme.cardTheme.copyWith(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Color(0xFFEAECF0)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFFFDF0F1),
        labelStyle: const TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppDesign.ink,
        ),
        deleteIconColor: AppDesign.accent,
        side: const BorderSide(color: Color(0xFFE4E7EC)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppDesign.accent,
        unselectedLabelColor: AppDesign.muted,
        indicatorColor: AppDesign.accent,
        dividerColor: Color(0xFFEAECF0),
        labelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: const WidgetStatePropertyAll(Color(0xFFF8F9FC)),
        elevation: const WidgetStatePropertyAll(0),
        constraints: const BoxConstraints(minHeight: 48),
        hintStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Roboto', fontSize: 12, color: AppDesign.muted),
        ),
        textStyle: const WidgetStatePropertyAll(
          TextStyle(fontFamily: 'Roboto', fontSize: 14, color: AppDesign.ink),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE4E7EC)),
          ),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppDesign.accent,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppDesign.ink,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: 'Roboto',
          fontSize: 12,
          color: AppDesign.muted,
        ),
        iconColor: AppDesign.muted,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppDesign.accent,
      ),
    );
  }
}

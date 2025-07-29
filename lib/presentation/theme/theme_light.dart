import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme {
  static getTheme() {
    return ThemeData(
      useMaterial3: false,
      brightness: Brightness.light,
      primarySwatch: Colors.red,
      scaffoldBackgroundColor: Colors.blueGrey.shade50,
      primaryColor: Colors.red.shade800,
      primaryColorDark: Colors.red.shade900,
      primaryColorLight: Colors.red.shade300,
      primaryIconTheme: IconThemeData(color: Colors.red.shade700),
      iconTheme: const IconThemeData(color: Colors.black87),
      appBarTheme: AppBarTheme(
          backgroundColor: Colors.red.shade900,
          iconTheme: IconThemeData(color: Colors.blueGrey.shade50)),
      cardColor: Colors.grey.shade50,
      cardTheme: CardThemeData(
          color: Colors.grey.shade50,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
      chipTheme: ChipThemeData(
          selectedColor: Colors.red.shade800,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          backgroundColor: Colors.blueGrey.shade100,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
      textTheme: TextTheme(
          labelMedium: GoogleFonts.oswald(
              fontSize: 14, color: const Color(0xFF725B2E), letterSpacing: 1),
          labelSmall: GoogleFonts.oswald(
              fontSize: 14, color: Colors.black87, letterSpacing: 1),
          bodyLarge:
              GoogleFonts.lato(color: Colors.grey.shade600, fontSize: 14),
          bodyMedium:
              GoogleFonts.roboto(color: Colors.blueGrey.shade600, fontSize: 14),
          bodySmall: GoogleFonts.poppins(
              color: Colors.blueGrey.shade500, fontSize: 11),
          titleLarge: GoogleFonts.lato(
              fontWeight: FontWeight.w600, fontSize: 18, color: Colors.black87),
          titleSmall: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87),
          titleMedium: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, color: Colors.black87, height: 1.0)),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            backgroundColor: Colors.red.shade50,
            minimumSize: const Size(double.infinity, 40),
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12))),
            side: const BorderSide(
              color: Colors.red,
            )),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.pressed)) {
                  return Colors.red; // Color when the button is pressed
                }
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey.shade400;
                }
                return Theme.of(Get.context!).primaryColor; // Default color
              }),
              shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)))),
              minimumSize:
                  const MaterialStatePropertyAll(Size(double.infinity, 40)))),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.red.shade700,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        labelStyle:
            GoogleFonts.roboto(color: Colors.grey.shade600, fontSize: 13),
        hintStyle: GoogleFonts.lato(fontSize: 13),
        contentPadding: const EdgeInsets.all(15),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red.shade600),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey;
          }
          return Colors.grey.shade100;
        }),
      ),
      drawerTheme: DrawerThemeData(backgroundColor: Colors.blueGrey.shade50),
      dialogTheme: DialogThemeData(
          contentTextStyle:
              GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 13),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
      listTileTheme: ListTileThemeData(
        titleTextStyle: GoogleFonts.lato(
            fontWeight: FontWeight.w600, fontSize: 14.5, color: Colors.black87),
        iconColor: Colors.black87,
        shape: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
    );
  }
}

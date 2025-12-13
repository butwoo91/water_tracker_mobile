import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF3E8BFF);
  static const secondaryColor = Color(0xFFEAF2FF);
  static const accentColor = Color(0xFFFFC107);

  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.white,
    textTheme: _textTheme,
    appBarTheme: _appBarTheme,
    elevatedButtonTheme: _elevatedButtonTheme,
    outlinedButtonTheme: _outlinedButtonTheme,
    inputDecorationTheme: _inputDecorationTheme,
  );

  static final TextTheme _textTheme = TextTheme(
    displayLarge: GoogleFonts.poppins(
        fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
    displayMedium: GoogleFonts.poppins(
        fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
    titleMedium: GoogleFonts.poppins(
        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
    titleSmall: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, color: Colors.black54),
    bodySmall: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
  );

  static final AppBarTheme _appBarTheme = AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    iconTheme: const IconThemeData(color: primaryColor),
    titleTextStyle: _textTheme.titleMedium,
  );

  static final ElevatedButtonThemeData _elevatedButtonTheme =
      ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: _textTheme.titleSmall,
    ),
  );

  static final OutlinedButtonThemeData _outlinedButtonTheme =
      OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: const BorderSide(color: primaryColor),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: _textTheme.titleSmall,
    ),
  );

  static final InputDecorationTheme _inputDecorationTheme =
      InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: secondaryColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: secondaryColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor),
    ),
    labelStyle: _textTheme.bodyMedium,
  );
}

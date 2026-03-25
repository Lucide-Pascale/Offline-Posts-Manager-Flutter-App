import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color accentYellow = Color(0xFFFFD600);
  static const Color backgroundWhite = Color(0xFFFAFAFA);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF1A1A1A);
  static const Color textDark = Color(0xFF212121);
  static const Color cardShadow = Color(0x1A000000);
  static const Color subtleGrey = Color(0xFF757575);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color errorRed = Color(0xFFB71C1C);

  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: primaryRed,
          onPrimary: surfaceWhite,
          secondary: accentYellow,
          onSecondary: textBlack,
          error: errorRed,
          onError: surfaceWhite,
          surface: surfaceWhite,
          onSurface: textBlack,
        ),
        scaffoldBackgroundColor: backgroundWhite,
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryRed,
          foregroundColor: surfaceWhite,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: surfaceWhite,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          iconTheme: IconThemeData(color: surfaceWhite),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: accentYellow,
          foregroundColor: textBlack,
          elevation: 6,
          shape: CircleBorder(),
        ),
        cardTheme: CardThemeData(
          color: surfaceWhite,
          elevation: 3,
          shadowColor: cardShadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceWhite,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: lightGrey, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: lightGrey, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: primaryRed, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: errorRed, width: 1.5),
          ),
          labelStyle: TextStyle(color: subtleGrey),
          hintStyle: TextStyle(color: subtleGrey),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            foregroundColor: surfaceWhite,
            elevation: 2,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryRed,
            textStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        fontFamily: 'Roboto',
      );
}

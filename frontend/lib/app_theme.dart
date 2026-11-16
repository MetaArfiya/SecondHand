import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF5E548E);
  static const Color accentLavender = Color(0xFFD1C4E9);
  static const Color darkPlum = Color(0xFF2D243D);
  static const Color secondaryPurple = Color(0xFF7E57C2);
  static const Color bgLight = Color(0xFFF8F6FB);
  static const Color bgWhite = Colors.white;
  static const Color bgPurpleTint = Color(0xFFF3E5F5);
  static const Color textGrey = Color(0xFF757575);
  static const Color textLightGrey = Color(0xFF9E9E9E);
  static const Color borderGrey = Color(0xFFE0E0E0);
  static const Color dangerRed = Color(0xFFD32F2F);
  static const Color warningOrange = Color(0xFFEF6C00);

  static const String fontFamily = 'Poppins';

  static const TextStyle heading1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkPlum,
    fontFamily: fontFamily,
  );
  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: darkPlum,
    fontFamily: fontFamily,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: darkPlum,
    fontFamily: fontFamily,
  );
  static const TextStyle body = TextStyle(
    fontSize: 13,
    color: textGrey,
    fontFamily: fontFamily,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: textLightGrey,
    fontFamily: fontFamily,
  );
  static const TextStyle price = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: darkPlum,
    fontFamily: fontFamily,
  );

  static final BorderRadius radiusMd = BorderRadius.circular(12);
  static final BorderRadius radiusSm = BorderRadius.circular(8);

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: bgWhite,
    borderRadius: radiusMd,
    border: Border.all(color: borderGrey.withValues(alpha: 0.5)),
    boxShadow: [
      BoxShadow(
        color: primaryPurple.withValues(alpha: 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: bgLight,
        fontFamily: fontFamily,
        textTheme: const TextTheme(
          headlineLarge: heading1,
          headlineMedium: heading2,
          titleMedium: subtitle,
          titleSmall: price,
          bodyMedium: body,
          bodySmall: caption,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryPurple,
          primary: primaryPurple,
          secondary: accentLavender,
          surface: bgWhite,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgWhite,
          foregroundColor: darkPlum,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: darkPlum,
            fontFamily: fontFamily,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkPlum,
            foregroundColor: bgWhite,
            shape: RoundedRectangleBorder(borderRadius: radiusSm),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgWhite,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: radiusSm,
            borderSide: const BorderSide(color: borderGrey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: radiusSm,
            borderSide: const BorderSide(color: borderGrey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: radiusSm,
            borderSide: const BorderSide(color: primaryPurple, width: 1.5),
          ),
          hintStyle: const TextStyle(color: textLightGrey, fontSize: 13),
        ),
      );
}

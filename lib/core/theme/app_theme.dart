import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Paleta Principal (Crema, Blanco, Negro) ──────────────────────────────
  static const Color ink         = Color(0xFF1A1A1A); // Negro principal
  static const Color inkLight    = Color(0xFF2D2D2D); // Negro secundario
  static const Color cream       = Color(0xFFF7F6F2); // Fondo crema
  static const Color white       = Color(0xFFFFFFFF);
  static const Color border      = Color(0xFFE8E7E3);
  static const Color borderLight = Color(0xFFE0DFD9);
  static const Color muted       = Color(0xFF9B9A96);
  static const Color mutedDark   = Color(0xFF6B6A66);
  static const Color placeholder = Color(0xFFC5C4C0);
  static const Color accent      = Color(0xFF1A1A1A); // Negro como acento
  static const Color danger      = Color(0xFFEF4444);
  static const Color dangerBg    = Color(0xFFFEF2F2);
  static const Color dangerBorder= Color(0xFFFECACA);
  static const Color dangerText  = Color(0xFFDC2626);

  // ── Paleta para Gráficos ──────────────────────────────
  static const List<Color> chartPalette = [
    Color(0xFF120907),
    Color(0xFF2B273F),
    Color(0xFF67638C),
    Color(0xFFAEA2E8),
    Color(0xFFF2E0ED),
  ];

  // ── Tipografía ───────────────────────────────────────
  static TextStyle bebasNeue({
    double fontSize = 24,
    double letterSpacing = 3,
    Color color = ink,
    double height = 1,
  }) =>
      GoogleFonts.bebasNeue(
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );

  static TextStyle sourceSans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    double letterSpacing = 0,
    Color color = ink,
    double? height,
  }) =>
      GoogleFonts.sourceSans3(
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        color: color,
        height: height,
      );

  // ── Tema principal ───────────────────────────────────
  static ThemeData get theme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: ink,
          onPrimary: white,
          secondary: inkLight,
          surface: cream,
          onSurface: ink,
          error: danger,
        ),
        scaffoldBackgroundColor: cream,
        textTheme: GoogleFonts.sourceSans3TextTheme(),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: border),
          ),
          shadowColor: Colors.black12,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: borderLight),
          ),
          enabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: borderLight),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: ink, width: 1.5),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: danger),
          ),
          hintStyle: GoogleFonts.sourceSans3(
              color: placeholder, fontSize: 14),
          labelStyle: GoogleFonts.sourceSans3(color: muted),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: ink,
            foregroundColor: white,
            disabledBackgroundColor: ink.withValues(alpha: 0.5),
            elevation: 0,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: GoogleFonts.sourceSans3(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: inkLight,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: GoogleFonts.bebasNeue(
            fontSize: 22,
            letterSpacing: 3,
            color: white,
          ),
          iconTheme: const IconThemeData(color: white),
          actionsIconTheme: const IconThemeData(color: white),
        ),
        dividerTheme: const DividerThemeData(
          color: border,
          space: 1,
          thickness: 1,
        ),
      );
}
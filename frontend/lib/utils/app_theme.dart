import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand palette — Modern Blue (NO ORANGE!) ──────────────────────
  static const Color primary       = Color(0xFF1966D2); // Modern Blue — brand utama
  static const Color primaryLight  = Color(0xFF3B82F6); // Blue lebih terang
  static const Color primaryXLight = Color(0xFF60A5FA); // Blue paling terang
  static const Color primaryDark   = Color(0xFF1E40AF); // Blue gelap
  static const Color accent        = Color(0xFF2563EB); // Accent Blue
  static const Color accentDark    = Color(0xFF1D4ED8);
  static const Color bg            = Color(0xFFF8FAFC); // Soft white — latar utama
  static const Color surface       = Color(0xFFFFFFFF); // Kartu/putih bersih
  static const Color surface2      = Color(0xFFF1F5F9); // Latar sekunder
  static const Color border        = Color(0xFFE2E8F0); // Border input
  static const Color cardBorder    = Color(0xFFE5E7EB);
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint      = Color(0xFF94A3B8);
  static const Color success       = Color(0xFF22C55E);
  static const Color danger        = Color(0xFFEF4444);
  static const Color warning       = Color(0xFFF59E0B);
  static const Color info          = Color(0xFF2563EB);

  // Radius kartu — lebih modern dengan sudut membulat
  static const double cardRadius = 16;
  static const double cardRadiusLg = 20;

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      surface: surface,
      error: danger,
    ),
    scaffoldBackgroundColor: bg,
    textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
      headlineLarge: _ts(22, FontWeight.w700),
      headlineMedium: _ts(20, FontWeight.w700),
      headlineSmall: _ts(18, FontWeight.w700),
      titleLarge: _ts(16, FontWeight.w700),
      titleMedium: _ts(15, FontWeight.w600),
      bodyLarge: _ts(15, FontWeight.w400),
      bodyMedium: _ts(14, FontWeight.w400),
      bodySmall: _ts(13, FontWeight.w400),
      labelLarge: _ts(13, FontWeight.w600),
      labelSmall: _ts(11, FontWeight.w500),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF0F172A),
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0.5,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0F172A),
      ),
      iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
    )),
    outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(
      foregroundColor: primary,
      side: const BorderSide(color: primary, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
    )),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(
      foregroundColor: primary,
      textStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w600),
    )),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: danger),
      ),
      hintStyle: const TextStyle(color: textHint, fontSize: 14),
      labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
        side: const BorderSide(color: cardBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 0),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textHint,
      elevation: 12,
      selectedLabelStyle: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 11),
      type: BottomNavigationBarType.fixed,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static TextStyle _ts(double size, FontWeight weight) =>
      TextStyle(fontSize: size, fontWeight: weight, color: textPrimary);
}
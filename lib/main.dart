import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'accueil_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivilApp',
      debugShowCheckedModeBanner: false,
      theme: _construireTheme(),
      home: const AccueilPage(),
    );
  }

  /// Thème global de l'application — style moderne 2024/2025
  /// Inspiré des apps gouvernementales scandinaves et de Material 3
  ThemeData _construireTheme() {
    // Palette principale : vert émeraude profond
    const couleurPrimaire = Color(0xFF0A6640);
    const couleurSecondaire = Color(0xFF1A9260);
    const couleurAccent = Color(0xFF00C896);
    const couleurFond = Color(0xFFF2F6F4);
    const couleurSurface = Color(0xFFFFFFFF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: couleurPrimaire,
      primary: couleurPrimaire,
      secondary: couleurSecondaire,
      tertiary: couleurAccent,
      surface: couleurSurface,
      surfaceContainerHighest: const Color(0xFFE8F0EC),
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: couleurFond,

      // --- Typographie ---
      textTheme: TextTheme(
        displayLarge: GoogleFonts.hankenGrotesk(fontSize: 48, fontWeight: FontWeight.w900),
        displayMedium: GoogleFonts.hankenGrotesk(fontSize: 36, fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.hankenGrotesk(fontSize: 28, fontWeight: FontWeight.bold),
        headlineMedium: GoogleFonts.hankenGrotesk(fontSize: 24, fontWeight: FontWeight.w700),
        headlineSmall: GoogleFonts.hankenGrotesk(fontSize: 20, fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w700),
        titleMedium: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w600),
        titleSmall: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.normal),
        bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.normal),
        bodySmall: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.normal),
        labelLarge: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
        labelMedium: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w500),
      ),

      // --- Boutons principaux : pill shape, effet moderne ---
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: couleurPrimaire,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // --- Boutons secondaires : contour net ---
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: couleurPrimaire,
          side: const BorderSide(color: couleurPrimaire, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // --- Boutons texte ---
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: couleurPrimaire,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // --- Cards : légèrement élevées, bords arrondis ---
      cardTheme: CardThemeData(
        color: couleurSurface,
        elevation: 0,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(vertical: 6),
      ),

      // --- Champs de saisie : modernes, fond teinté ---
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F4F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFDDE5E2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: couleurPrimaire, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600, fontSize: 14),
        hintStyle: GoogleFonts.plusJakartaSans(color: Colors.grey.shade400, fontSize: 14),
        prefixIconColor: couleurPrimaire,
      ),

      // --- AppBar : transparente avec titre centré ---
      appBarTheme: AppBarTheme(
        backgroundColor: couleurPrimaire,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.hankenGrotesk(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),

      // --- Chip de filtre ---
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFE8F0EC),
        selectedColor: couleurPrimaire.withValues(alpha: 0.15),
        labelStyle: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: const BorderSide(color: Color(0xFFCDD8D3)),
      ),

      // --- BottomNavigationBar ---
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: couleurSurface,
        selectedItemColor: couleurPrimaire,
        unselectedItemColor: Color(0xFF9EADA8),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // --- Dividers discrets ---
      dividerTheme: const DividerThemeData(
        color: Color(0xFFECF0EE),
        thickness: 1,
        space: 1,
      ),
    );
  }
}

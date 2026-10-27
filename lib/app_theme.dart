import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palette de couleurs sobre et institutionnelle pour CivilApp.
/// Basée sur l'identité officielle : Bleu nuit du logo, surfaces neutres,
/// turquoise pour les validations et statuts codifiés sans dégradés.
class Palette {
  // Couleurs principales
  static const Color primaire = Color(0xFF0A2A57); // Bleu nuit du logo
  static const Color primaireFonce = Color(0xFF071C3A);
  static const Color secondaire = Color(0xFF1E3A8A); // Bleu institutionnel
  static const Color accent = Color(0xFF0B7F86); // Turquoise du logo (assombri pour lisibilité)
  static const Color validation = Color(0xFF0B7F86); // Utilisé pour validations et coches

  // Surfaces et fonds
  static const Color fond = Color(0xFFF5F6F8); // Gris froid très clair
  static const Color surface = Color(0xFFFFFFFF); // Blanc pur pour cartes et fiches
  static const Color surfaceSecondaire = Color(0xFFEEF2F6);
  static const Color surfaceMuted = Color(0xFFE9ECEF);
  static const Color bordure = Color(0xFFD8DDE5); // Bordure fine 1px
  static const Color bordureLegere = Color(0xFFE5E7EB);
  static const Color separateur = Color(0xFFE2E8F0);

  // Textes
  static const Color textePrimaire = Color(0xFF1B2433);
  static const Color texteSecondaire = Color(0xFF5A677B);
  static const Color texteDiscret = Color(0xFF8A99AD);
  static const Color texteSurSombre = Color(0xFFFFFFFF);
  static const Color texteSurSombreMuted = Color(0xFFC7D2FE);

  // Statuts administratifs
  static const Color statutRecue = Color(0xFF1D4ED8); // Bleu institutionnel officiel / Reçue
  static const Color statutRecueFond = Color(0xFFEFF6FF);
  static const Color statutEnCours = Color(0xFFB45309); // Ambre chaud / En cours d'instruction
  static const Color statutEnCoursFond = Color(0xFFFFFBEB);
  static const Color statutPrete = Color(0xFF0B7F86); // Turquoise du logo / Prête
  static const Color statutPreteFond = Color(0xFFF0FDFA);
  static const Color statutLivree = Color(0xFF15803D); // Vert sobre / Livrée
  static const Color statutLivreeFond = Color(0xFFF0FDF4);
  static const Color statutRejetee = Color(0xFFB91C1C); // Rouge sobre / Refusée
  static const Color statutRejeteeFond = Color(0xFFFEF2F2);
  static const Color statutInconnu = Color(0xFF475569);
  static const Color statutInconnuFond = Color(0xFFF1F5F9);

  // Types d'actes d'état civil (palette sobre)
  static const Color acteNaissance = Color(0xFF1E40AF); // Bleu marine
  static const Color acteExtrait = Color(0xFF0D9488); // Bleu sarcelle
  static const Color acteMariage = Color(0xFF6D28D9); // Indigo/Pourpre sobre
  static const Color acteDeces = Color(0xFF475569); // Ardoise

  /// Couleur de badge pour un statut donné
  static Color couleurStatut(String statut) {
    switch (statut.trim().toLowerCase()) {
      case 'reçue':
      case 'recue':
      case 'en attente':
        return statutRecue;
      case 'en cours':
        return statutEnCours;
      case 'prête':
      case 'prete':
        return statutPrete;
      case 'livrée':
      case 'livree':
        return statutLivree;
      case 'rejetée':
      case 'rejetee':
      case 'refusée':
      case 'refusee':
        return statutRejetee;
      default:
        return statutInconnu;
    }
  }

  /// Couleur de fond pour le badge de statut
  static Color fondStatut(String statut) {
    switch (statut.trim().toLowerCase()) {
      case 'reçue':
      case 'recue':
      case 'en attente':
        return statutRecueFond;
      case 'en cours':
        return statutEnCoursFond;
      case 'prête':
      case 'prete':
        return statutPreteFond;
      case 'livrée':
      case 'livree':
        return statutLivreeFond;
      case 'rejetée':
      case 'rejetee':
      case 'refusée':
      case 'refusee':
        return statutRejeteeFond;
      default:
        return statutInconnuFond;
    }
  }

  /// Icône pour un statut donné
  static IconData iconeStatut(String statut) {
    switch (statut.trim().toLowerCase()) {
      case 'reçue':
      case 'recue':
      case 'en attente':
        return Icons.inbox_outlined;
      case 'en cours':
        return Icons.hourglass_top_outlined;
      case 'prête':
      case 'prete':
        return Icons.task_alt_outlined;
      case 'livrée':
      case 'livree':
        return Icons.check_circle_outline;
      case 'rejetée':
      case 'rejetee':
      case 'refusée':
      case 'refusee':
        return Icons.highlight_off_outlined;
      default:
        return Icons.info_outline;
    }
  }
}

/// Badge de statut administratif professionnel, propre et institutionnel.
/// Remplace les pilules pastel délavées "effet IA" par un badge sobre avec puce colorée et bordure nette.
class BadgeStatut extends StatelessWidget {
  final String statut;
  final bool compact;

  const BadgeStatut({
    super.key,
    required this.statut,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final couleur = Palette.couleurStatut(statut);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: compact ? 6 : 7,
            height: compact ? 6 : 7,
            decoration: BoxDecoration(
              color: couleur,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: compact ? 5 : 6),
          Text(
            statut.toUpperCase(),
            style: GoogleFonts.publicSans(
              color: couleur,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thème global de l'application
ThemeData construireThemeCivilApp() {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Palette.primaire,
    primary: Palette.primaire,
    secondary: Palette.secondaire,
    tertiary: Palette.accent,
    surface: Palette.surface,
    surfaceContainerHighest: Palette.surfaceSecondaire,
    onPrimary: Colors.white,
    onSurface: Palette.textePrimaire,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Palette.fond,

    // Typographie unifiée Public Sans
    textTheme: TextTheme(
      displayLarge: GoogleFonts.publicSans(fontSize: 34, fontWeight: FontWeight.bold, color: Palette.textePrimaire),
      displayMedium: GoogleFonts.publicSans(fontSize: 28, fontWeight: FontWeight.bold, color: Palette.textePrimaire),
      headlineLarge: GoogleFonts.publicSans(fontSize: 24, fontWeight: FontWeight.bold, color: Palette.textePrimaire),
      headlineMedium: GoogleFonts.publicSans(fontSize: 20, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
      headlineSmall: GoogleFonts.publicSans(fontSize: 18, fontWeight: FontWeight.w600, color: Palette.textePrimaire),
      titleLarge: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
      titleMedium: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w600, color: Palette.textePrimaire),
      titleSmall: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w600, color: Palette.textePrimaire),
      bodyLarge: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.normal, color: Palette.textePrimaire),
      bodyMedium: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.normal, color: Palette.texteSecondaire),
      bodySmall: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.normal, color: Palette.texteDiscret),
      labelLarge: GoogleFonts.publicSans(fontSize: 13, fontWeight: FontWeight.w600, color: Palette.textePrimaire),
      labelMedium: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500, color: Palette.texteSecondaire),
      labelSmall: GoogleFonts.publicSans(fontSize: 11, fontWeight: FontWeight.w500, color: Palette.texteDiscret),
    ),

    // Boutons surélevés sobres
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Palette.primaire,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Boutons avec bordure nette
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Palette.primaire,
        side: const BorderSide(color: Palette.bordure, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        textStyle: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Boutons textes
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Palette.primaire,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        textStyle: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // Cartes plates avec bordure 1px
    cardTheme: CardTheme(
      color: Palette.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Palette.bordure, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 6),
    ),

    // Champs de saisie administratifs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Palette.bordure, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Palette.bordure, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Palette.primaire, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Palette.statutRejetee, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Palette.statutRejetee, width: 1.5),
      ),
      labelStyle: GoogleFonts.publicSans(color: Palette.texteSecondaire, fontSize: 13),
      hintStyle: GoogleFonts.publicSans(color: Palette.texteDiscret, fontSize: 13),
      prefixIconColor: Palette.texteSecondaire,
    ),

    // Barre d'application sobre et plate
    appBarTheme: AppBarTheme(
      backgroundColor: Palette.primaire,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.publicSans(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),

    // Chips sobres
    chipTheme: ChipThemeData(
      backgroundColor: Palette.surfaceSecondaire,
      selectedColor: Palette.primaire,
      labelStyle: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w500),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: const BorderSide(color: Palette.bordure, width: 1),
    ),

    // Navigation inférieure
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Palette.surface,
      selectedItemColor: Palette.primaire,
      unselectedItemColor: Palette.texteDiscret,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // Séparateurs discrets
    dividerTheme: const DividerThemeData(
      color: Palette.bordure,
      thickness: 1,
      space: 1,
    ),
  );
}

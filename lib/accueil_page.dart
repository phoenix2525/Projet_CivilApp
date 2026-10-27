import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'creer_profil_page.dart';
import 'connexion_agent_page.dart';

/// Page d'accueil officielle de l'application CivilApp.
/// Interface administrative sobre, respectant l'identité visuelle du logo communal.
class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.fond,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Bandeau supérieur institutionnel
              _construireBandeauHaut(),

              // Section centrale : choix de l'espace
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portail des démarches',
                      style: GoogleFonts.publicSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Palette.textePrimaire,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sélectionnez votre profil d\'accès pour continuer.',
                      style: GoogleFonts.publicSans(
                        fontSize: 13,
                        color: Palette.texteSecondaire,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Carte d'accès Espace Citoyen
                    _construireEntree(
                      context,
                      titre: 'Espace Citoyen',
                      description: 'Effectuez une demande d\'acte ou suivez un dossier en cours.',
                      icone: Icons.person_outline_rounded,
                      estPrimaire: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreerProfilPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Carte d'accès Espace Agent Mairie
                    _construireEntree(
                      context,
                      titre: 'Espace Agent Mairie',
                      description: 'Accès réservé au traitement et à la délivrance des actes civils.',
                      icone: Icons.admin_panel_settings_outlined,
                      estPrimaire: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ConnexionAgentPage()),
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // Mention officielle et légale
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.verified_outlined,
                            size: 15,
                            color: Palette.texteDiscret,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'République du Sénégal — Ministère des Collectivités',
                            style: GoogleFonts.publicSans(
                              fontSize: 11,
                              color: Palette.texteDiscret,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bandeau institutionnel bleu nuit avec le logo officiel
  Widget _construireBandeauHaut() {
    return Container(
      color: Palette.primaire,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
      child: Column(
        children: [
          // Logo CivilApp officiel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Palette.bordure, width: 1),
            ),
            child: Image.asset(
              'assets/images/logo_civilapp.png',
              height: 64,
              width: 64,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.account_balance_rounded,
                size: 48,
                color: Palette.primaire,
              ),
            ),
          ),
          const SizedBox(height: 18),

          Text(
            'CivilApp',
            style: GoogleFonts.publicSans(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),

          Text(
            'Système d\'Information de l\'État Civil',
            textAlign: TextAlign.center,
            style: GoogleFonts.publicSans(
              fontSize: 13,
              color: Palette.texteSurSombreMuted,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// Carte d'accès à un espace
  Widget _construireEntree(
    BuildContext context, {
    required String titre,
    required String description,
    required IconData icone,
    required bool estPrimaire,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: estPrimaire ? Palette.primaire : Palette.bordure,
            width: estPrimaire ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: estPrimaire ? Palette.primaire : Palette.surfaceSecondaire,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icone,
                color: estPrimaire ? Colors.white : Palette.textePrimaire,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: GoogleFonts.publicSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Palette.textePrimaire,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      color: Palette.texteSecondaire,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Palette.texteDiscret,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

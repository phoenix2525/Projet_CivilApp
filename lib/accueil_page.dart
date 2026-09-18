import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'creer_profil_page.dart';
import 'connexion_agent_page.dart';

/// Page d'accueil de l'application CivilApp.
class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fond dégradé sombre — effet premium
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF062917), // Vert très sombre
                    Color(0xFF0A6640), // Vert émeraude
                    Color(0xFF083D26), // Profond
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),

          // Cercles décoratifs flous en arrière-plan
          Positioned(
            top: -80,
            right: -60,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00C896).withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            bottom: size.height * 0.25,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A9260).withValues(alpha: 0.15),
              ),
            ),
          ),

          // Contenu principal
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Column(
                  children: [
                    const SizedBox(height: 60),

                    // Logo et nom de l'application
                    _construireEntete(),

                    const SizedBox(height: 64),

                    // Carte principale glassmorphism
                    _construireCarteGlass(context),

                    const SizedBox(height: 32),

                    // Mention de sécurité en bas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline, size: 14, color: Colors.white38),
                        const SizedBox(width: 6),
                        Text(
                          'Données chiffrées — République du Sénégal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: Colors.white38,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// En-tête avec icône et slogan
  Widget _construireEntete() {
    return Column(
      children: [
        // Icône principale avec halo lumineux
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C896).withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.account_balance_rounded, size: 42, color: Colors.white),
        ),
        const SizedBox(height: 20),

        Text(
          'CivilApp',
          style: GoogleFonts.hankenGrotesk(
            fontSize: 42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          "L'État Civil Sénégalais, à portée de main",
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            color: Colors.white60,
            fontWeight: FontWeight.w400,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Carte principale avec effet glassmorphism
  Widget _construireCarteGlass(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisissez votre espace',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Accédez à vos services administratifs en ligne.',
                style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.white54),
              ),
              const SizedBox(height: 28),

              // Bouton citoyen — plein, accent vert lumineux
              _construireBoutonCitoyen(context),
              const SizedBox(height: 14),

              // Bouton agent — transparent, contour blanc
              _construireBoutonAgent(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Bouton espace citoyen — design premium avec gradient
  Widget _construireBoutonCitoyen(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreerProfilPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00C896), Color(0xFF0A8A5A)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00C896).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Espace Citoyen',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Démarrez ou suivez une demande',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  /// Bouton espace agent — contour blanc discret
  Widget _construireBoutonAgent(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ConnexionAgentPage()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Espace Agent Mairie',
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Gestion et traitement des dossiers',
                    style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }
}

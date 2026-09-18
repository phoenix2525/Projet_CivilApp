import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/document.dart';
import 'formulaire_demande_page.dart';

/// Page de détails d'un document administratif.
/// Présente les informations, pièces requises et étapes de la démarche.
class DetailsDocumentPage extends StatelessWidget {
  final Document document;

  const DetailsDocumentPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: CustomScrollView(
        slivers: [
          // AppBar avec image Hero en fond
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: document.couleur,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image Hero
                  Hero(
                    tag: 'doc_icon_${document.id}',
                    child: Image.asset(
                      document.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: document.couleur.withValues(alpha: 0.3),
                        child: Icon(document.icon, size: 80, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                  // Gradient de lisibilité
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          document.couleur.withValues(alpha: 0.85),
                        ],
                      ),
                    ),
                  ),
                  // Titre en bas de l'image
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ÉTAT CIVIL',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white70,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          document.titre,
                          style: GoogleFonts.hankenGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Corps de la page
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges délai et frais
                  Row(
                    children: [
                      _construireBadge(Icons.schedule_rounded, document.delai, const Color(0xFFF57C00)),
                      const SizedBox(width: 10),
                      _construireBadge(Icons.payments_rounded, document.frais, const Color(0xFF0A6640)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  Text(
                    document.description,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section pièces justificatives
                  _construireTitreSection('Pièces justificatives requises', Icons.checklist_rounded),
                  const SizedBox(height: 6),
                  Text(
                    'Préparez ces documents avant de démarrer votre demande.',
                    style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 14),

                  ...document.piecesAFournir.asMap().entries.map((entry) {
                    return _construireItemPiece(entry.key + 1, entry.value, colorScheme);
                  }),

                  const SizedBox(height: 28),

                  // Section étapes
                  _construireTitreSection('Étapes de traitement', Icons.timeline_rounded),
                  const SizedBox(height: 14),

                  _construireEtape(context, '1', 'Soumission en ligne',
                      'Remplissez le formulaire et validez la checklist des pièces.', false),
                  _construireEtape(context, '2', 'Instruction & Vérification',
                      'Vérification dans les registres municipaux par l\'officier d\'état civil.', false),
                  _construireEtape(context, '3', 'Délivrance & Retrait',
                      'Notification de mise à disposition et retrait du document officiel en mairie.', true),

                  const SizedBox(height: 32),

                  // Bouton d'action principal
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FormulaireDemandePage(document: document),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: Text(
                        'Faire une demande pour cet acte',
                        style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Badge d'information (délai ou frais)
  Widget _construireBadge(IconData icone, String texte, Color couleur) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: couleur.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: couleur.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 16, color: couleur),
          const SizedBox(width: 6),
          Text(
            texte,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: couleur,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  /// Titre de section avec icône
  Widget _construireTitreSection(String titre, IconData icone) {
    return Row(
      children: [
        Icon(icone, size: 20, color: const Color(0xFF0A6640)),
        const SizedBox(width: 8),
        Text(
          titre,
          style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1A2E26)),
        ),
      ],
    );
  }

  /// Ligne de pièce justificative numérotée
  Widget _construireItemPiece(int numero, String piece, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro de la pièce
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              piece,
              style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  /// Étape numérotée dans le parcours administratif
  Widget _construireEtape(
    BuildContext context,
    String numero,
    String titre,
    String description,
    bool estDerniere,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  numero,
                  style: GoogleFonts.hankenGrotesk(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!estDerniere)
              Container(width: 2, height: 40, color: const Color(0xFFDDE5E2)),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text(
                  titre,
                  style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade600, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

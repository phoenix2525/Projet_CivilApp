import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/document.dart';
import 'formulaire_demande_page.dart';

/// Page de détails d'un document administratif officiel.
/// Présentation sobre des pièces requises et étapes d'instruction.
class DetailsDocumentPage extends StatelessWidget {
  final Document document;

  const DetailsDocumentPage({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.fond,
      body: CustomScrollView(
        slivers: [
          // AppBar avec image du document et bandeau sombre uni
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: Palette.primaire,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'doc_icon_${document.id}',
                    child: Image.asset(
                      document.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Palette.primaire,
                        child: Icon(document.icon, size: 60, color: Colors.white24),
                      ),
                    ),
                  ),
                  // Scrim sombre uniforme pour assurer la lisibilité
                  Container(
                    color: Colors.black.withOpacity(0.55),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACTE OFFICIEL D\'ÉTAT CIVIL',
                          style: GoogleFonts.publicSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Palette.texteSurSombreMuted,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          document.titre,
                          style: GoogleFonts.publicSans(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
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

          // Contenu informatif
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges d'information administrative
                  Row(
                    children: [
                      _construireBadge(Icons.schedule, 'Délai : ${document.delai}'),
                      const SizedBox(width: 10),
                      _construireBadge(Icons.payments_outlined, 'Frais : ${document.frais}'),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Description officielle
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Palette.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Palette.bordure, width: 1),
                    ),
                    child: Text(
                      document.description,
                      style: GoogleFonts.publicSans(
                        fontSize: 13,
                        color: Palette.texteSecondaire,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pièces justificatives requises
                  _construireTitreSection('Pièces à fournir', Icons.checklist_outlined),
                  const SizedBox(height: 4),
                  Text(
                    'Documents obligatoires lors du retrait en mairie.',
                    style: GoogleFonts.publicSans(fontSize: 12, color: Palette.texteDiscret),
                  ),
                  const SizedBox(height: 12),

                  ...document.piecesAFournir.asMap().entries.map((entry) {
                    return _construireItemPiece(entry.key + 1, entry.value);
                  }),

                  const SizedBox(height: 24),

                  // Étapes de délivrance
                  _construireTitreSection('Instruction du dossier', Icons.timeline_outlined),
                  const SizedBox(height: 12),

                  _construireEtape('1', 'Saisie du formulaire',
                      'Renseignement des données d\'état civil et validation des conditions.', false),
                  _construireEtape('2', 'Contrôle des registres',
                      'Vérification de conformité dans le registre communal par un officier.', false),
                  _construireEtape('3', 'Signature & Retrait',
                      'Édition du document timbré et mise à disposition au guichet municipal.', true),

                  const SizedBox(height: 28),

                  // Bouton de démarche
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
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                      label: Text(
                        'Faire une demande pour cet acte',
                        style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700),
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

  Widget _construireBadge(IconData icone, String texte) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icone, size: 14, color: Palette.texteSecondaire),
          const SizedBox(width: 6),
          Text(
            texte,
            style: GoogleFonts.publicSans(
              fontSize: 12,
              color: Palette.textePrimaire,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireTitreSection(String titre, IconData icone) {
    return Row(
      children: [
        Icon(icone, size: 18, color: Palette.primaire),
        const SizedBox(width: 8),
        Text(
          titre,
          style: GoogleFonts.publicSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Palette.textePrimaire,
          ),
        ),
      ],
    );
  }

  Widget _construireItemPiece(int numero, String piece) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Palette.surfaceSecondaire,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Palette.bordure, width: 1),
            ),
            child: Center(
              child: Text(
                '$numero',
                style: GoogleFonts.publicSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Palette.primaire,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              piece,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Palette.textePrimaire,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireEtape(
    String numero,
    String titre,
    String description,
    bool estDerniere,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Palette.primaire,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  numero,
                  style: GoogleFonts.publicSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            if (!estDerniere)
              Container(width: 2, height: 36, color: Palette.bordure),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Palette.textePrimaire,
                  ),
                ),
                const SizedBox(height: 2),
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
        ),
      ],
    );
  }
}

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/document.dart';
import 'details_document_page.dart';
import 'mes_demandes_page.dart';
import 'tableau_de_bord_citoyen_page.dart';

/// Page catalogue des actes d'état civil disponibles.

class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Filtrage en temps réel selon la saisie
    final documentsFiltres = documentsDisponibles
        .where(
          (doc) => doc.titre.toLowerCase().contains(_recherche.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: Stack(
        children: [
          // Fond décoratif en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF062917), Color(0xFF0A6640)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec titre et description
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catalogue',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sélectionnez un acte pour démarrer votre demande.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.white60,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Barre de recherche glassmorphism
                      _construireBarreRecherche(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // Liste des documents
                Expanded(
                  child: documentsFiltres.isEmpty
                      ? _construireEtatVide()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                          itemCount: documentsFiltres.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final doc = documentsFiltres[index];
                            return _construireCarteDocument(
                              context,
                              doc,
                              colorScheme,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _construireBottomNav(colorScheme),
    );
  }

  /// Barre de recherche avec effet verre sur fond sombre
  Widget _construireBarreRecherche() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: TextField(
            onChanged: (val) => setState(() => _recherche = val),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Rechercher un acte...',
              hintStyle: GoogleFonts.plusJakartaSans(
                color: Colors.white54,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.white60,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              fillColor: Colors.transparent,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ),
    );
  }

  /// Carte d'un document
  Widget _construireCarteDocument(
    BuildContext context,
    Document doc,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsDocumentPage(document: doc),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Hero du document
            Hero(
              tag: 'doc_icon_${doc.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
                child: Image.asset(
                  doc.imagePath,
                  width: 90,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 100,
                    decoration: BoxDecoration(
                      color: doc.couleur.withValues(alpha: 0.15),
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(18),
                      ),
                    ),
                    child: Icon(doc.icon, color: doc.couleur, size: 36),
                  ),
                ),
              ),
            ),

            // Contenu texte
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge catégorie
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: doc.couleur.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'ÉTAT CIVIL',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: doc.couleur,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      doc.titre,
                      style: GoogleFonts.hankenGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF1A2E26),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.description,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    // Délai et frais
                    Row(
                      children: [
                        _construireMiniTag(
                          Icons.schedule_rounded,
                          doc.delai,
                          const Color(0xFFF57C00),
                        ),
                        const SizedBox(width: 8),
                        _construireMiniTag(
                          Icons.payments_rounded,
                          doc.frais,
                          const Color(0xFF0A6640),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFCDD8D3),
                size: 22,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mini tag délai / frais
  Widget _construireMiniTag(IconData icone, String texte, Color couleur) {
    return Row(
      children: [
        Icon(icone, size: 12, color: couleur),
        const SizedBox(width: 3),
        Text(
          texte,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            color: couleur,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// Écran vide si aucun document ne correspond à la recherche
  Widget _construireEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Aucun document trouvé',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de navigation inférieure
  Widget _construireBottomNav(ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECF0EE))),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: const Color(0xFF9EADA8),
        selectedLabelStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_rounded),
            label: 'Mes Dossiers',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TableauDeBordCitoyenPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MesDemandesPage()),
            );
          }
        },
      ),
    );
  }
}

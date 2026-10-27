import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/document.dart';
import 'details_document_page.dart';
import 'mes_demandes_page.dart';
import 'tableau_de_bord_citoyen_page.dart';

/// Page catalogue des actes d'état civil disponibles.
/// Interface administrative sobre et structurée en fiches distinctes.
class CataloguePage extends StatefulWidget {
  const CataloguePage({super.key});

  @override
  State<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends State<CataloguePage> {
  String _recherche = '';

  @override
  Widget build(BuildContext context) {
    // Filtrage en temps réel selon la saisie
    final documentsFiltres = documentsDisponibles
        .where(
          (doc) => doc.titre.toLowerCase().contains(_recherche.toLowerCase()),
        )
        .toList();

    return Scaffold(
      backgroundColor: Palette.fond,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bandeau supérieur sobre
            Container(
              color: Palette.primaire,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catalogue',
                    style: GoogleFonts.publicSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sélectionnez un acte officiel pour formuler une demande.',
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      color: Palette.texteSurSombreMuted,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Barre de recherche sobre et nette
                  _construireBarreRecherche(),
                ],
              ),
            ),

            // Liste des documents
            Expanded(
              child: documentsFiltres.isEmpty
                  ? _construireEtatVide()
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: documentsFiltres.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final doc = documentsFiltres[index];
                        return _construireCarteDocument(context, doc);
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _construireBottomNav(),
    );
  }

  /// Barre de recherche administrative nette
  Widget _construireBarreRecherche() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _recherche = val),
        style: GoogleFonts.publicSans(
          color: Palette.textePrimaire,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Rechercher un acte (naissance, mariage...)',
          hintStyle: GoogleFonts.publicSans(
            color: Palette.texteDiscret,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Palette.texteSecondaire,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          fillColor: Colors.transparent,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
      ),
    );
  }

  /// Fiche d'un acte officiel avec bordure fine et détails lisibles
  Widget _construireCarteDocument(BuildContext context, Document doc) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsDocumentPage(document: doc),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Palette.bordure, width: 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Vignette image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
              child: SizedBox(
                width: 86,
                height: 100,
                child: Image.asset(
                  doc.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Palette.surfaceSecondaire,
                    child: Icon(doc.icon, color: doc.couleur, size: 30),
                  ),
                ),
              ),
            ),

            // Contenu informatif
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.titre,
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Palette.textePrimaire,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.description,
                      style: GoogleFonts.publicSans(
                        fontSize: 11,
                        color: Palette.texteSecondaire,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _construireTagDelai(doc.delai),
                        _construireTagFrais(doc.frais),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 38, right: 12),
              child: Icon(
                Icons.chevron_right_rounded,
                color: Palette.texteDiscret,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireTagDelai(String delai) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.schedule, size: 12, color: Palette.texteSecondaire),
        const SizedBox(width: 3),
        Text(
          delai,
          style: GoogleFonts.publicSans(
            fontSize: 11,
            color: Palette.texteSecondaire,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _construireTagFrais(String frais) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Palette.surfaceSecondaire,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        frais,
        style: GoogleFonts.publicSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Palette.textePrimaire,
        ),
      ),
    );
  }

  /// Écran vide sobre
  Widget _construireEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 48, color: Palette.texteDiscret),
          const SizedBox(height: 12),
          Text(
            'Aucun document ne correspond à la recherche.',
            style: GoogleFonts.publicSans(
              fontSize: 13,
              color: Palette.texteSecondaire,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigation inférieure
  Widget _construireBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.surface,
        border: Border(top: BorderSide(color: Palette.bordure, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 1,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Palette.primaire,
        unselectedItemColor: Palette.texteDiscret,
        selectedLabelStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.publicSans(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder_rounded),
            label: 'Mes Dossiers',
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
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

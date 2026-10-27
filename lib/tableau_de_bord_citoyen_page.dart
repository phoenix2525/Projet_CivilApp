import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/demande.dart';
import 'catalogue_page.dart';
import 'mes_demandes_page.dart';

/// Tableau de bord du citoyen connecté.
/// Interface administrative sobre, sans dégradés ni effets superflus.
class TableauDeBordCitoyenPage extends StatefulWidget {
  const TableauDeBordCitoyenPage({super.key});

  @override
  State<TableauDeBordCitoyenPage> createState() => _TableauDeBordCitoyenPageState();
}

class _TableauDeBordCitoyenPageState extends State<TableauDeBordCitoyenPage> {
  int _indexCourant = 0;

  @override
  Widget build(BuildContext context) {
    final citoyen = DatabaseSimulee.citoyenConnecte;

    if (citoyen == null) {
      return Scaffold(
        backgroundColor: Palette.fond,
        body: Center(
          child: Text(
            'Erreur : citoyen non connecté.',
            style: GoogleFonts.publicSans(color: Palette.textePrimaire),
          ),
        ),
      );
    }

    // Calcul des statistiques du citoyen
    final mesDemandes = DatabaseSimulee.demandes
        .where((d) => d.citoyen.telephone == citoyen.telephone)
        .toList();
    final demandesEnCours = mesDemandes.where((d) => d.statut == 'reçue' || d.statut == 'en cours').length;
    final demandesTerminees = mesDemandes.where((d) => d.statut == 'prête' || d.statut == 'livrée').length;
    final totalDemandes = mesDemandes.length;

    final initiales = citoyen.prenom.isNotEmpty && citoyen.nom.isNotEmpty
        ? citoyen.prenom[0].toUpperCase() + citoyen.nom[0].toUpperCase()
        : 'CI';

    return Scaffold(
      backgroundColor: Palette.fond,
      body: CustomScrollView(
        slivers: [
          // AppBar avec fond uni bleu nuit institutionnel
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Palette.primaire,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _construireHeader(initiales, citoyen.prenom, citoyen.nom, totalDemandes),
            ),
            title: Text(
              'Mon Espace',
              style: GoogleFonts.publicSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ),

          // Corps de la page
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Synthèse chiffrée
                  _construireTitreSection('État des démarches'),
                  const SizedBox(height: 12),
                  _construireRangeeStats(demandesEnCours, demandesTerminees, totalDemandes),
                  const SizedBox(height: 24),

                  // Actions principales
                  _construireTitreSection('Démarches administratives'),
                  const SizedBox(height: 12),
                  _construireBoutonAction(
                    context,
                    icone: Icons.add_circle_outline,
                    titre: 'Nouvelle demande',
                    sousTitre: 'Parcourir le catalogue officiel des actes',
                    couleurIcone: Palette.primaire,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const CataloguePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _construireBoutonAction(
                    context,
                    icone: Icons.folder_outlined,
                    titre: 'Suivre mes dossiers',
                    sousTitre: 'Consulter l\'instruction et les convocations',
                    couleurIcone: Palette.secondaire,
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MesDemandesPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Encart d'information officielle
                  _construireEncartInfo(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _construireBottomNav(),
    );
  }

  /// Header uni avec initiales et nom
  Widget _construireHeader(String initiales, String prenom, String nom, int total) {
    return Container(
      color: Palette.primaire,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                // Pastille citoyen
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      initiales,
                      style: GoogleFonts.publicSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Usager connecté',
                        style: GoogleFonts.publicSans(
                          color: Palette.texteSurSombreMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '$prenom $nom',
                        style: GoogleFonts.publicSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$total dossier${total > 1 ? 's' : ''} enregistré${total > 1 ? 's' : ''}',
                        style: GoogleFonts.publicSans(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _construireTitreSection(String titre) {
    return Text(
      titre,
      style: GoogleFonts.publicSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Palette.textePrimaire,
      ),
    );
  }

  /// Panneau de synthèse officiel des démarches, sobre et unifié
  Widget _construireRangeeStats(int enCours, int terminees, int total) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _construireItemSynthese(
                label: 'En cours',
                valeur: enCours,
                couleur: Palette.statutEnCours,
              ),
            ),
            Container(width: 1, color: Palette.bordure, margin: const EdgeInsets.symmetric(vertical: 10)),
            Expanded(
              child: _construireItemSynthese(
                label: 'Prêtes',
                valeur: terminees,
                couleur: Palette.statutPrete,
              ),
            ),
            Container(width: 1, color: Palette.bordure, margin: const EdgeInsets.symmetric(vertical: 10)),
            Expanded(
              child: _construireItemSynthese(
                label: 'Total',
                valeur: total,
                couleur: Palette.primaire,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireItemSynthese({
    required String label,
    required int valeur,
    required Color couleur,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: couleur,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Palette.texteSecondaire,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$valeur',
            style: GoogleFonts.publicSans(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Palette.textePrimaire,
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton d'action institutionnel
  Widget _construireBoutonAction(
    BuildContext context, {
    required IconData icone,
    required String titre,
    required String sousTitre,
    required Color couleurIcone,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Palette.bordure, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Palette.surfaceSecondaire,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icone, color: couleurIcone, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: GoogleFonts.publicSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Palette.textePrimaire,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: GoogleFonts.publicSans(
                      fontSize: 12,
                      color: Palette.texteSecondaire,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Palette.texteDiscret, size: 14),
          ],
        ),
      ),
    );
  }

  /// Encart d'information officielle
  Widget _construireEncartInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Palette.surfaceSecondaire,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Palette.primaire, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Délais légaux : instruction sous 48h ouvrées. Un SMS ou une notification est émis dès que votre acte est prêt en mairie.',
              style: GoogleFonts.publicSans(
                fontSize: 12,
                color: Palette.texteSecondaire,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de navigation inférieure
  Widget _construireBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.surface,
        border: Border(top: BorderSide(color: Palette.bordure, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _indexCourant,
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
          if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CataloguePage()),
            );
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MesDemandesPage()),
            );
          } else {
            setState(() => _indexCourant = 0);
          }
        },
      ),
    );
  }
}

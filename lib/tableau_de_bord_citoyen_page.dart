import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/demande.dart';
import 'catalogue_page.dart';
import 'mes_demandes_page.dart';

/// Tableau de bord du citoyen connecté.
/// Design moderne : header gradient, stats colorées, actions visuelles.
class TableauDeBordCitoyenPage extends StatefulWidget {
  const TableauDeBordCitoyenPage({super.key});

  @override
  State<TableauDeBordCitoyenPage> createState() => _TableauDeBordCitoyenPageState();
}

class _TableauDeBordCitoyenPageState extends State<TableauDeBordCitoyenPage> {
  // Index de la page active dans la BottomNav
  int _indexCourant = 0;

  @override
  Widget build(BuildContext context) {
    final citoyen = DatabaseSimulee.citoyenConnecte;
    final colorScheme = Theme.of(context).colorScheme;

    if (citoyen == null) {
      return Scaffold(
        body: Center(
          child: Text('Erreur : citoyen non connecté.', style: Theme.of(context).textTheme.bodyLarge),
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

    // Initiales du citoyen pour l'avatar
    final initiales = citoyen.prenom[0].toUpperCase() + citoyen.nom[0].toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: CustomScrollView(
        slivers: [
          // AppBar déroulante avec header gradient
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0A6640),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _construireHeader(initiales, citoyen.prenom, citoyen.nom, totalDemandes),
            ),
            title: Text(
              'Mon Espace',
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                  const SizedBox(height: 4),

                  // Cartes de statistiques
                  _construireTitreSection('Aperçu de vos dossiers'),
                  const SizedBox(height: 12),
                  _construireRangeeStats(demandesEnCours, demandesTerminees, totalDemandes),
                  const SizedBox(height: 28),

                  // Actions rapides
                  _construireTitreSection('Que souhaitez-vous faire ?'),
                  const SizedBox(height: 12),
                  _construireBoutonAction(
                    context,
                    icone: Icons.add_circle_rounded,
                    titre: 'Nouvelle demande',
                    sousTitre: 'Parcourir le catalogue des actes disponibles',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0A6640), Color(0xFF1A9260)],
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const CataloguePage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _construireBoutonAction(
                    context,
                    icone: Icons.folder_open_rounded,
                    titre: 'Suivre mes dossiers',
                    sousTitre: 'Consulter l\'état de vos demandes en cours',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MesDemandesPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 28),

                  // Rappel info service
                  _construireEncartInfo(colorScheme),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),

      // Barre de navigation inférieure moderne
      bottomNavigationBar: _construireBottomNav(colorScheme),
    );
  }

  /// Header expansible avec gradient et avatar citoyen
  Widget _construireHeader(String initiales, String prenom, String nom, int total) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF062917), Color(0xFF0A6640), Color(0xFF1A9260)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                // Avatar citoyen
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Center(
                    child: Text(
                      initiales,
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Bonjour,',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white60, fontSize: 13),
                      ),
                    Text(
                      '$prenom $nom',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$total demande${total != 1 ? 's' : ''} au total',
                        style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 12),
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

  /// Titre de section sobre
  Widget _construireTitreSection(String titre) {
    return Text(
      titre,
      style: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1A2E26),
      ),
    );
  }

  /// Rangée de 3 cartes de statistiques colorées
  Widget _construireRangeeStats(int enCours, int terminees, int total) {
    return Row(
      children: [
        Expanded(child: _construireCarteStat('En cours', enCours, const Color(0xFFF57C00), Icons.hourglass_top_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _construireCarteStat('Prêtes', terminees, const Color(0xFF0A6640), Icons.check_circle_rounded)),
        const SizedBox(width: 10),
        Expanded(child: _construireCarteStat('Total', total, const Color(0xFF1565C0), Icons.description_rounded)),
      ],
    );
  }

  /// Carte de statistique individuelle
  Widget _construireCarteStat(String titre, int valeur, Color couleur, IconData icone) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: couleur.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: couleur.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icone, color: couleur, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            '$valeur',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: couleur,
            ),
          ),
          Text(
            titre,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton d'action avec gradient coloré
  Widget _construireBoutonAction(
    BuildContext context, {
    required IconData icone,
    required String titre,
    required String sousTitre,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icone, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: GoogleFonts.hankenGrotesk(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sousTitre,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 16),
          ],
        ),
      ),
    );
  }

  /// Encart d'information sur les délais
  Widget _construireEncartInfo(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A6640).withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF0A6640).withValues(alpha: 0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Les délais de traitement sont de 3 à 7 jours ouvrables selon le type de document. Vous serez notifié à chaque changement de statut.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF1A3A2A),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Barre de navigation inférieure avec séparateur en haut
  Widget _construireBottomNav(ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECF0EE))),
      ),
      child: BottomNavigationBar(
        currentIndex: _indexCourant,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: const Color(0xFF9EADA8),
        selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/demande.dart';
import 'models/agent.dart';
import 'traitement_demande_page.dart';

/// Interface de gestion des demandes pour les agents de mairie.
/// Table de bord administrative claire avec filtres et recherche instantanée.
class GestionDemandesPage extends StatefulWidget {
  const GestionDemandesPage({super.key});

  @override
  State<GestionDemandesPage> createState() => _GestionDemandesPageState();
}

class _GestionDemandesPageState extends State<GestionDemandesPage> {
  final TextEditingController _rechercheController = TextEditingController();
  String _rechercheTexte = '';
  String? _filtreStatut;

  final List<String> _statuts = ['reçue', 'en cours', 'prête', 'livrée'];

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  void _rafraichir() => setState(() {});

  List<Demande> _demandesFiltrees() {
    List<Demande> resultat = DatabaseSimulee.demandes;

    if (_filtreStatut != null) {
      resultat = resultat.where((d) => d.statut == _filtreStatut).toList();
    }

    if (_rechercheTexte.isNotEmpty) {
      final recherche = _rechercheTexte.toLowerCase();
      resultat = resultat.where((d) {
        return d.citoyen.prenom.toLowerCase().contains(recherche) ||
            d.citoyen.nom.toLowerCase().contains(recherche) ||
            d.document.titre.toLowerCase().contains(recherche) ||
            d.id.contains(recherche);
      }).toList();
    }

    return resultat;
  }

  @override
  Widget build(BuildContext context) {
    final demandes = _demandesFiltrees();
    final agent = DatabaseSimulee.agentConnecte;

    return Scaffold(
      backgroundColor: Palette.fond,
      body: CustomScrollView(
        slivers: [
          // AppBar sobre sans dégradé
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Palette.primaire,
            actions: [
              if (agent != null)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  child: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      agent.prenom[0].toUpperCase(),
                      style: GoogleFonts.publicSans(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                tooltip: 'Déconnexion',
                onPressed: () {
                  DatabaseSimulee.agentConnecte = null;
                  Navigator.pop(context);
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _construireHeaderAgent(agent),
            ),
            title: Text(
              'Gestion des Demandes',
              style: GoogleFonts.publicSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),

          // Barre de recherche et filtres
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _construireBarreRecherche(),
                  const SizedBox(height: 12),
                  _construireFiltresStatut(),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // Liste des demandes
          demandes.isEmpty
              ? SliverFillRemaining(child: _construireEtatVide())
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _construireCarteDemande(context, demandes[index]),
                      childCount: demandes.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _construireHeaderAgent(Agent? agent) {
    return Container(
      color: Palette.primaire,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                if (agent != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${agent.prenom} ${agent.nom}',
                          style: GoogleFonts.publicSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${agent.role} • ${agent.matricule}',
                          style: GoogleFonts.publicSans(
                            color: Palette.texteSurSombreMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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

  Widget _construireBarreRecherche() {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: TextField(
        controller: _rechercheController,
        style: GoogleFonts.publicSans(fontSize: 13, color: Palette.textePrimaire),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom d\'usager, acte, n°...',
          hintStyle: GoogleFonts.publicSans(color: Palette.texteDiscret, fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: Palette.texteSecondaire, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        ),
        onChanged: (value) => setState(() => _rechercheTexte = value),
      ),
    );
  }

  Widget _construireFiltresStatut() {
    final int total = DatabaseSimulee.demandes.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _boutonFiltre(
            label: 'Tous',
            count: total,
            estSelectionne: _filtreStatut == null,
            couleur: Palette.primaire,
            onTap: () => setState(() => _filtreStatut = null),
          ),
          ..._statuts.map((statut) {
            final couleur = Palette.couleurStatut(statut);
            final int count = DatabaseSimulee.demandes.where((d) => d.statut == statut).length;
            final String labelAffiche;
            switch (statut) {
              case 'reçue':
                labelAffiche = 'Reçues';
                break;
              case 'en cours':
                labelAffiche = 'En cours';
                break;
              case 'prête':
                labelAffiche = 'Prêtes';
                break;
              case 'livrée':
                labelAffiche = 'Livrées';
                break;
              default:
                labelAffiche = statut;
            }
            return _boutonFiltre(
              label: labelAffiche,
              count: count,
              estSelectionne: _filtreStatut == statut,
              couleur: couleur,
              onTap: () => setState(() {
                _filtreStatut = _filtreStatut == statut ? null : statut;
              }),
            );
          }),
        ],
      ),
    );
  }

  Widget _boutonFiltre({
    required String label,
    required int count,
    required bool estSelectionne,
    required Color couleur,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: estSelectionne ? Palette.primaire : Palette.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: estSelectionne ? Palette.primaire : Palette.bordure,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: GoogleFonts.publicSans(
                  color: estSelectionne ? Colors.white : Palette.textePrimaire,
                  fontWeight: estSelectionne ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: estSelectionne ? Colors.white.withOpacity(0.2) : Palette.surfaceSecondaire,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.publicSans(
                    color: estSelectionne ? Colors.white : Palette.texteSecondaire,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireCarteDemande(BuildContext context, Demande demande) {
    final dateFormatee =
        '${demande.dateDemande.day.toString().padLeft(2, '0')}/${demande.dateDemande.month.toString().padLeft(2, '0')}/${demande.dateDemande.year}';
    final reference =
        'REF-${demande.id.substring(demande.id.length > 4 ? demande.id.length - 4 : 0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TraitementDemandePage(demande: demande),
            ),
          ).then((_) => _rafraichir());
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${demande.citoyen.prenom} ${demande.citoyen.nom}',
                            style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Palette.textePrimaire,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Palette.surfaceSecondaire,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Palette.bordure, width: 1),
                          ),
                          child: Text(
                            reference,
                            style: GoogleFonts.publicSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Palette.texteSecondaire,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(demande.document.icon, size: 14, color: Palette.texteSecondaire),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            demande.document.titre,
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              color: Palette.texteSecondaire,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        BadgeStatut(statut: demande.statut, compact: true),
                        const Spacer(),
                        const Icon(Icons.calendar_today_outlined, size: 11, color: Palette.texteDiscret),
                        const SizedBox(width: 4),
                        Text(
                          dateFormatee,
                          style: GoogleFonts.publicSans(
                            fontSize: 11,
                            color: Palette.texteDiscret,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Palette.texteDiscret,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireEtatVide() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Palette.texteDiscret),
          const SizedBox(height: 12),
          Text(
            'Aucune demande trouvée',
            style: GoogleFonts.publicSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Palette.texteSecondaire,
            ),
          ),
        ],
      ),
    );
  }
}

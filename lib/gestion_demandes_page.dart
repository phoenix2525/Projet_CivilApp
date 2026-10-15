import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/demande.dart';
import 'models/agent.dart';
import 'traitement_demande_page.dart';

/// Interface de gestion des demandes pour les agents de mairie.
/// Recherche instantanée, filtres par statut, liste visuelle moderne.
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

  // Rafraîchit la liste après retour de la page traitement
  void _rafraichir() => setState(() {});

  /// Filtre les demandes selon le texte de recherche et le statut sélectionné
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
    final colorScheme = Theme.of(context).colorScheme;
    final agent = DatabaseSimulee.agentConnecte;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: CustomScrollView(
        slivers: [
          // AppBar expandable avec infos agent
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0A6640),
            actions: [
              // Avatar agent
              if (agent != null)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  child: CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      agent.prenom[0].toUpperCase(),
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              // Déconnexion
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
          ),

          // Corps
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),

                  // Barre de recherche
                  _construireBarreRecherche(),
                  const SizedBox(height: 14),

                  // Filtres par statut
                  _construireFiltresStatut(colorScheme),
                  const SizedBox(height: 6),
                ],
              ),
            ),
          ),

          // Liste des demandes ou état vide
          demandes.isEmpty
              ? SliverFillRemaining(child: _construireEtatVide(colorScheme))
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final demande = demandes[index];
                      return _construireCarteDemande(context, demande);
                    }, childCount: demandes.length),
                  ),
                ),
        ],
      ),
    );
  }

  /// Header de l'espace agent avec rôle et matricule
  Widget _construireHeaderAgent(Agent? agent) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF062917), Color(0xFF0A6640)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                if (agent != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${agent.prenom} ${agent.nom}',
                          style: GoogleFonts.hankenGrotesk(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${agent.role} • ${agent.matricule}',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white60,
                            fontSize: 12,
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

  /// Barre de recherche moderne
  Widget _construireBarreRecherche() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _rechercheController,
        decoration: InputDecoration(
          hintText: 'Rechercher par nom, document...',
          prefixIcon: const Icon(Icons.search_rounded),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onChanged: (value) => setState(() => _rechercheTexte = value),
      ),
    );
  }

  /// Filtres de statut modernes, très visibles et contrastés
  Widget _construireFiltresStatut(ColorScheme colorScheme) {
    final int total = DatabaseSimulee.demandes.length;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          // Bouton "Tous"
          _boutonFiltre(
            label: 'Tous',
            count: total,
            estSelectionne: _filtreStatut == null,
            couleurTheme: const Color(0xFF0A6640),
            onTap: () => setState(() => _filtreStatut = null),
          ),
          // Boutons par statut
          ..._statuts.map((statut) {
            final couleur = _couleurStatut(statut);
            final int count = DatabaseSimulee.demandes
                .where((d) => d.statut == statut)
                .length;
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
                labelAffiche = statut[0].toUpperCase() + statut.substring(1);
            }
            return _boutonFiltre(
              label: labelAffiche,
              count: count,
              estSelectionne: _filtreStatut == statut,
              couleurTheme: couleur,
              onTap: () => setState(() {
                _filtreStatut = _filtreStatut == statut ? null : statut;
              }),
            );
          }),
        ],
      ),
    );
  }

  /// Bouton de filtre personnalisé avec contraste renforcé pour visibilité optimale
  Widget _boutonFiltre({
    required String label,
    required int count,
    required bool estSelectionne,
    required Color couleurTheme,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: estSelectionne
                  ? couleurTheme
                  : couleurTheme.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: estSelectionne
                    ? couleurTheme
                    : couleurTheme.withValues(alpha: 0.40),
                width: estSelectionne ? 2.0 : 1.5,
              ),
              boxShadow: [
                if (estSelectionne)
                  BoxShadow(
                    color: couleurTheme.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (estSelectionne) ...[
                  const Icon(Icons.check_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                ] else ...[
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: couleurTheme,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: estSelectionne ? Colors.white : couleurTheme,
                    fontWeight: estSelectionne ? FontWeight.w800 : FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: estSelectionne
                        ? Colors.white.withValues(alpha: 0.25)
                        : couleurTheme.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$count',
                    style: GoogleFonts.plusJakartaSans(
                      color: estSelectionne ? Colors.white : couleurTheme,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Carte d'une demande dans la liste
  Widget _construireCarteDemande(BuildContext context, Demande demande) {
    final couleur = _couleurStatut(demande.statut);
    final dateFormatee =
        '${demande.dateDemande.day}/${demande.dateDemande.month}/${demande.dateDemande.year}';
    final reference =
        'REF-${demande.id.substring(demande.id.length > 4 ? demande.id.length - 4 : 0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TraitementDemandePage(demande: demande),
              ),
            ).then((_) => _rafraichir());
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Indicateur couleur à gauche
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: couleur,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 14),

                // Icône document
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: couleur.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.description_rounded,
                    color: couleur,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Infos de la demande
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${demande.citoyen.prenom} ${demande.citoyen.nom}',
                        style: GoogleFonts.hankenGrotesk(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        demande.document.titre,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Badge statut
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: couleur.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: couleur.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              demande.statut.toUpperCase(),
                              style: GoogleFonts.plusJakartaSans(
                                color: couleur,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Text(
                            '$dateFormatee • $reference',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFFCDD8D3),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// État vide de la liste
  Widget _construireEtatVide(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _rechercheTexte.isNotEmpty || _filtreStatut != null
                ? 'Aucune demande trouvée'
                : 'Aucune demande reçue pour le moment',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 16,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Les demandes des citoyens apparaîtront ici.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  /// Couleur associée à chaque statut de demande
  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'reçue':
        return const Color(0xFFF57C00);
      case 'en cours':
        return const Color(0xFF1565C0);
      case 'prête':
        return const Color(0xFF0A6640);
      case 'livrée':
        return const Color(0xFF6A1B9A);
      default:
        return Colors.grey;
    }
  }
}

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
              collapseMode: CollapseMode.pin,
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 52, 20, 16),
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${agent.prenom} ${agent.nom}',
                      style: GoogleFonts.hankenGrotesk(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '${agent.role} • ${agent.matricule}',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ],
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

  /// Filtres de statut sous forme de chips
  Widget _construireFiltresStatut(ColorScheme colorScheme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Chip "Tous"
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('Tous'),
              selected: _filtreStatut == null,
              selectedColor: colorScheme.primary.withValues(alpha: 0.15),
              checkmarkColor: colorScheme.primary,
              onSelected: (_) => setState(() => _filtreStatut = null),
            ),
          ),
          // Chips par statut
          ..._statuts.map((statut) {
            final couleur = _couleurStatut(statut);
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(statut[0].toUpperCase() + statut.substring(1)),
                selected: _filtreStatut == statut,
                selectedColor: couleur.withValues(alpha: 0.15),
                checkmarkColor: couleur,
                onSelected: (selected) =>
                    setState(() => _filtreStatut = selected ? statut : null),
              ),
            );
          }),
        ],
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
                      Row(
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
                          const SizedBox(width: 8),
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

import 'package:flutter/material.dart';
import 'models/demande.dart';
import 'traitement_demande_page.dart';

class GestionDemandesPage extends StatefulWidget {
  const GestionDemandesPage({super.key});

  @override
  State<GestionDemandesPage> createState() => _GestionDemandesPageState();
}

class _GestionDemandesPageState extends State<GestionDemandesPage> {
  // Contrôleur pour la barre de recherche
  final TextEditingController _rechercheController = TextEditingController();
  String _rechercheTexte = '';

  // Filtre par statut sélectionné (null = tous)
  String? _filtreStatut;

  final List<String> _statuts = ['reçue', 'en cours', 'prête', 'livrée'];

  @override
  void dispose() {
    _rechercheController.dispose();
    super.dispose();
  }

  // Rafraichir la liste après un retour de la page de traitement
  void _rafraichir() {
    setState(() {});
  }

  /// Retourne la liste filtrée des demandes selon la recherche et le filtre statut
  List<Demande> _demandesFiltrees() {
    List<Demande> resultat = DatabaseSimulee.demandes;

    // Filtre par statut
    if (_filtreStatut != null) {
      resultat = resultat.where((d) => d.statut == _filtreStatut).toList();
    }

    // Filtre par recherche textuelle (nom, prénom, type de document, référence)
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Espace Agent - Demandes'),
        actions: [
          if (DatabaseSimulee.agentConnecte != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface,
                radius: 16,
                child: Text(
                  DatabaseSimulee.agentConnecte!.prenom[0],
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              DatabaseSimulee.agentConnecte = null;
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des demandes reçues',
              style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 8),
            Text(
              'Consultez et traitez les demandes citoyennes récentes.',
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _rechercheController,
              decoration: InputDecoration(
                hintText: 'Rechercher une demande...',
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _rechercheTexte = value;
                });
              },
            ),
            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('Tous'),
                      selected: _filtreStatut == null,
                      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                      onSelected: (selected) {
                        setState(() {
                          _filtreStatut = null;
                        });
                      },
                    ),
                  ),
                  ..._statuts.map((statut) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: FilterChip(
                        label: Text(statut[0].toUpperCase() + statut.substring(1)),
                        selected: _filtreStatut == statut,
                        selectedColor: _couleurStatut(statut).withValues(alpha: 0.2),
                        onSelected: (selected) {
                          setState(() {
                            _filtreStatut = selected ? statut : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: demandes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            _rechercheTexte.isNotEmpty || _filtreStatut != null
                                ? 'Aucune demande ne correspond à vos critères.'
                                : 'Aucune demande pour le moment.',
                            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: demandes.length,
                      itemBuilder: (context, index) {
                        final demande = demandes[index];
                        final statutCouleur = _couleurStatut(demande.statut);
                        final dateFormatee = '${demande.dateDemande.day}/${demande.dateDemande.month}/${demande.dateDemande.year}';
                        final reference = 'REF-${demande.id.substring(demande.id.length > 4 ? demande.id.length - 4 : 0)}';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                              child: Icon(Icons.description, color: colorScheme.primary),
                            ),
                            title: Text(
                              '${demande.citoyen.prenom} ${demande.citoyen.nom}',
                              style: textTheme.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(demande.document.titre, style: textTheme.bodyMedium),
                                const SizedBox(height: 4),
                                Text(
                                  '$dateFormatee  •  Réf: $reference',
                                  style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: statutCouleur.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: statutCouleur.withValues(alpha: 0.5)),
                                  ),
                                  child: Text(
                                    demande.statut.toUpperCase(),
                                    style: TextStyle(color: statutCouleur, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.chevron_right, color: colorScheme.outlineVariant),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TraitementDemandePage(demande: demande),
                                ),
                              ).then((_) => _rafraichir());
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retourne la couleur associée à un statut donné
  Color _couleurStatut(String statut) {
    switch (statut) {
      case 'reçue':
        return Colors.orange;
      case 'en cours':
        return Colors.blue;
      case 'prête':
        return Colors.green;
      case 'livrée':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

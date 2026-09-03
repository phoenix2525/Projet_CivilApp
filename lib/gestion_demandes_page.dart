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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Espace Agent - Demandes', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Affichage de l'agent connecté
          if (DatabaseSimulee.agentConnecte != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
                child: Text(
                  DatabaseSimulee.agentConnecte!.prenom[0],
                  style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Déconnexion',
            onPressed: () {
              DatabaseSimulee.agentConnecte = null;
              Navigator.pop(context); // Retour à la page de connexion
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des demandes reçues',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
            const SizedBox(height: 8),
            Text(
              'Consultez et traitez les demandes citoyennes récentes.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),

            // Barre de recherche (conforme à la maquette)
            TextField(
              controller: _rechercheController,
              decoration: InputDecoration(
                hintText: 'Rechercher une demande...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {
                  _rechercheTexte = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Ligne de filtres par statut (conforme à la maquette "Filtrer")
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Bouton "Tous"
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: const Text('Tous'),
                      selected: _filtreStatut == null,
                      selectedColor: Colors.green.shade100,
                      onSelected: (selected) {
                        setState(() {
                          _filtreStatut = null;
                        });
                      },
                    ),
                  ),
                  // Boutons pour chaque statut
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
                          Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            _rechercheTexte.isNotEmpty || _filtreStatut != null
                                ? 'Aucune demande ne correspond à vos critères.'
                                : 'Aucune demande pour le moment.',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
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

                        // Formater la date
                        final dateFormatee = '${demande.dateDemande.day}/${demande.dateDemande.month}/${demande.dateDemande.year}';
                        // Référence courte
                        final reference = 'REF-${demande.id.substring(demande.id.length > 4 ? demande.id.length - 4 : 0)}';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.green.shade100,
                              child: Icon(Icons.description, color: Colors.green.shade900),
                            ),
                            title: Text(
                              '${demande.citoyen.prenom} ${demande.citoyen.nom}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(demande.document.titre),
                                const SizedBox(height: 4),
                                Text(
                                  '$dateFormatee  •  Réf: $reference',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
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
                            trailing: const Icon(Icons.chevron_right),
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

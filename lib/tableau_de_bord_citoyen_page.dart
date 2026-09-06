import 'package:flutter/material.dart';
import 'models/demande.dart';
import 'catalogue_page.dart';
import 'mes_demandes_page.dart';

class TableauDeBordCitoyenPage extends StatefulWidget {
  const TableauDeBordCitoyenPage({super.key});

  @override
  State<TableauDeBordCitoyenPage> createState() => _TableauDeBordCitoyenPageState();
}

class _TableauDeBordCitoyenPageState extends State<TableauDeBordCitoyenPage> {
  @override
  Widget build(BuildContext context) {
    final citoyen = DatabaseSimulee.citoyenConnecte;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    
    if (citoyen == null) {
      return Scaffold(
        body: Center(child: Text("Erreur: Citoyen non connecté.", style: textTheme.bodyLarge)),
      );
    }

    final mesDemandes = DatabaseSimulee.demandes
        .where((d) => d.citoyen.telephone == citoyen.telephone)
        .toList();
        
    final demandesEnCours = mesDemandes.where((d) => d.statut == 'reçue' || d.statut == 'en cours').length;
    final demandesTerminees = mesDemandes.where((d) => d.statut == 'prête' || d.statut == 'livrée').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        automaticallyImplyLeading: false, // Pas de flèche retour
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Espace d'accueil chaleureux avec bannière
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/banner_dashboard.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.1),
                    spreadRadius: 0,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: colorScheme.surface,
                    child: Text(
                      citoyen.prenom[0].toUpperCase() + citoyen.nom[0].toUpperCase(),
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bienvenue,',
                          style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        Text(
                          '${citoyen.prenom} ${citoyen.nom}',
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Statistiques rapides
            Text(
              'Aperçu de vos demandes',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _construireCarteStat(
                    context,
                    titre: 'En cours',
                    valeur: demandesEnCours.toString(),
                    couleur: Colors.orange.shade700,
                    icone: Icons.hourglass_top,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _construireCarteStat(
                    context,
                    titre: 'Prêtes',
                    valeur: demandesTerminees.toString(),
                    couleur: colorScheme.secondary,
                    icone: Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Actions rapides (Carrefour)
            Text(
              'Que souhaitez-vous faire ?',
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            _construireBoutonAction(
              context,
              titre: 'Nouvelle demande',
              sousTitre: 'Parcourir le catalogue des documents',
              icone: Icons.add_circle_outline,
              couleur: colorScheme.primary,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CataloguePage()),
                );
              },
            ),
            const SizedBox(height: 16),
            _construireBoutonAction(
              context,
              titre: 'Suivre mes dossiers',
              sousTitre: 'Consulter l\'état de vos demandes existantes',
              icone: Icons.folder_open,
              couleur: colorScheme.secondary,
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MesDemandesPage()),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
        backgroundColor: colorScheme.surface,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Mes Demandes',
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
          }
        },
      ),
    );
  }

  Widget _construireCarteStat(BuildContext context, {required String titre, required String valeur, required Color couleur, required IconData icone}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            spreadRadius: 0,
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(color: couleur.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icone, color: couleur, size: 28),
              Text(
                valeur,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: couleur,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titre,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireBoutonAction(BuildContext context, {required String titre, required String sousTitre, required IconData icone, required Color couleur, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.05),
              spreadRadius: 0,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: couleur.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icone, color: couleur, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titre,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sousTitre,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: theme.colorScheme.outlineVariant),
          ],
        ),
      ),
    );
  }
}

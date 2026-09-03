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
    
    // Si pour une raison quelconque l'utilisateur n'est pas connecté
    if (citoyen == null) {
      return const Scaffold(
        body: Center(child: Text("Erreur: Citoyen non connecté.")),
      );
    }

    final mesDemandes = DatabaseSimulee.demandes
        .where((d) => d.citoyen.telephone == citoyen.telephone)
        .toList();
        
    final demandesEnCours = mesDemandes.where((d) => d.statut == 'reçue' || d.statut == 'en cours').length;
    final demandesTerminees = mesDemandes.where((d) => d.statut == 'prête' || d.statut == 'livrée').length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Tableau de Bord'),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false, // Pas de flèche retour
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Espace d'accueil chaleureux
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    citoyen.prenom[0].toUpperCase() + citoyen.nom[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade900,
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
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                      ),
                      Text(
                        '${citoyen.prenom} ${citoyen.nom}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Statistiques rapides
            const Text(
              'Aperçu de vos demandes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _construireCarteStat(
                    titre: 'En cours',
                    valeur: demandesEnCours.toString(),
                    couleur: Colors.orange,
                    icone: Icons.hourglass_top,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _construireCarteStat(
                    titre: 'Prêtes',
                    valeur: demandesTerminees.toString(),
                    couleur: Colors.green,
                    icone: Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Actions rapides (Carrefour)
            const Text(
              'Que souhaitez-vous faire ?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _construireBoutonAction(
              context,
              titre: 'Nouvelle demande',
              sousTitre: 'Parcourir le catalogue des documents',
              icone: Icons.add_circle_outline,
              couleur: Colors.blue.shade700,
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
              titre: 'Suivre mes dossiers',
              sousTitre: 'Consulter l\'état de vos demandes existantes',
              icone: Icons.folder_open,
              couleur: Colors.purple.shade700,
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
        currentIndex: 0, // 0 pour l'Accueil/Tableau de bord
        selectedItemColor: Colors.green.shade900,
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

  Widget _construireCarteStat({required String titre, required String valeur, required Color couleur, required IconData icone}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: couleur.withValues(alpha: 0.3)),
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: couleur,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            titre,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireBoutonAction(BuildContext context, {required String titre, required String sousTitre, required IconData icone, required Color couleur, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.05),
              spreadRadius: 1,
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
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sousTitre,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

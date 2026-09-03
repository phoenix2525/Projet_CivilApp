import 'package:flutter/material.dart';
import 'models/demande.dart';
import 'catalogue_page.dart';

class MesDemandesPage extends StatefulWidget {
  const MesDemandesPage({super.key});

  @override
  State<MesDemandesPage> createState() => _MesDemandesPageState();
}

class _MesDemandesPageState extends State<MesDemandesPage> {

  /// Récupère les notifications destinées au citoyen connecté
  List<Map<String, dynamic>> _mesNotifications() {
    if (DatabaseSimulee.citoyenConnecte == null) return [];
    return DatabaseSimulee.notifications
        .where((n) => n['telephone'] == DatabaseSimulee.citoyenConnecte!.telephone)
        .toList();
  }

  /// Affiche un dialogue modal avec les notifications du citoyen
  void _afficherNotifications() {
    final notifs = _mesNotifications();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.notifications, color: Colors.green.shade900),
              const SizedBox(width: 8),
              const Text('Mes Notifications'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: notifs.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Aucune notification pour le moment.'),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifs.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final notif = notifs[notifs.length - 1 - index];
                      final DateTime date = notif['date'];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Icon(Icons.notifications_active, color: Colors.green.shade700),
                        ),
                        title: Text(
                          notif['message'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filtrer les demandes du citoyen connecté
    final mesDemandes = DatabaseSimulee.demandes
        .where((d) => d.citoyen.telephone == DatabaseSimulee.citoyenConnecte?.telephone)
        .toList();

    final nbNotifications = _mesNotifications().length;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Mes Demandes'),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
        actions: [
          // Icône de notification avec badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: _afficherNotifications,
              ),
              if (nbNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$nbNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: mesDemandes.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Vous n\'avez fait aucune demande pour le moment.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mesDemandes.length,
              itemBuilder: (context, index) {
                final demande = mesDemandes[index];
                
                Color statutCouleur = Colors.grey;
                if (demande.statut == 'reçue') statutCouleur = Colors.orange;
                if (demande.statut == 'en cours') statutCouleur = Colors.blue;
                if (demande.statut == 'prête') statutCouleur = Colors.green;
                if (demande.statut == 'livrée') statutCouleur = Colors.purple;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: demande.document.couleur.withValues(alpha: 0.2),
                      child: Icon(demande.document.icon, color: demande.document.couleur),
                    ),
                    title: Text(
                      demande.document.titre,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Date : ${demande.dateDemande.day}/${demande.dateDemande.month}/${demande.dateDemande.year}'),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: statutCouleur.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: statutCouleur.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            demande.statut.toUpperCase(),
                            style: TextStyle(color: statutCouleur, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.info_outline),
                    onTap: () {
                      _afficherDetailsDemande(demande);
                    },
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // 2 pour Profil / Mes Demandes
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
          }
        },
      ),
    );
  }

  /// Affiche un dialogue avec les détails complets d'une demande
  void _afficherDetailsDemande(Demande demande) {
    Color statutCouleur = Colors.grey;
    if (demande.statut == 'reçue') statutCouleur = Colors.orange;
    if (demande.statut == 'en cours') statutCouleur = Colors.blue;
    if (demande.statut == 'prête') statutCouleur = Colors.green;
    if (demande.statut == 'livrée') statutCouleur = Colors.purple;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(demande.document.icon, color: demande.document.couleur),
              const SizedBox(width: 8),
              Expanded(child: Text(demande.document.titre, style: const TextStyle(fontSize: 18))),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Réf: REQ-${demande.id.substring(demande.id.length > 4 ? demande.id.length - 4 : 0)}'),
                const SizedBox(height: 8),
                Text('Date de soumission : ${demande.dateDemande.day}/${demande.dateDemande.month}/${demande.dateDemande.year}'),
                const SizedBox(height: 12),
                const Text('Statut actuel :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statutCouleur.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statutCouleur.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    demande.statut.toUpperCase(),
                    style: TextStyle(color: statutCouleur, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 24),
                const Text('Récapitulatif des données saisies :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...demande.donneesFormulaire.entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text('• ${e.key.replaceAll('_', ' ')} : ${e.value}'),
                )),
                const Divider(height: 24),
                const Text('Pièces justificatives cochées :', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...demande.piecesFournies.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(child: Text(entry.key, style: const TextStyle(fontSize: 12))),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

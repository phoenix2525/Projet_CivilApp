import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/demande.dart';
import 'details_demande_citoyen_page.dart';
import 'catalogue_page.dart';
import 'tableau_de_bord_citoyen_page.dart';

/// Page de suivi des demandes du citoyen connecté.
/// Affiche l'historique et les notifications avec un design moderne.
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

  /// Couleur associée au statut d'une demande
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

  /// Icône associée au statut
  IconData _iconeStatut(String statut) {
    switch (statut) {
      case 'reçue':
        return Icons.inbox_rounded;
      case 'en cours':
        return Icons.hourglass_top_rounded;
      case 'prête':
        return Icons.check_circle_rounded;
      case 'livrée':
        return Icons.done_all_rounded;
      default:
        return Icons.help_outline;
    }
  }

  /// Affiche les notifications dans un dialogue modal
  void _afficherNotifications() {
    final notifs = _mesNotifications();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.notifications_rounded, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 10),
              Text('Notifications', style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: notifs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Aucune notification pour le moment.',
                      style: GoogleFonts.plusJakartaSans(color: Colors.grey.shade600),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifs.length,
                    separatorBuilder: (context, index) => Divider(color: Colors.grey.shade100),
                    itemBuilder: (context, index) {
                      final notif = notifs[notifs.length - 1 - index];
                      final DateTime date = notif['date'];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.notifications_active_rounded,
                              color: Theme.of(context).colorScheme.primary, size: 20),
                        ),
                        title: Text(notif['message'],
                            style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          '${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Demandes du citoyen connecté
    final mesDemandes = DatabaseSimulee.demandes
        .where((d) => d.citoyen.telephone == DatabaseSimulee.citoyenConnecte?.telephone)
        .toList();

    final nbNotifications = _mesNotifications().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: CustomScrollView(
        slivers: [
          // AppBar avec badge notification
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: const Color(0xFF0A6640),
            title: Text(
              'Mes Dossiers',
              style: GoogleFonts.hankenGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
            actions: [
              // Icône notification avec badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_rounded, color: Colors.white),
                    onPressed: _afficherNotifications,
                  ),
                  if (nbNotifications > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF0A6640), width: 2),
                        ),
                        child: Center(
                          child: Text(
                            '$nbNotifications',
                            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Corps : liste ou état vide
          mesDemandes.isEmpty
              ? SliverFillRemaining(child: _construireEtatVide(colorScheme))
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final demande = mesDemandes[index];
                        return _construireCarteDemande(demande);
                      },
                      childCount: mesDemandes.length,
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: _construireBottomNav(colorScheme),
    );
  }

  /// Carte d'une demande dans la liste
  Widget _construireCarteDemande(Demande demande) {
    final couleur = _couleurStatut(demande.statut);
    final icone = _iconeStatut(demande.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2)),
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
              MaterialPageRoute(builder: (context) => DetailsDemandeCitoyenPage(demande: demande)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Image du document ou icône
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    demande.document.imagePath,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: couleur.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(demande.document.icon, color: couleur, size: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Infos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        demande.document.titre,
                        style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Déposée le ${demande.dateDemande.day}/${demande.dateDemande.month}/${demande.dateDemande.year}',
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(height: 8),
                      // Badge statut avec icône
                      Row(
                        children: [
                          Icon(icone, size: 14, color: couleur),
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: couleur.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: couleur.withValues(alpha: 0.3)),
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
                        ],
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right_rounded, color: Color(0xFFCDD8D3), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Écran vide quand aucune demande n'existe
  Widget _construireEtatVide(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.folder_open_rounded, size: 56, color: colorScheme.primary.withValues(alpha: 0.5)),
            ),
            const SizedBox(height: 20),
            Text(
              'Aucune demande',
              style: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez encore déposé aucune demande. Rendez-vous dans le catalogue pour commencer.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CataloguePage()),
                );
              },
              icon: const Icon(Icons.grid_view_rounded),
              label: const Text('Voir le catalogue'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Barre de navigation inférieure
  Widget _construireBottomNav(ColorScheme colorScheme) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFECF0EE))),
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: const Color(0xFF9EADA8),
        selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Catalogue'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_rounded), label: 'Mes Dossiers'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CataloguePage()),
            );
          }
        },
      ),
    );
  }
}

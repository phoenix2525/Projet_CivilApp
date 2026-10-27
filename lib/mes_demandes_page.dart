import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/demande.dart';
import 'details_demande_citoyen_page.dart';
import 'catalogue_page.dart';
import 'tableau_de_bord_citoyen_page.dart';

/// Page de suivi des demandes du citoyen connecté.
/// Vue sobre en liste de dossiers avec statuts officiels codifiés.
class MesDemandesPage extends StatefulWidget {
  const MesDemandesPage({super.key});

  @override
  State<MesDemandesPage> createState() => _MesDemandesPageState();
}

class _MesDemandesPageState extends State<MesDemandesPage> {
  List<Map<String, dynamic>> _mesNotifications() {
    if (DatabaseSimulee.citoyenConnecte == null) return [];
    return DatabaseSimulee.notifications
        .where((n) => n['telephone'] == DatabaseSimulee.citoyenConnecte!.telephone)
        .toList();
  }

  void _afficherNotifications() {
    final notifs = _mesNotifications();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Palette.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Palette.bordure, width: 1),
          ),
          title: Row(
            children: [
              const Icon(Icons.notifications_outlined, color: Palette.primaire, size: 20),
              const SizedBox(width: 10),
              Text(
                'Notifications officielles',
                style: GoogleFonts.publicSans(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: notifs.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Aucune notification pour le moment.',
                      style: GoogleFonts.publicSans(color: Palette.texteSecondaire, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifs.length,
                    separatorBuilder: (context, index) => const Divider(color: Palette.bordure),
                    itemBuilder: (context, index) {
                      final notif = notifs[notifs.length - 1 - index];
                      final DateTime date = notif['date'];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Palette.surfaceSecondaire,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.notifications_active_outlined,
                            color: Palette.primaire,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          notif['message'],
                          style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                          style: GoogleFonts.publicSans(fontSize: 11, color: Palette.texteDiscret),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final mesDemandes = DatabaseSimulee.demandes
        .where((d) => d.citoyen.telephone == DatabaseSimulee.citoyenConnecte?.telephone)
        .toList();

    final nbNotifications = _mesNotifications().length;

    return Scaffold(
      backgroundColor: Palette.fond,
      body: CustomScrollView(
        slivers: [
          // AppBar unie
          SliverAppBar(
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: Palette.primaire,
            title: Text(
              'Mes Dossiers',
              style: GoogleFonts.publicSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: _afficherNotifications,
                  ),
                  if (nbNotifications > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Palette.accent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$nbNotifications',
                          style: GoogleFonts.publicSans(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Liste des demandes
          mesDemandes.isEmpty
              ? SliverFillRemaining(child: _construireEtatVide())
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _construireCarteDemande(mesDemandes[index]),
                      childCount: mesDemandes.length,
                    ),
                  ),
                ),
        ],
      ),
      bottomNavigationBar: _construireBottomNav(),
    );
  }

  Widget _construireCarteDemande(Demande demande) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              builder: (context) => DetailsDemandeCitoyenPage(demande: demande),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: Image.asset(
                    demande.document.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Palette.surfaceSecondaire,
                      child: Icon(demande.document.icon, color: Palette.primaire, size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      demande.document.titre,
                      style: GoogleFonts.publicSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Palette.textePrimaire,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Déposée le ${demande.dateDemande.day.toString().padLeft(2, '0')}/${demande.dateDemande.month.toString().padLeft(2, '0')}/${demande.dateDemande.year}',
                      style: GoogleFonts.publicSans(fontSize: 11, color: Palette.texteDiscret),
                    ),
                    const SizedBox(height: 8),
                    BadgeStatut(statut: demande.statut),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Palette.texteDiscret,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construireEtatVide() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_open_outlined, size: 48, color: Palette.texteDiscret),
            const SizedBox(height: 16),
            Text(
              'Aucun dossier déposé',
              style: GoogleFonts.publicSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Palette.textePrimaire,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Vos futures demandes d\'actes d\'état civil s\'afficheront ici pour le suivi.',
              textAlign: TextAlign.center,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                color: Palette.texteSecondaire,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const CataloguePage()),
                );
              },
              icon: const Icon(Icons.grid_view_rounded, size: 16),
              label: const Text('Consulter le catalogue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Palette.surface,
        border: Border(top: BorderSide(color: Palette.bordure, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: Palette.primaire,
        unselectedItemColor: Palette.texteDiscret,
        selectedLabelStyle: GoogleFonts.publicSans(fontWeight: FontWeight.w600, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.publicSans(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view_outlined),
            activeIcon: Icon(Icons.grid_view_rounded),
            label: 'Catalogue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder_rounded),
            label: 'Mes Dossiers',
          ),
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

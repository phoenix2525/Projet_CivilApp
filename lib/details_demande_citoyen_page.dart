import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/demande.dart';

/// Page de consultation détaillée d'une demande d'acte pour le citoyen.
/// Présente l'état d'avancement officiel et le récapitulatif des données saisies.
class DetailsDemandeCitoyenPage extends StatelessWidget {
  final Demande demande;

  const DetailsDemandeCitoyenPage({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    final numeroDossier =
        'REQ-${demande.dateDemande.year}-${demande.id.length >= 6 ? demande.id.substring(demande.id.length - 6) : demande.id}';
    final dateTexte =
        '${demande.dateDemande.day.toString().padLeft(2, '0')}/${demande.dateDemande.month.toString().padLeft(2, '0')}/${demande.dateDemande.year} à ${demande.dateDemande.hour.toString().padLeft(2, '0')}:${demande.dateDemande.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Palette.fond,
      appBar: AppBar(
        title: const Text('Détail de ma demande'),
        backgroundColor: Palette.primaire,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte principale avec Réf et Statut
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Palette.bordure, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'RÉF. $numeroDossier',
                          style: GoogleFonts.publicSans(
                            color: Palette.texteSecondaire,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _construireBadgeStatut(demande.statut),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    demande.document.titre,
                    style: GoogleFonts.publicSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Palette.textePrimaire,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 13, color: Palette.texteDiscret),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Déposée le $dateTexte',
                          style: GoogleFonts.publicSans(fontSize: 11, color: Palette.texteSecondaire),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Note de l'agent si présente
            if (demande.noteAgent.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Palette.statutEnCoursFond,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Palette.statutEnCours.withOpacity(0.3), width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.notifications_active_outlined, color: Palette.statutEnCours, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Observation de l\'officier d\'état civil',
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Palette.statutEnCours,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            demande.noteAgent,
                            style: GoogleFonts.publicSans(
                              fontSize: 12,
                              color: Palette.textePrimaire,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Progression administrative
            Text(
              'Instruction officielle',
              style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
            ),
            const SizedBox(height: 8),
            _construireProgression(context),
            const SizedBox(height: 16),

            // Données déclarées
            Text(
              'Éléments du dossier',
              style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Palette.bordure, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _construireListeChamps(context),
              ),
            ),
            const SizedBox(height: 16),

            // Pièces justificatives
            Text(
              'Pièces justificatives',
              style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Palette.bordure, width: 1),
              ),
              child: Column(
                children: demande.document.piecesAFournir.map((piece) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 16, color: Palette.validation),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            piece,
                            style: GoogleFonts.publicSans(fontSize: 12, color: Palette.textePrimaire),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _construireBadgeStatut(String statut) {
    return BadgeStatut(statut: statut);
  }

  Widget _construireProgression(BuildContext context) {
    final statut = demande.statut.toLowerCase();

    const etape1Validee = true;
    final etape2Validee = statut == 'en cours' || statut == 'prête' || statut == 'livrée';
    final etape3Validee = statut == 'prête' || statut == 'livrée';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Column(
        children: [
          _construireItemTimeline(
            titre: 'Demande enregistrée',
            sousTitre: 'Dossier transmis au service municipal',
            estValide: etape1Validee,
            estEnCours: statut == 'reçue',
            estDernier: false,
          ),
          _construireItemTimeline(
            titre: 'Instruction en mairie',
            sousTitre: 'Vérification dans les registres officiels',
            estValide: etape2Validee,
            estEnCours: statut == 'en cours',
            estDernier: false,
          ),
          _construireItemTimeline(
            titre: statut == 'livrée' ? 'Acte délivré' : 'Document prêt pour retrait',
            sousTitre: statut == 'livrée'
                ? 'Procédure d\'état civil clôturée'
                : 'Disponible au guichet municipal',
            estValide: etape3Validee,
            estEnCours: statut == 'prête',
            estDernier: true,
          ),
        ],
      ),
    );
  }

  Widget _construireItemTimeline({
    required String titre,
    required String sousTitre,
    required bool estValide,
    required bool estEnCours,
    required bool estDernier,
  }) {
    Color couleurCercle = Palette.bordure;
    IconData icone = Icons.circle_outlined;
    Color couleurIcone = Palette.texteDiscret;

    if (estValide) {
      couleurCercle = Palette.validation;
      icone = Icons.check;
      couleurIcone = Colors.white;
    } else if (estEnCours) {
      couleurCercle = Palette.statutEnCours;
      icone = Icons.hourglass_top_outlined;
      couleurIcone = Colors.white;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: couleurCercle,
              child: Icon(icone, size: 13, color: couleurIcone),
            ),
            if (!estDernier)
              Container(
                width: 2,
                height: 32,
                color: estValide ? Palette.validation : Palette.bordure,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: GoogleFonts.publicSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: estValide || estEnCours ? Palette.textePrimaire : Palette.texteDiscret,
                  ),
                ),
                Text(
                  sousTitre,
                  style: GoogleFonts.publicSans(fontSize: 11, color: Palette.texteSecondaire),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _construireListeChamps(BuildContext context) {
    final widgets = <Widget>[];
    final entrees = demande.donneesFormulaire.entries.toList();

    for (int i = 0; i < entrees.length; i++) {
      final cle = entrees[i].key;
      final valeur = entrees[i].value;
      final label = _formaterCle(cle);

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: GoogleFonts.publicSans(
                    fontSize: 11,
                    color: Palette.texteSecondaire,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  valeur,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Palette.textePrimaire,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      if (i < entrees.length - 1) {
        widgets.add(const Divider(height: 10, thickness: 1, color: Palette.bordure));
      }
    }

    return widgets;
  }

  String _formaterCle(String cle) {
    switch (cle) {
      case 'prenom_enfant':
        return 'Prénom(s) enfant';
      case 'nom_enfant':
        return 'Nom enfant';
      case 'sexe':
        return 'Sexe';
      case 'date_naissance':
        return 'Date de naissance';
      case 'heure_naissance':
        return 'Heure de naissance';
      case 'lieu_naissance':
        return 'Lieu de naissance';
      case 'prenom_nom_pere':
        return 'Père';
      case 'profession_pere':
        return 'Profession du père';
      case 'prenom_nom_mere':
        return 'Mère';
      case 'profession_mere':
        return 'Profession de la mère';
      case 'domicile_parents':
        return 'Domicile des parents';
      case 'prenom_titulaire':
        return 'Prénom(s) titulaire';
      case 'nom_titulaire':
        return 'Nom titulaire';
      case 'num_registre':
        return 'N° de Registre / Acte';
      case 'annee_registre':
        return 'Année du Registre';
      case 'centre_etat_civil':
        return 'Centre d\'État Civil';
      case 'prenom_epoux':
        return 'Prénom(s) de l\'époux';
      case 'nom_epoux':
        return 'Nom de l\'époux';
      case 'date_naissance_epoux':
        return 'Date de naissance de l\'époux';
      case 'prenom_epouse':
        return 'Prénom(s) de l\'épouse';
      case 'nom_epouse':
        return 'Nom de l\'épouse';
      case 'date_naissance_epouse':
        return 'Date de naissance de l\'épouse';
      case 'date_mariage':
        return 'Date du mariage';
      case 'lieu_mariage':
        return 'Lieu du mariage';
      case 'regime_matrimonial':
        return 'Régime matrimonial';
      case 'num_acte_mariage':
        return 'N° Acte de Mariage';
      case 'prenom_defunt':
        return 'Prénom(s) du défunt';
      case 'nom_defunt':
        return 'Nom du défunt';
      case 'date_naissance_defunt':
        return 'Date de naissance du défunt';
      case 'date_deces':
        return 'Date du décès';
      case 'heure_deces':
        return 'Heure du décès';
      case 'lieu_deces':
        return 'Lieu du décès';
      case 'prenom_nom_declarant':
        return 'Déclarant';
      case 'lien_parente_declarant':
        return 'Lien de parenté';
      case 'cni_declarant':
        return 'CNI du déclarant';
      default:
        return cle.replaceAll('_', ' ').toUpperCase();
    }
  }
}

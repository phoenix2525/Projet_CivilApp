import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'models/demande.dart';
import 'mes_demandes_page.dart';
import 'tableau_de_bord_citoyen_page.dart';

/// Page de confirmation après transmission d'une demande d'acte civil.
/// Présentation sous forme de récépissé officiel de mairie avec perforation.
class ConfirmationEnvoiPage extends StatelessWidget {
  final Demande demande;

  const ConfirmationEnvoiPage({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    // Calcul d'un identifiant de suivi officiel
    final numeroSuivi =
        'SN-${demande.dateDemande.year}-${demande.id.length >= 6 ? demande.id.substring(demande.id.length - 6) : demande.id}';

    // Nom du bénéficiaire ou titulaire de l'acte
    String beneficiaire = '${demande.citoyen.prenom} ${demande.citoyen.nom}';
    if (demande.donneesFormulaire.containsKey('prenom') &&
        demande.donneesFormulaire.containsKey('nom')) {
      beneficiaire =
          '${demande.donneesFormulaire['prenom']} ${demande.donneesFormulaire['nom']}';
    } else if (demande.donneesFormulaire.containsKey('nom_epoux')) {
      beneficiaire =
          '${demande.donneesFormulaire['nom_epoux']} & ${demande.donneesFormulaire['nom_epouse']}';
    } else if (demande.donneesFormulaire.containsKey('nom_defunt')) {
      beneficiaire =
          '${demande.donneesFormulaire['prenom_defunt'] ?? ''} ${demande.donneesFormulaire['nom_defunt']} (Défunt)';
    }

    final dateDepot =
        '${demande.dateDemande.day.toString().padLeft(2, '0')}/${demande.dateDemande.month.toString().padLeft(2, '0')}/${demande.dateDemande.year} à ${demande.dateDemande.hour.toString().padLeft(2, '0')}:${demande.dateDemande.minute.toString().padLeft(2, '0')}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const TableauDeBordCitoyenPage(),
            ),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Palette.fond,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Badge de confirmation sobre avec turquoise validation
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Palette.statutPreteFond,
                          shape: BoxShape.circle,
                          border: Border.all(color: Palette.validation, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Palette.validation,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text(
                      'Demande enregistrée',
                      style: GoogleFonts.publicSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Palette.textePrimaire,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      'Votre dossier a été transmis aux officiers d\'état civil.',
                      style: GoogleFonts.publicSans(
                        fontSize: 13,
                        color: Palette.texteSecondaire,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // --- Récépissé de mairie ---
                    _construireRecepisseMairie(
                      context,
                      numeroSuivi: numeroSuivi,
                      dateDepot: dateDepot,
                      beneficiaire: beneficiaire,
                      typeDocument: demande.document.titre,
                      delai: demande.document.delai,
                      frais: demande.document.frais,
                    ),
                    const SizedBox(height: 28),

                    // Boutons d'action
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MesDemandesPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.folder_outlined, size: 18),
                      label: const Text('Suivre mes demandes'),
                    ),
                    const SizedBox(height: 10),

                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TableauDeBordCitoyenPage(),
                          ),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.home_outlined, size: 18),
                      label: const Text('Retour au tableau de bord'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Carte sous forme de récépissé officiel avec ligne de perforation
  Widget _construireRecepisseMairie(
    BuildContext context, {
    required String numeroSuivi,
    required String dateDepot,
    required String beneficiaire,
    required String typeDocument,
    required String delai,
    required String frais,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En-tête du récépissé
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: Palette.surfaceSecondaire,
              borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance, size: 16, color: Palette.primaire),
                    const SizedBox(width: 8),
                    Text(
                      'RÉCÉPISSÉ OFFICIEL DE DÉPÔT',
                      style: GoogleFonts.publicSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Palette.primaire,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateDepot.split(' à ').first,
                  style: GoogleFonts.publicSans(
                    fontSize: 11,
                    color: Palette.texteSecondaire,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          // Bloc Numéro de Suivi mis en avant
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'NUMÉRO DE DOSSIER OFFICIEL',
                  style: GoogleFonts.publicSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Palette.texteDiscret,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Palette.surfaceSecondaire,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Palette.bordure, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        numeroSuivi,
                        style: GoogleFonts.publicSans(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Palette.primaire,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(width: 10),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: numeroSuivi));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Numéro $numeroSuivi copié.'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 16,
                            color: Palette.texteSecondaire,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ligne de perforation visuelle (style coupon / reçu)
          Row(
            children: [
              Container(
                width: 10,
                height: 18,
                decoration: const BoxDecoration(
                  color: Palette.fond,
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                ),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final boxWidth = constraints.constrainWidth();
                    const dashWidth = 5.0;
                    const dashSpace = 4.0;
                    final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(dashCount, (_) {
                        return Container(
                          width: dashWidth,
                          height: 1,
                          color: Palette.bordure,
                        );
                      }),
                    );
                  },
                ),
              ),
              Container(
                width: 10,
                height: 18,
                decoration: const BoxDecoration(
                  color: Palette.fond,
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                ),
              ),
            ],
          ),

          // Détails administratifs
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _construireLigneInfo('Acte demandé', typeDocument),
                const SizedBox(height: 10),
                _construireLigneInfo('Bénéficiaire', beneficiaire),
                const SizedBox(height: 10),
                _construireLigneInfo('Date et heure de dépôt', dateDepot),
                const SizedBox(height: 10),
                _construireLigneInfo('Délai d\'instruction estimé', delai),
                const SizedBox(height: 10),
                _construireLigneInfo('Frais de timbre communal', frais),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _construireLigneInfo(String libelle, String valeur) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          libelle,
          style: GoogleFonts.publicSans(
            fontSize: 12,
            color: Palette.texteSecondaire,
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            valeur,
            textAlign: TextAlign.right,
            style: GoogleFonts.publicSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Palette.textePrimaire,
            ),
          ),
        ),
      ],
    );
  }
}

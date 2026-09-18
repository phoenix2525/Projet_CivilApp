import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/demande.dart';
import 'mes_demandes_page.dart';
import 'tableau_de_bord_citoyen_page.dart';

/// Page de confirmation après transmission d'une demande d'acte civil.
/// Présente le récapitulatif du dépôt, le numéro de suivi officiel
/// et offre des raccourcis vers le suivi ou l'accueil.
class ConfirmationEnvoiPage extends StatelessWidget {
  final Demande demande;

  const ConfirmationEnvoiPage({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Calcul d'un identifiant de suivi lisible pour l'usager
    final numeroSuivi = 'SN-${demande.dateDemande.year}-${demande.id.length >= 6 ? demande.id.substring(demande.id.length - 6) : demande.id}';

    // Nom du bénéficiaire ou titulaire de l'acte
    String beneficiaire = '${demande.citoyen.prenom} ${demande.citoyen.nom}';
    if (demande.donneesFormulaire.containsKey('prenom') && demande.donneesFormulaire.containsKey('nom')) {
      beneficiaire = '${demande.donneesFormulaire['prenom']} ${demande.donneesFormulaire['nom']}';
    } else if (demande.donneesFormulaire.containsKey('nom_epoux')) {
      beneficiaire = '${demande.donneesFormulaire['nom_epoux']} & ${demande.donneesFormulaire['nom_epouse']}';
    } else if (demande.donneesFormulaire.containsKey('nom_defunt')) {
      beneficiaire = '${demande.donneesFormulaire['prenom_defunt'] ?? ''} ${demande.donneesFormulaire['nom_defunt']} (Défunt)';
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icône de validation animée/stylisée
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: colorScheme.primary,
                        size: 64,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Titre principal
                    Text(
                      'Demande transmise !',
                      style: textTheme.headlineMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Message rassurant pour l'usager
                    Text(
                      'Votre dossier a bien été reçu par le bureau d\'état civil municipal. Il est actuellement en attente d\'instruction.',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Récépissé / Carte de synthèse de la démarche
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Ligne Type de document
                            _construireLigneRecapitulatif(
                              context,
                              icone: Icons.description_outlined,
                              libelle: 'Type de document',
                              valeur: demande.document.titre,
                            ),
                            const Divider(height: 28),

                            // Ligne Titulaire / Concerne
                            _construireLigneRecapitulatif(
                              context,
                              icone: Icons.person_outline,
                              libelle: 'Concerne',
                              valeur: beneficiaire,
                            ),
                            const Divider(height: 28),

                            // Ligne Numéro de suivi avec copie
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.qr_code_2, color: colorScheme.primary, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'N° de Suivi officiel',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        numeroSuivi,
                                        style: textTheme.titleMedium?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Copier le numéro',
                                  icon: const Icon(Icons.copy_rounded, size: 20),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(text: numeroSuivi));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Row(
                                          children: [
                                            Icon(Icons.check, color: Colors.white, size: 18),
                                            SizedBox(width: 8),
                                            Text('Numéro de suivi copié dans le presse-papiers !'),
                                          ],
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        margin: const EdgeInsets.all(16),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Actions de navigation
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const MesDemandesPage()),
                          );
                        },
                        icon: const Icon(Icons.assignment_outlined),
                        label: const Text(
                          'Suivre mes demandes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Retour au tableau de bord'),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
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

  /// Helper pour construire une rangée dans le récapitulatif
  Widget _construireLigneRecapitulatif(
    BuildContext context, {
    required IconData icone,
    required String libelle,
    required String valeur,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icone, color: colorScheme.onSurfaceVariant, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                libelle,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valeur,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

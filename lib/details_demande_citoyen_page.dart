import 'package:flutter/material.dart';
import 'models/demande.dart';

/// Page de consultation détaillée d'une demande d'acte pour le citoyen.
/// Affiche la progression administrative, les informations transmises
/// et les éventuelles instructions laissées par l'agent de la mairie.
class DetailsDemandeCitoyenPage extends StatelessWidget {
  final Demande demande;

  const DetailsDemandeCitoyenPage({super.key, required this.demande});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final numeroDossier = 'REQ-${demande.dateDemande.year}-${demande.id.length >= 6 ? demande.id.substring(demande.id.length - 6) : demande.id}';
    final dateTexte = '${demande.dateDemande.day.toString().padLeft(2, '0')}/${demande.dateDemande.month.toString().padLeft(2, '0')}/${demande.dateDemande.year} à ${demande.dateDemande.hour.toString().padLeft(2, '0')}:${demande.dateDemande.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de ma demande'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte d'en-tête avec Statut
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RÉF. $numeroDossier',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        _construireBadgeStatut(demande.statut),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      demande.document.titre,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 14, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Text(
                          'Soumise le $dateTexte',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Note de l'agent de mairie si disponible
            if (demande.noteAgent.trim().isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade400),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.mark_chat_unread_rounded, color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Message de l\'officier d\'état civil',
                          style: textTheme.titleSmall?.copyWith(
                            color: Colors.amber.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      demande.noteAgent,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.brown.shade900,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Section Suivi de l'avancement
            Text(
              'Parcours de la demande',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),

            _construireProgression(context),

            const SizedBox(height: 24),

            // Section Informations saisies
            Text(
              'Informations déclarées',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: _construireListeChamps(context),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section Pièces justificatives
            Text(
              'Pièces justificatives validées',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: demande.piecesFournies.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Bouton d'aide ou contact mairie
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Row(
                        children: [
                          Icon(Icons.info_outline),
                          SizedBox(width: 8),
                          Text('Service État Civil'),
                        ],
                      ),
                      content: const Text(
                        'Pour toute question sur l\'état d\'avancement de votre dossier, vous pouvez vous présenter au centre d\'état civil municipal muni de votre numéro de suivi.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Fermer'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.help_outline),
                label: const Text('Besoin d\'assistance pour ce dossier ?'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Badge de statut coloré avec libellé explicite
  Widget _construireBadgeStatut(String statut) {
    Color couleur;
    Color texteCouleur;
    String libelle;

    switch (statut.toLowerCase()) {
      case 'reçue':
        couleur = Colors.amber.shade100;
        texteCouleur = Colors.amber.shade900;
        libelle = 'Reçue';
        break;
      case 'en cours':
        couleur = Colors.blue.shade100;
        texteCouleur = Colors.blue.shade900;
        libelle = 'En cours';
        break;
      case 'prête':
        couleur = Colors.green.shade100;
        texteCouleur = Colors.green.shade900;
        libelle = 'Prête en mairie';
        break;
      case 'livrée':
        couleur = Colors.teal.shade100;
        texteCouleur = Colors.teal.shade900;
        libelle = 'Délivrée';
        break;
      default:
        couleur = Colors.grey.shade200;
        texteCouleur = Colors.black87;
        libelle = statut;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: couleur,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        libelle,
        style: TextStyle(
          color: texteCouleur,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Timeline verticale adaptée au statut actuel de la demande
  Widget _construireProgression(BuildContext context) {
    final statut = demande.statut.toLowerCase();

    final etape1Validee = true; // Reçue
    final etape2Validee = statut == 'en cours' || statut == 'prête' || statut == 'livrée';
    final etape3Validee = statut == 'prête' || statut == 'livrée';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _construireItemTimeline(
            context,
            titre: 'Demande enregistrée',
            sousTitre: 'Dossier transmis au service de la mairie',
            estValide: etape1Validee,
            estEnCours: statut == 'reçue',
            estDernier: false,
          ),
          _construireItemTimeline(
            context,
            titre: 'Instruction en cours',
            sousTitre: 'Contrôle des pièces et recherche dans le registre',
            estValide: etape2Validee,
            estEnCours: statut == 'en cours',
            estDernier: false,
          ),
          _construireItemTimeline(
            context,
            titre: statut == 'livrée' ? 'Acte remis au citoyen' : 'Document prêt pour retrait',
            sousTitre: statut == 'livrée' ? 'Procédure finalisée' : 'Disponible au guichet de l\'état civil',
            estValide: etape3Validee,
            estEnCours: statut == 'prête',
            estDernier: true,
          ),
        ],
      ),
    );
  }

  /// Rangée individuelle de la timeline
  Widget _construireItemTimeline(
    BuildContext context, {
    required String titre,
    required String sousTitre,
    required bool estValide,
    required bool estEnCours,
    required bool estDernier,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color couleurCercle = Colors.grey.shade300;
    IconData icone = Icons.circle_outlined;
    Color couleurIcone = Colors.grey.shade600;

    if (estValide) {
      couleurCercle = colorScheme.primary;
      icone = Icons.check;
      couleurIcone = colorScheme.onPrimary;
    } else if (estEnCours) {
      couleurCercle = Colors.orange;
      icone = Icons.hourglass_top;
      couleurIcone = Colors.white;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: couleurCercle,
              child: Icon(icone, size: 14, color: couleurIcone),
            ),
            if (!estDernier)
              Container(
                width: 2,
                height: 36,
                color: estValide ? colorScheme.primary : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titre,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: estValide || estEnCours ? theme.colorScheme.onSurface : Colors.grey.shade500,
                  ),
                ),
                Text(
                  sousTitre,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Liste des champs déclarés dans le formulaire
  List<Widget> _construireListeChamps(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    final widgets = <Widget>[];
    final entrees = demande.donneesFormulaire.entries.toList();

    for (int i = 0; i < entrees.length; i++) {
      final cle = entrees[i].key;
      final valeur = entrees[i].value;

      // Nettoyage et formatage du label
      final label = _formaterCle(cle);

      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Text(
                  valeur,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      );

      if (i < entrees.length - 1) {
        widgets.add(const Divider(height: 12, thickness: 0.5));
      }
    }

    return widgets;
  }

  /// Formate les clés de formulaire pour un affichage lisible
  String _formaterCle(String cle) {
    switch (cle) {
      case 'prenom': return 'Prénom(s)';
      case 'nom': return 'Nom';
      case 'sexe': return 'Sexe';
      case 'date_naissance': return 'Date de naissance';
      case 'heure_naissance': return 'Heure de naissance';
      case 'lieu_naissance': return 'Lieu de naissance';
      case 'numero_registre': return 'N° de Registre';
      case 'annee_registre': return 'Année du registre';
      case 'centre_etat_civil': return 'Centre d\'état civil';
      case 'prenom_pere': return 'Prénom du Père';
      case 'nom_pere': return 'Nom du Père';
      case 'profession_pere': return 'Profession du Père';
      case 'prenom_mere': return 'Prénom de la Mère';
      case 'nom_mere': return 'Nom de la Mère';
      case 'profession_mere': return 'Profession de la Mère';
      case 'domicile_parents': return 'Domicile des parents';
      case 'nom_epoux': return 'Nom de l\'époux';
      case 'prenom_epoux': return 'Prénom de l\'époux';
      case 'nom_epouse': return 'Nom de l\'épouse';
      case 'prenom_epouse': return 'Prénom de l\'épouse';
      case 'date_mariage': return 'Date du mariage';
      case 'lieu_mariage': return 'Lieu du mariage';
      case 'regime_matrimonial': return 'Régime matrimonial';
      case 'numero_acte_mariage': return 'N° d\'acte de mariage';
      case 'nom_defunt': return 'Nom du défunt';
      case 'prenom_defunt': return 'Prénom du défunt';
      case 'date_deces': return 'Date du décès';
      case 'lieu_deces': return 'Lieu du décès';
      case 'lien_parente_declarant': return 'Lien de parenté';
      case 'cni_declarant': return 'CNI du déclarant';
      default:
        return cle.replaceAll('_', ' ').toUpperCase();
    }
  }
}

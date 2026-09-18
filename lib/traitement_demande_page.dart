import 'package:flutter/material.dart';
import 'models/demande.dart';

/// Page de traitement d'une demande administrative par un agent de mairie.
/// Permet de consulter les informations du citoyen, les données de l'acte,
/// de vérifier les pièces justificatives, de mettre à jour le statut et d'ajouter des notes internes.
class TraitementDemandePage extends StatefulWidget {
  final Demande demande;

  const TraitementDemandePage({super.key, required this.demande});

  @override
  State<TraitementDemandePage> createState() => _TraitementDemandePageState();
}

class _TraitementDemandePageState extends State<TraitementDemandePage> {
  late String _statutActuel;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _statutActuel = widget.demande.statut;
    _noteController = TextEditingController(text: widget.demande.noteAgent);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  /// Notifie le citoyen de l'avancement de son dossier
  void _notifierCitoyen() {
    final notification = {
      'message': 'Votre demande de ${widget.demande.document.titre} est passée au statut : "$_statutActuel".',
      'date': DateTime.now(),
      'demandeId': widget.demande.id,
      'telephone': widget.demande.citoyen.telephone,
    };
    DatabaseSimulee.notifications.add(notification);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Notification transmise à ${widget.demande.citoyen.prenom} (${widget.demande.citoyen.telephone}) !',
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Met à jour le statut administratif de la demande
  void _changerStatut(String? nouveauStatut) {
    if (nouveauStatut != null) {
      setState(() {
        _statutActuel = nouveauStatut;
        widget.demande.statut = nouveauStatut;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Statut mis à jour : $nouveauStatut'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  /// Enregistre les annotations internes rédigées par l'agent
  void _enregistrerNote() {
    widget.demande.noteAgent = _noteController.text.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text('Note interne enregistrée.'),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final referenceCourt = 'REQ-${widget.demande.id.substring(widget.demande.id.length > 4 ? widget.demande.id.length - 4 : 0)}';
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails & Traitement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fil d'Ariane
            Row(
              children: [
                Text('Demandes > ', style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                Text(
                  referenceCourt,
                  style: textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Traitement : ${widget.demande.document.titre}',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Carte d'identité du demandeur
            _buildCitoyenCard(colorScheme, textTheme),
            const SizedBox(height: 16),

            // Carte des données saisies dans le formulaire
            _buildDonneesFormulaireCard(colorScheme, textTheme),
            const SizedBox(height: 16),

            // Carte des pièces justificatives fournies
            _buildPiecesCard(colorScheme, textTheme),
            const SizedBox(height: 16),

            // Carte de gestion du statut et envoi de notification
            _buildStatutCard(colorScheme, textTheme),
            const SizedBox(height: 16),

            // Carte des notes internes de l'agent
            _buildNotesCard(colorScheme, textTheme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Construit la carte récapitulative des informations du citoyen demandeur
  Widget _buildCitoyenCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                  radius: 24,
                  child: Icon(Icons.person, color: colorScheme.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.demande.citoyen.prenom} ${widget.demande.citoyen.nom}',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: colorScheme.primary, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'Demandeur Enregistré',
                              style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _infoRow(Icons.phone, 'Téléphone', widget.demande.citoyen.telephone),
            const SizedBox(height: 12),
            _infoRow(Icons.email, 'Email', widget.demande.citoyen.email),
            const SizedBox(height: 12),
            _infoRow(Icons.location_on, 'Adresse Domicile', widget.demande.citoyen.adresse),
          ],
        ),
      ),
    );
  }

  /// Construit la carte récapitulative des champs du formulaire
  Widget _buildDonneesFormulaireCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.demande.document.icon, color: widget.demande.document.couleur),
                const SizedBox(width: 8),
                Text('Données du Formulaire de Demande', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Informations administratives renseignées pour l\'acte :',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 24),

            if (widget.demande.donneesFormulaire.isEmpty)
              Text('Aucune donnée saisie.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))
            else
              ...widget.demande.donneesFormulaire.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _formaterCle(entry.key),
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          entry.value.isNotEmpty ? entry.value : '-',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Construit la carte de validation des pièces justificatives
  Widget _buildPiecesCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.checklist, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text('Pièces Justificatives Vérifiées', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Statut des justificatifs exigés pour cette démarche :',
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            const Divider(height: 24),
            if (widget.demande.piecesFournies.isEmpty)
              Text('Aucune pièce déclarée.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error))
            else
              ...widget.demande.piecesFournies.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'CONFORME',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  /// Construit la section de changement de statut et notification
  Widget _buildStatutCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gestion du Statut & Notification', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _statutActuel,
              decoration: const InputDecoration(
                labelText: 'Statut de traitement',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'reçue', child: Text('Reçue')),
                DropdownMenuItem(value: 'en cours', child: Text('En cours de traitement')),
                DropdownMenuItem(value: 'prête', child: Text('Prête pour retrait')),
                DropdownMenuItem(value: 'livrée', child: Text('Livrée / Finalisée')),
              ],
              onChanged: _changerStatut,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _notifierCitoyen,
                icon: const Icon(Icons.notifications_active),
                label: const Text('Envoyer une notification au citoyen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construit la section des notes internes de l'agent
  Widget _buildNotesCard(ColorScheme colorScheme, TextTheme textTheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.edit_note, color: colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Text('Notes internes Mairie (Agent)', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Saisissez des notes internes (ex: Registre N° 4, Folio 12)...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: _enregistrerNote,
                icon: const Icon(Icons.save),
                label: const Text('Enregistrer la note'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper pour reformater les clés techniques en libellés compréhensibles
  String _formaterCle(String cle) {
    switch (cle) {
      case 'prenom_enfant': return 'Prénom(s) enfant';
      case 'nom_enfant': return 'Nom enfant';
      case 'sexe': return 'Sexe';
      case 'date_naissance': return 'Date de naissance';
      case 'heure_naissance': return 'Heure de naissance';
      case 'lieu_naissance': return 'Lieu de naissance';
      case 'prenom_nom_pere': return 'Père';
      case 'profession_pere': return 'Profession père';
      case 'prenom_nom_mere': return 'Mère';
      case 'profession_mere': return 'Profession mère';
      case 'domicile_parents': return 'Domicile parents';
      case 'prenom_titulaire': return 'Prénom(s) titulaire';
      case 'nom_titulaire': return 'Nom titulaire';
      case 'num_registre': return 'N° de Registre / Acte';
      case 'annee_registre': return 'Année du Registre';
      case 'centre_etat_civil': return 'Centre d\'État Civil';
      case 'prenom_epoux': return 'Prénom(s) Époux';
      case 'nom_epoux': return 'Nom Époux';
      case 'date_naissance_epoux': return 'Date naissance Époux';
      case 'prenom_epouse': return 'Prénom(s) Épouse';
      case 'nom_epouse': return 'Nom Épouse';
      case 'date_naissance_epouse': return 'Date naissance Épouse';
      case 'date_mariage': return 'Date du Mariage';
      case 'lieu_mariage': return 'Lieu du Mariage';
      case 'regime_matrimonial': return 'Régime Matrimonial';
      case 'num_acte_mariage': return 'N° Acte de Mariage';
      case 'prenom_defunt': return 'Prénom(s) Défunt';
      case 'nom_defunt': return 'Nom Défunt';
      case 'date_naissance_defunt': return 'Date naissance Défunt';
      case 'date_deces': return 'Date du Décès';
      case 'heure_deces': return 'Heure du Décès';
      case 'lieu_deces': return 'Lieu du Décès';
      case 'prenom_nom_declarant': return 'Déclarant';
      case 'lien_parente_declarant': return 'Lien parenté déclarant';
      case 'cni_declarant': return 'CNI Déclarant';
      default:
        return cle.replaceAll('_', ' ');
    }
  }

  /// Ligne d'information stylisée
  Widget _infoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

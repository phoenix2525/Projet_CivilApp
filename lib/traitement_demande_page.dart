import 'package:flutter/material.dart';
import 'models/demande.dart';

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

  void _notifierCitoyen() {
    final notification = {
      'message': 'Votre demande de ${widget.demande.document.titre} est maintenant "$_statutActuel".',
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
              child: Text('Notification envoyée à ${widget.demande.citoyen.prenom} (${widget.demande.citoyen.telephone}) !'),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  void _changerStatut(String? nouveauStatut) {
    if (nouveauStatut != null) {
      setState(() {
        _statutActuel = nouveauStatut;
        widget.demande.statut = nouveauStatut;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Statut mis à jour : $nouveauStatut')),
      );
    }
  }

  void _enregistrerNote() {
    widget.demande.noteAgent = _noteController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Note interne enregistrée avec succès.'),
        backgroundColor: Colors.green.shade700,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
              style: textTheme.headlineSmall?.copyWith(color: colorScheme.primary),
            ),
            const SizedBox(height: 24),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
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
                                style: textTheme.titleLarge,
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
                                      'Demandeur Officiel Enregistré',
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
                    const Divider(height: 32),
                    _infoRow(Icons.phone, 'Téléphone', widget.demande.citoyen.telephone, context),
                    const SizedBox(height: 12),
                    _infoRow(Icons.email, 'Email', widget.demande.citoyen.email, context),
                    const SizedBox(height: 12),
                    _infoRow(Icons.location_on, 'Adresse Domicile', widget.demande.citoyen.adresse, context),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(widget.demande.document.icon, color: widget.demande.document.couleur),
                        const SizedBox(width: 8),
                        Text(
                          'Données du Formulaire de Demande',
                          style: textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informations nécessaires pour l\'établissement de l\'acte administratif :',
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const Divider(height: 24),

                    if (widget.demande.donneesFormulaire.isEmpty)
                      Text('Aucune donnée saisie.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant))
                    else
                      ...widget.demande.donneesFormulaire.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  _formaterCle(entry.key),
                                  style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
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
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.checklist, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text('Pièces Justificatives Vérifiées', style: textTheme.titleMedium),
                      ],
                    ),
                    const Divider(height: 24),
                    if (widget.demande.piecesFournies.isEmpty)
                      Text('Aucune pièce déclarée.', style: textTheme.bodyMedium?.copyWith(color: colorScheme.error))
                    else
                      ...widget.demande.piecesFournies.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.image, color: colorScheme.secondary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.remove_red_eye, color: colorScheme.primary),
                                tooltip: 'Voir l\'image',
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Ouverture de ${entry.value}')),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Gestion du Statut & Notification', style: textTheme.titleMedium),
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
                        DropdownMenuItem(value: 'prête', child: Text('Prête pour retrait/livraison')),
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
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text('Notes internes Mairie (Agent)', style: textTheme.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Saisissez des notes internes (ex: registre volume 3 p. 45)...',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _enregistrerNote,
                        icon: const Icon(Icons.save),
                        label: const Text('Enregistrer la note'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Helper pour reformater les clés de données en libellés lisibles
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
      case 'num_registre': return 'N° de Registre/Acte';
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
        return cle.replaceAll('_', ' ').toUpperCase();
    }
  }

  Widget _infoRow(IconData icon, String label, String value, BuildContext context) {
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
                  letterSpacing: 1,
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

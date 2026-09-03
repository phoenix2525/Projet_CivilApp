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

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Détails & Traitement', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fil d'ariane
            Row(
              children: [
                const Text('Demandes > ', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  referenceCourt,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Traitement : ${widget.demande.document.titre}',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green.shade900),
            ),
            const SizedBox(height: 16),

            // Carte 1: Identité du Citoyen Demandeur
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          radius: 24,
                          child: const Icon(Icons.person, color: Colors.green, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${widget.demande.citoyen.prenom} ${widget.demande.citoyen.nom}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified, color: Colors.green.shade700, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Demandeur Officiel Enregistré',
                                      style: TextStyle(color: Colors.green.shade700, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _infoRow(Icons.phone, 'Téléphone', widget.demande.citoyen.telephone),
                    const SizedBox(height: 8),
                    _infoRow(Icons.email, 'Email', widget.demande.citoyen.email),
                    const SizedBox(height: 8),
                    _infoRow(Icons.location_on, 'Adresse Domicile', widget.demande.citoyen.adresse),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Carte 2: Données administratives requises saisies dans le formulaire
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(widget.demande.document.icon, color: widget.demande.document.couleur),
                        const SizedBox(width: 8),
                        Text(
                          'Données du Formulaire de Demande',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Informations nécessaires pour l\'établissement de l\'acte administratif :',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    const Divider(height: 20),

                    if (widget.demande.donneesFormulaire.isEmpty)
                      const Text('Aucune donnée saisie.', style: TextStyle(color: Colors.grey))
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
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  entry.value.isNotEmpty ? entry.value : '-',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
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

            // Carte 3: Check-list et Pièces Fournies
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.checklist, color: Colors.green.shade800),
                        const SizedBox(width: 8),
                        const Text('Pièces Justificatives Vérifiées', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 20),
                    if (widget.demande.piecesFournies.isEmpty)
                      const Text('Aucune pièce déclarée.', style: TextStyle(color: Colors.red))
                    else
                      ...widget.demande.piecesFournies.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              const Icon(Icons.image, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                tooltip: 'Voir l\'image (Simulé)',
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

            // Carte 4: Modification du Statut & Notification
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gestion du Statut & Notification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                        icon: const Icon(Icons.notifications_active, color: Colors.white),
                        label: const Text('Envoyer une notification au citoyen', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade900,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Carte 5: Notes internes Agent
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.edit_note, color: Colors.grey.shade700),
                        const SizedBox(width: 8),
                        const Text('Notes internes Mairie (Agent)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Saisissez des notes internes (ex: registre volume 3 p. 45)...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: _enregistrerNote,
                        icon: const Icon(Icons.save),
                        label: const Text('Enregistrer la note'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green.shade900,
                          side: BorderSide(color: Colors.green.shade900),
                        ),
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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

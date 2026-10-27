import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
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
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Notification transmise à ${widget.demande.citoyen.prenom} (${widget.demande.citoyen.telephone})',
              ),
            ),
          ],
        ),
        backgroundColor: Palette.primaire,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(16),
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
        SnackBar(
          content: Text('Statut mis à jour : $nouveauStatut'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _enregistrerNote() {
    final note = _noteController.text.trim();
    widget.demande.noteAgent = note;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Observation interne enregistrée dans le registre municipal.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.fond,
      appBar: AppBar(
        title: const Text('Détails & Traitement'),
        backgroundColor: Palette.primaire,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCitoyenCard(),
            const SizedBox(height: 14),
            _buildDonneesFormulaireCard(),
            const SizedBox(height: 14),
            _buildPiecesCard(),
            const SizedBox(height: 14),
            _buildStatutCard(),
            const SizedBox(height: 14),
            _buildNotesCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCitoyenCard() {
    return Container(
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
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Palette.surfaceSecondaire,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Palette.bordure, width: 1),
                ),
                child: Center(
                  child: Text(
                    widget.demande.citoyen.prenom.isNotEmpty ? widget.demande.citoyen.prenom[0].toUpperCase() : 'C',
                    style: GoogleFonts.publicSans(fontSize: 16, fontWeight: FontWeight.w700, color: Palette.primaire),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.demande.citoyen.prenom} ${widget.demande.citoyen.nom}',
                      style: GoogleFonts.publicSans(fontSize: 15, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Demandeur officiel',
                      style: GoogleFonts.publicSans(fontSize: 11, color: Palette.texteSecondaire),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Palette.bordure),
          _infoRow(Icons.phone_outlined, 'Téléphone', widget.demande.citoyen.telephone),
          const SizedBox(height: 8),
          _infoRow(Icons.email_outlined, 'Email', widget.demande.citoyen.email),
          const SizedBox(height: 8),
          _infoRow(Icons.location_on_outlined, 'Résidence', widget.demande.citoyen.adresse),
        ],
      ),
    );
  }

  Widget _buildDonneesFormulaireCard() {
    return Container(
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
            children: [
              Icon(widget.demande.document.icon, color: widget.demande.document.couleur, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Données de l\'acte : ${widget.demande.document.titre}',
                  style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Palette.bordure),

          if (widget.demande.donneesFormulaire.isEmpty)
            Text(
              'Aucune donnée saisie.',
              style: GoogleFonts.publicSans(color: Palette.texteDiscret, fontSize: 12),
            )
          else
            ...widget.demande.donneesFormulaire.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        _formaterCle(entry.key),
                        style: GoogleFonts.publicSans(fontSize: 11, color: Palette.texteSecondaire, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        entry.value.isNotEmpty ? entry.value : '-',
                        style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600, color: Palette.textePrimaire),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPiecesCard() {
    return Container(
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
            children: [
              const Icon(Icons.checklist_outlined, color: Palette.primaire, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Contrôle des pièces justificatives',
                  style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Palette.bordure),

          if (widget.demande.piecesFournies.isEmpty)
            Text('Aucune pièce déclarée.', style: GoogleFonts.publicSans(color: Palette.statutRejetee, fontSize: 12))
          else
            ...widget.demande.piecesFournies.entries.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6.0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Palette.surfaceSecondaire,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Palette.bordure, width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: Palette.validation, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: GoogleFonts.publicSans(fontSize: 12, color: Palette.textePrimaire),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Palette.surface,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Palette.bordure, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Palette.validation,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CONFORME',
                            style: GoogleFonts.publicSans(
                              color: Palette.validation,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStatutCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mise à jour du statut',
            style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _statutActuel,
            decoration: const InputDecoration(
              labelText: 'Statut officiel',
            ),
            items: const [
              DropdownMenuItem(value: 'reçue', child: Text('Reçue')),
              DropdownMenuItem(value: 'en cours', child: Text('En cours d\'instruction')),
              DropdownMenuItem(value: 'prête', child: Text('Prête pour retrait')),
              DropdownMenuItem(value: 'livrée', child: Text('Délivrée / Clôturée')),
            ],
            onChanged: _changerStatut,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _notifierCitoyen,
              icon: const Icon(Icons.notifications_active_outlined, size: 18),
              label: const Text('Notifier le citoyen'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
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
            children: [
              const Icon(Icons.edit_note_outlined, color: Palette.primaire, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Mentions et annotations internes (Mairie)',
                  style: GoogleFonts.publicSans(fontSize: 14, fontWeight: FontWeight.w700, color: Palette.textePrimaire),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 3,
            style: GoogleFonts.publicSans(fontSize: 13),
            decoration: const InputDecoration(
              hintText: 'Mentions internes (ex: Registre N° 4, Folio 12, Acte N° 45)...',
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _enregistrerNote,
              icon: const Icon(Icons.save_outlined, size: 16),
              label: const Text('Enregistrer la mention'),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Palette.texteSecondaire),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.publicSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Palette.texteDiscret,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.w600, color: Palette.textePrimaire),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

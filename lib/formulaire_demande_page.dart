import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import 'models/document.dart';
import 'models/demande.dart';
import 'confirmation_envoi_page.dart';

/// Page de formulaire de demande d'acte d'état civil.
/// Le formulaire est dynamique : il s'adapte au type de document sélectionné.
class FormulaireDemandePage extends StatefulWidget {
  final Document document;

  const FormulaireDemandePage({super.key, required this.document});

  @override
  State<FormulaireDemandePage> createState() => _FormulaireDemandePageState();
}

class _FormulaireDemandePageState extends State<FormulaireDemandePage> {
  final _formKey = GlobalKey<FormState>();

  // Contrôleurs pour la saisie des champs selon le type d'acte
  final Map<String, TextEditingController> _controllers = {};

  // État de la checklist des pièces à fournir (cochée ou non)
  final Map<String, bool> _piecesCochees = {};

  // Valeurs des menus déroulants spécifiques à certains actes
  String _sexeTitulaire = 'Masculin';
  String _regimeMatrimonial = 'Monogamie - Séparation de biens';
  String _lienParenteDeclarant = 'Enfant';

  @override
  void initState() {
    super.initState();
    // Initialisation des champs de saisie selon l'acte choisi
    _initialiserChamps();
    // Initialisation de la checklist : toutes les pièces sont non cochées au départ
    for (var piece in widget.document.piecesAFournir) {
      _piecesCochees[piece] = false;
    }
  }

  /// Crée les contrôleurs de champs selon le type d'acte d'état civil
  void _initialiserChamps() {
    switch (widget.document.id) {
      case 'acte_naissance':
        _controllers['prenom_enfant'] = TextEditingController();
        _controllers['nom_enfant'] = TextEditingController();
        _controllers['date_naissance'] = TextEditingController();
        _controllers['heure_naissance'] = TextEditingController();
        _controllers['lieu_naissance'] = TextEditingController();
        _controllers['prenom_nom_pere'] = TextEditingController();
        _controllers['profession_pere'] = TextEditingController();
        _controllers['prenom_nom_mere'] = TextEditingController();
        _controllers['profession_mere'] = TextEditingController();
        _controllers['domicile_parents'] = TextEditingController();
        break;

      case 'extrait_naissance':
        _controllers['prenom_titulaire'] = TextEditingController();
        _controllers['nom_titulaire'] = TextEditingController();
        _controllers['date_naissance'] = TextEditingController();
        _controllers['lieu_naissance'] = TextEditingController();
        _controllers['num_registre'] = TextEditingController();
        _controllers['annee_registre'] = TextEditingController();
        _controllers['centre_etat_civil'] = TextEditingController();
        _controllers['prenom_nom_pere'] = TextEditingController();
        _controllers['prenom_nom_mere'] = TextEditingController();
        break;

      case 'certificat_mariage':
        _controllers['prenom_epoux'] = TextEditingController();
        _controllers['nom_epoux'] = TextEditingController();
        _controllers['date_naissance_epoux'] = TextEditingController();
        _controllers['prenom_epouse'] = TextEditingController();
        _controllers['nom_epouse'] = TextEditingController();
        _controllers['date_naissance_epouse'] = TextEditingController();
        _controllers['date_mariage'] = TextEditingController();
        _controllers['lieu_mariage'] = TextEditingController();
        _controllers['num_acte_mariage'] = TextEditingController();
        break;

      case 'certificat_deces':
        _controllers['prenom_defunt'] = TextEditingController();
        _controllers['nom_defunt'] = TextEditingController();
        _controllers['date_naissance_defunt'] = TextEditingController();
        _controllers['date_deces'] = TextEditingController();
        _controllers['heure_deces'] = TextEditingController();
        _controllers['lieu_deces'] = TextEditingController();
        _controllers['prenom_nom_declarant'] = TextEditingController();
        _controllers['cni_declarant'] = TextEditingController();
        break;

      default:
        _controllers['remarques'] = TextEditingController();
        break;
    }
  }

  @override
  void dispose() {
    // Libération de la mémoire de tous les contrôleurs
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Vérifie que toutes les pièces obligatoires ont été cochées
  bool _toutesPiecesCochees() {
    return _piecesCochees.values.every((cochee) => cochee == true);
  }

  /// Soumet la demande après validation du formulaire et de la checklist
  void _soumettreDemande() {
    // Vérification de la présence d'un citoyen connecté
    if (DatabaseSimulee.citoyenConnecte == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : aucun profil citoyen trouvé.')),
      );
      return;
    }

    // Vérification que toutes les pièces sont cochées
    if (!_toutesPiecesCochees()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Veuillez cocher toutes les pièces requises.')),
            ],
          ),
          backgroundColor: Palette.statutEnCours,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    // Validation des champs du formulaire
    if (_formKey.currentState!.validate()) {
      // Extraction des données saisies
      final Map<String, String> donnees = {};
      _controllers.forEach((cle, controller) {
        donnees[cle] = controller.text.trim();
      });

      // Ajout des options déroulantes au résultat
      if (widget.document.id == 'acte_naissance' ||
          widget.document.id == 'extrait_naissance') {
        donnees['sexe'] = _sexeTitulaire;
      } else if (widget.document.id == 'certificat_mariage') {
        donnees['regime_matrimonial'] = _regimeMatrimonial;
      } else if (widget.document.id == 'certificat_deces') {
        donnees['lien_parente_declarant'] = _lienParenteDeclarant;
      }

      // Construction de la map des pièces fournies (cochées)
      final Map<String, String> piecesFournies = {};
      _piecesCochees.forEach((piece, cochee) {
        if (cochee) piecesFournies[piece] = 'fournie';
      });

      // Création et enregistrement de la demande en mémoire
      final nouvelleDemande = Demande(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        document: widget.document,
        citoyen: DatabaseSimulee.citoyenConnecte!,
        dateDemande: DateTime.now(),
        donneesFormulaire: donnees,
        piecesFournies: piecesFournies,
        statut: 'reçue',
      );

      // Enregistrement de la demande en tête de liste de la base simulée
      DatabaseSimulee.demandes.insert(0, nouvelleDemande);

      // Redirection vers la page de confirmation officielle de dépôt
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationEnvoiPage(demande: nouvelleDemande),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Palette.fond,
      appBar: AppBar(
        title: Text(
          'Demande : ${widget.document.titre}',
          style: GoogleFonts.publicSans(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        backgroundColor: Palette.primaire,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête du document sélectionné sobre
                _construireEnTeteDocument(textTheme),
                const SizedBox(height: 20),

                // Formulaire adapté au type d'acte sélectionné
                _construireFormulaireSpecifique(),
                const SizedBox(height: 20),

                // Section checklist des pièces justificatives
                _construireChecklistPieces(textTheme),
                const SizedBox(height: 24),

                // Boutons d'action (Annuler / Envoyer)
                _construireBoutonsAction(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// En-tête avec l'image du document et bordure sobre
  Widget _construireEnTeteDocument(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      child: Row(
        children: [
          Hero(
            tag: 'doc_icon_${widget.document.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                widget.document.imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Palette.surfaceSecondaire,
                  child: Icon(widget.document.icon, color: widget.document.couleur, size: 28),
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
                  widget.document.titre,
                  style: GoogleFonts.publicSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Palette.textePrimaire,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  widget.document.description,
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    color: Palette.texteSecondaire,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le formulaire de saisie approprié selon le type d'acte
  Widget _construireFormulaireSpecifique() {
    switch (widget.document.id) {
      case 'acte_naissance':
        return _formulaireActeNaissance();
      case 'extrait_naissance':
        return _formulaireExtraitNaissance();
      case 'certificat_mariage':
        return _formulaireCertificatMariage();
      case 'certificat_deces':
        return _formulaireCertificatDeces();
      default:
        return Container();
    }
  }

  /// Checklist interactive des pièces justificatives à cocher
  Widget _construireChecklistPieces(TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pièces justificatives requises',
          style: GoogleFonts.publicSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Palette.textePrimaire,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Veuillez confirmer que vous disposez des originaux obligatoires :',
          style: GoogleFonts.publicSans(
            fontSize: 12,
            color: Palette.texteSecondaire,
          ),
        ),
        const SizedBox(height: 12),

        ...widget.document.piecesAFournir.map((piece) {
          final estCochee = _piecesCochees[piece] ?? false;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: estCochee ? Palette.statutPreteFond : Palette.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: estCochee ? Palette.validation : Palette.bordure,
                width: 1,
              ),
            ),
            child: CheckboxListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              dense: true,
              title: Text(
                piece,
                style: GoogleFonts.publicSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Palette.textePrimaire,
                ),
              ),
              subtitle: Text(
                estCochee ? 'Pièce confirmée' : 'Pièce requise obligatoire',
                style: GoogleFonts.publicSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: estCochee ? Palette.validation : Palette.statutRejetee,
                ),
              ),
              value: estCochee,
              activeColor: Palette.validation,
              onChanged: (valeur) {
                setState(() {
                  _piecesCochees[piece] = valeur ?? false;
                });
              },
            ),
          );
        }),
      ],
    );
  }

  /// Boutons bas de page : Annuler et Envoyer la demande
  Widget _construireBoutonsAction() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _soumettreDemande,
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Envoyer la demande'),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // --- Formulaires spécifiques par type d'acte ---
  // ---------------------------------------------------------------------------

  /// Formulaire pour la déclaration / copie intégrale d'acte de naissance
  Widget _formulaireActeNaissance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Informations sur le Nouveau-né'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_enfant'],
                decoration: const InputDecoration(
                  labelText: 'Prénom(s) de l\'enfant *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_enfant'],
                decoration: const InputDecoration(
                  labelText: 'Nom de famille *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _sexeTitulaire,
                decoration: const InputDecoration(labelText: 'Sexe *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Masculin', child: Text('Masculin')),
                  DropdownMenuItem(value: 'Féminin', child: Text('Féminin')),
                ],
                onChanged: (v) => setState(() => _sexeTitulaire = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['date_naissance'],
                decoration: const InputDecoration(
                  labelText: 'Date de naissance *',
                  hintText: 'JJ/MM/AAAA',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['heure_naissance'],
                decoration: const InputDecoration(
                  labelText: 'Heure de naissance',
                  hintText: 'Ex: 14h30',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['lieu_naissance'],
                decoration: const InputDecoration(
                  labelText: 'Lieu / Hôpital *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitre('Filiation (Parents)'),
        TextFormField(
          controller: _controllers['prenom_nom_pere'],
          decoration: const InputDecoration(
            labelText: 'Prénom et Nom du Père *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['profession_pere'],
          decoration: const InputDecoration(
            labelText: 'Profession du Père',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['prenom_nom_mere'],
          decoration: const InputDecoration(
            labelText: 'Prénom et Nom de la Mère *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['profession_mere'],
          decoration: const InputDecoration(
            labelText: 'Profession de la Mère',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['domicile_parents'],
          decoration: const InputDecoration(
            labelText: 'Domicile des parents *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
      ],
    );
  }

  /// Formulaire pour la demande d'extrait de naissance
  Widget _formulaireExtraitNaissance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Informations du Titulaire'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_titulaire'],
                decoration: const InputDecoration(
                  labelText: 'Prénom(s) *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_titulaire'],
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _sexeTitulaire,
                decoration: const InputDecoration(labelText: 'Sexe *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Masculin', child: Text('Masculin')),
                  DropdownMenuItem(value: 'Féminin', child: Text('Féminin')),
                ],
                onChanged: (v) => setState(() => _sexeTitulaire = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['date_naissance'],
                decoration: const InputDecoration(
                  labelText: 'Date de naissance *',
                  hintText: 'JJ/MM/AAAA',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['lieu_naissance'],
          decoration: const InputDecoration(
            labelText: 'Lieu de naissance *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations du Registre'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['num_registre'],
                decoration: const InputDecoration(
                  labelText: 'N° Acte / Registre *',
                  hintText: 'Ex: 1234',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['annee_registre'],
                decoration: const InputDecoration(
                  labelText: 'Année du Registre *',
                  hintText: 'Ex: 2002',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['centre_etat_civil'],
          decoration: const InputDecoration(
            labelText: 'Centre d\'État Civil *',
            hintText: 'Ex: Mairie de Dakar-Plateau',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Filiation'),
        TextFormField(
          controller: _controllers['prenom_nom_pere'],
          decoration: const InputDecoration(
            labelText: 'Prénom et Nom du Père *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['prenom_nom_mere'],
          decoration: const InputDecoration(
            labelText: 'Prénom et Nom de la Mère *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
      ],
    );
  }

  /// Formulaire pour la demande de certificat de mariage
  Widget _formulaireCertificatMariage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Informations de l\'Époux'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_epoux'],
                decoration: const InputDecoration(
                  labelText: 'Prénom(s) de l\'Époux *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_epoux'],
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'Époux *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['date_naissance_epoux'],
          decoration: const InputDecoration(
            labelText: 'Date de naissance de l\'Époux *',
            hintText: 'JJ/MM/AAAA',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations de l\'Épouse'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_epouse'],
                decoration: const InputDecoration(
                  labelText: 'Prénom(s) de l\'Épouse *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_epouse'],
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'Épouse *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['date_naissance_epouse'],
          decoration: const InputDecoration(
            labelText: 'Date de naissance de l\'Épouse *',
            hintText: 'JJ/MM/AAAA',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations de l\'Union'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['date_mariage'],
                decoration: const InputDecoration(
                  labelText: 'Date du Mariage *',
                  hintText: 'JJ/MM/AAAA',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['lieu_mariage'],
                decoration: const InputDecoration(
                  labelText: 'Lieu de Célébration *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: _regimeMatrimonial,
          decoration: const InputDecoration(
            labelText: 'Régime Matrimonial *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Monogamie - Séparation de biens', child: Text('Monogamie - Séparation de biens', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: 'Monogamie - Communauté de biens', child: Text('Monogamie - Communauté de biens', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: 'Polygamie (Limitée à 2 femmes)', child: Text('Polygamie (Limitée à 2 femmes)', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: 'Polygamie (Limitée à 3 femmes)', child: Text('Polygamie (Limitée à 3 femmes)', overflow: TextOverflow.ellipsis)),
            DropdownMenuItem(value: 'Polygamie (Limitée à 4 femmes)', child: Text('Polygamie (Limitée à 4 femmes)', overflow: TextOverflow.ellipsis)),
          ],
          onChanged: (v) => setState(() => _regimeMatrimonial = v!),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['num_acte_mariage'],
          decoration: const InputDecoration(
            labelText: 'N° Acte de Mariage / Registre (si connu)',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  /// Formulaire pour la demande de certificat de décès
  Widget _formulaireCertificatDeces() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Informations sur le Défunt'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_defunt'],
                decoration: const InputDecoration(
                  labelText: 'Prénom(s) du Défunt *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_defunt'],
                decoration: const InputDecoration(
                  labelText: 'Nom du Défunt *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['date_naissance_defunt'],
          decoration: const InputDecoration(
            labelText: 'Date de naissance du Défunt',
            hintText: 'JJ/MM/AAAA',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['date_deces'],
                decoration: const InputDecoration(
                  labelText: 'Date du Décès *',
                  hintText: 'JJ/MM/AAAA',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['heure_deces'],
                decoration: const InputDecoration(
                  labelText: 'Heure du Décès',
                  hintText: 'Ex: 08h15',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['lieu_deces'],
          decoration: const InputDecoration(
            labelText: 'Lieu du Décès (Hôpital / Commune) *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations du Déclarant'),
        TextFormField(
          controller: _controllers['prenom_nom_declarant'],
          decoration: const InputDecoration(
            labelText: 'Prénom et Nom du Déclarant *',
            border: OutlineInputBorder(),
          ),
          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                value: _lienParenteDeclarant,
                decoration: const InputDecoration(
                  labelText: 'Lien de Parenté *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Conjoint(e)', child: Text('Conjoint(e)')),
                  DropdownMenuItem(value: 'Enfant', child: Text('Enfant')),
                  DropdownMenuItem(value: 'Père / Mère', child: Text('Père / Mère')),
                  DropdownMenuItem(value: 'Frère / Sœur', child: Text('Frère / Sœur')),
                  DropdownMenuItem(value: 'Autre proche', child: Text('Autre proche')),
                ],
                onChanged: (v) => setState(() => _lienParenteDeclarant = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['cni_declarant'],
                decoration: const InputDecoration(
                  labelText: 'N° CNI du Déclarant *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Champ requis' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Widget helper : titre de section avec séparateur
  Widget _sectionTitre(String titre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: GoogleFonts.publicSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Palette.primaire,
            ),
          ),
          const Divider(color: Palette.bordure, height: 16),
        ],
      ),
    );
  }
}

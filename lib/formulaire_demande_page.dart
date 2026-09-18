import 'dart:ui';
import 'package:flutter/material.dart';
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
          backgroundColor: Colors.orange.shade700,
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

      DatabaseSimulee.demandes.add(nouvelleDemande);

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
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Demande : ${widget.document.titre}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colorScheme.primary,
        // AppBar glassmorphisme pour un rendu moderne
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: colorScheme.surface.withValues(alpha: 0.7)),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Fond dégradé léger
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F5E9), Color(0xFFFAFAFA)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête du document sélectionné avec effet Glassmorphism et Hero
                    _construireEnTeteDocument(colorScheme, textTheme),
                    const SizedBox(height: 24),

                    // Formulaire adapté au type d'acte sélectionné
                    _construireFormulaireSpecifique(colorScheme),
                    const SizedBox(height: 24),

                    // Section checklist des pièces justificatives
                    _construireChecklistPieces(colorScheme, textTheme),
                    const SizedBox(height: 32),

                    // Boutons d'action (Annuler / Envoyer)
                    _construireBoutonsAction(colorScheme),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// En-tête avec l'image du document et l'effet Hero venant du catalogue
  Widget _construireEnTeteDocument(ColorScheme colorScheme, TextTheme textTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            children: [
              // Image animée Hero : suit la transition depuis le catalogue
              Hero(
                tag: 'doc_icon_${widget.document.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    widget.document.imagePath,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 70,
                      height: 70,
                      color: widget.document.couleur.withValues(alpha: 0.2),
                      child: Icon(widget.document.icon, color: widget.document.couleur, size: 32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.document.titre,
                      style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.document.description,
                      style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit le formulaire de saisie approprié selon le type d'acte
  Widget _construireFormulaireSpecifique(ColorScheme colorScheme) {
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
  Widget _construireChecklistPieces(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pièces justificatives à fournir',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Cochez chaque pièce que vous avez en votre possession :',
          style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
        ),
        const Divider(height: 20),

        // Génération de la checklist selon les pièces du document sélectionné
        ...widget.document.piecesAFournir.map((piece) {
          final estCochee = _piecesCochees[piece] ?? false;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: estCochee ? Colors.green.shade50 : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: estCochee ? Colors.green.shade400 : Colors.grey.shade300,
              ),
            ),
            child: CheckboxListTile(
              title: Text(piece, style: textTheme.bodyMedium),
              subtitle: Text(
                estCochee ? 'Pièce confirmée ✓' : 'Pièce requise *',
                style: TextStyle(
                  fontSize: 11,
                  color: estCochee ? Colors.green.shade700 : Colors.red.shade400,
                ),
              ),
              value: estCochee,
              activeColor: colorScheme.primary,
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
  Widget _construireBoutonsAction(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Annuler', style: TextStyle(fontSize: 16, color: Colors.black54)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _soumettreDemande,
            icon: const Icon(Icons.send, color: Colors.white),
            label: const Text('Envoyer', style: TextStyle(fontSize: 16, color: Colors.white)),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
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
                initialValue: _sexeTitulaire,
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
                initialValue: _sexeTitulaire,
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
          initialValue: _regimeMatrimonial,
          decoration: const InputDecoration(
            labelText: 'Régime Matrimonial *',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'Monogamie - Séparation de biens', child: Text('Monogamie - Séparation de biens')),
            DropdownMenuItem(value: 'Monogamie - Communauté de biens', child: Text('Monogamie - Communauté de biens')),
            DropdownMenuItem(value: 'Polygamie (Limitée à 2 femmes)', child: Text('Polygamie (Limitée à 2 femmes)')),
            DropdownMenuItem(value: 'Polygamie (Limitée à 3 femmes)', child: Text('Polygamie (Limitée à 3 femmes)')),
            DropdownMenuItem(value: 'Polygamie (Limitée à 4 femmes)', child: Text('Polygamie (Limitée à 4 femmes)')),
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
                initialValue: _lienParenteDeclarant,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

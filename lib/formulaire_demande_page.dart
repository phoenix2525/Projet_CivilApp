import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'models/document.dart';
import 'models/demande.dart';

class FormulaireDemandePage extends StatefulWidget {
  final Document document;

  const FormulaireDemandePage({super.key, required this.document});

  @override
  State<FormulaireDemandePage> createState() => _FormulaireDemandePageState();
}

class _FormulaireDemandePageState extends State<FormulaireDemandePage> {
  final _formKey = GlobalKey<FormState>();

  // Map des contrôleurs pour la saisie dynamique des champs selon le type de document
  final Map<String, TextEditingController> _controllers = {};

  // Map des chemins d'images sélectionnées pour les pièces à fournir
  final Map<String, String?> _fichiersPieces = {};
  
  final ImagePicker _picker = ImagePicker();

  // Valeurs sélectionnées pour les listes déroulantes spécifiques
  String _sexeTitulaire = 'Masculin';
  String _regimeMatrimonial = 'Monogamie - Séparation de biens';
  String _lienParenteDeclarant = 'Enfant';

  @override
  void initState() {
    super.initState();

    // Initialisation des contrôleurs spécifiques au type de document
    _initialiserChamps();

    // Initialisation de la checklist des pièces requises pour ce document
    for (var piece in widget.document.piecesAFournir) {
      _fichiersPieces[piece] = null;
    }
  }

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
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Vérifie si toutes les pièces obligatoires ont été uploadées
  bool _toutesPiecesFournies() {
    return _fichiersPieces.values.every((chemin) => chemin != null);
  }

  Future<void> _prendrePhoto(String piece) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _fichiersPieces[piece] = photo.path;
      });
    }
  }

  Future<void> _choisirGalerie(String piece) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _fichiersPieces[piece] = image.path;
      });
    }
  }

  void _soumettreDemande() {
    if (DatabaseSimulee.citoyenConnecte == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: Aucun profil citoyen trouvé !')),
      );
      return;
    }

    if (!_toutesPiecesFournies()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez fournir TOUTES les pièces requises (photos/images).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Extraire les données saisies
      final Map<String, String> donnees = {};
      _controllers.forEach((cle, controller) {
        donnees[cle] = controller.text.trim();
      });

      // Ajouter les options sélectionnées
      if (widget.document.id == 'acte_naissance' || widget.document.id == 'extrait_naissance') {
        donnees['sexe'] = _sexeTitulaire;
      } else if (widget.document.id == 'certificat_mariage') {
        donnees['regime_matrimonial'] = _regimeMatrimonial;
      } else if (widget.document.id == 'certificat_deces') {
        donnees['lien_parente_declarant'] = _lienParenteDeclarant;
      }

      // Filtrer et caster la map des pièces
      final Map<String, String> piecesUploadees = {};
      _fichiersPieces.forEach((piece, chemin) {
        if (chemin != null) piecesUploadees[piece] = chemin;
      });

      // Création et sauvegarde de la demande
      final nouvelleDemande = Demande(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        document: widget.document,
        citoyen: DatabaseSimulee.citoyenConnecte!,
        dateDemande: DateTime.now(),
        donneesFormulaire: donnees,
        piecesFournies: piecesUploadees,
        statut: 'reçue',
      );

      DatabaseSimulee.demandes.add(nouvelleDemande);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Demande de ${widget.document.titre} transmise à la mairie avec succès !'),
          backgroundColor: Colors.green.shade800,
        ),
      );
      Navigator.pop(context); // Retour au catalogue
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Demande : ${widget.document.titre}'),
        backgroundColor: Colors.green.shade900,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du document choisi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: widget.document.couleur.withValues(alpha: 0.2),
                      child: Icon(widget.document.icon, color: widget.document.couleur, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.document.titre,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.document.description,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Formulaire dynamique selon l'acte
              _construireFormulaireSpecifique(),

              const SizedBox(height: 24),

              // Check-list des pièces à fournir
              const Text(
                'Vérification des pièces à fournir',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Veuillez confirmer que vous disposez des pièces ci-dessous :',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const Divider(),
              const SizedBox(height: 8),

              ...widget.document.piecesAFournir.map((piece) {
                final estFourni = _fichiersPieces[piece] != null;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: estFourni ? Colors.green.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: estFourni ? Colors.green.shade400 : Colors.grey.shade300,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      estFourni ? Icons.check_circle : Icons.upload_file,
                      color: estFourni ? Colors.green.shade700 : Colors.grey.shade600,
                    ),
                    title: Text(piece, style: const TextStyle(fontSize: 14)),
                    subtitle: Text(
                      estFourni ? 'Fichier joint' : 'Pièce requise *',
                      style: TextStyle(fontSize: 11, color: estFourni ? Colors.green.shade700 : Colors.red),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          tooltip: 'Prendre une photo',
                          onPressed: () => _prendrePhoto(piece),
                        ),
                        IconButton(
                          icon: const Icon(Icons.photo_library),
                          tooltip: 'Choisir depuis la galerie',
                          onPressed: () => _choisirGalerie(piece),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 32),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      child: const Text('Annuler', style: TextStyle(fontSize: 16, color: Colors.black54)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _soumettreDemande,
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text('Envoyer la demande', style: TextStyle(fontSize: 16, color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade900,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit le formulaire approprié au type de document d'état civil
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

  // --- 1. Formulaire Acte de Naissance ---
  Widget _formulaireActeNaissance() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Informations sur le Nouveau-né / Titulaire'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_enfant'],
                decoration: const InputDecoration(labelText: 'Prénom(s) de l\'enfant *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_enfant'],
                decoration: const InputDecoration(labelText: 'Nom de famille *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
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
                decoration: const InputDecoration(labelText: 'Date de Naissance *', hintText: 'JJ/MM/AAAA', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
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
                decoration: const InputDecoration(labelText: 'Heure de Naissance', hintText: 'Ex: 14h30', border: OutlineInputBorder()),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['lieu_naissance'],
                decoration: const InputDecoration(labelText: 'Lieu / Hopital de naissance *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _sectionTitre('Filiation (Parents)'),
        TextFormField(
          controller: _controllers['prenom_nom_pere'],
          decoration: const InputDecoration(labelText: 'Prénom et Nom du Père *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['profession_pere'],
          decoration: const InputDecoration(labelText: 'Profession du Père', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['prenom_nom_mere'],
          decoration: const InputDecoration(labelText: 'Prénom et Nom de la Mère *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['profession_mere'],
          decoration: const InputDecoration(labelText: 'Profession de la Mère', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['domicile_parents'],
          decoration: const InputDecoration(labelText: 'Domicile des parents *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
      ],
    );
  }

  // --- 2. Formulaire Extrait de Naissance ---
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
                decoration: const InputDecoration(labelText: 'Prénom(s) *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_titulaire'],
                decoration: const InputDecoration(labelText: 'Nom *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
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
                decoration: const InputDecoration(labelText: 'Date de Naissance *', hintText: 'JJ/MM/AAAA', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['lieu_naissance'],
          decoration: const InputDecoration(labelText: 'Lieu de Naissance *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations du Registre / Acte d\'État Civil'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['num_registre'],
                decoration: const InputDecoration(labelText: 'N° d\'Acte / Registre *', hintText: 'Ex: 1234', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['annee_registre'],
                decoration: const InputDecoration(labelText: 'Année du Registre *', hintText: 'Ex: 2002', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['centre_etat_civil'],
          decoration: const InputDecoration(labelText: 'Centre d\'État Civil *', hintText: 'Ex: Mairie de Dakar-Plateau', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Filiation'),
        TextFormField(
          controller: _controllers['prenom_nom_pere'],
          decoration: const InputDecoration(labelText: 'Prénom et Nom du Père *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['prenom_nom_mere'],
          decoration: const InputDecoration(labelText: 'Prénom et Nom de la Mère *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
      ],
    );
  }

  // --- 3. Formulaire Certificat de Mariage ---
  Widget _formulaireCertificatMariage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitre('Informations de l\'Époux (Mari)'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_epoux'],
                decoration: const InputDecoration(labelText: 'Prénom(s) de l\'Époux *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_epoux'],
                decoration: const InputDecoration(labelText: 'Nom de l\'Époux *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['date_naissance_epoux'],
          decoration: const InputDecoration(labelText: 'Date de Naissance de l\'Époux *', hintText: 'JJ/MM/AAAA', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations de l\'Épouse (Femme)'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['prenom_epouse'],
                decoration: const InputDecoration(labelText: 'Prénom(s) de l\'Épouse *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_epouse'],
                decoration: const InputDecoration(labelText: 'Nom de l\'Épouse *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['date_naissance_epouse'],
          decoration: const InputDecoration(labelText: 'Date de Naissance de l\'Épouse *', hintText: 'JJ/MM/AAAA', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations de l\'Union (Mariage)'),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['date_mariage'],
                decoration: const InputDecoration(labelText: 'Date du Mariage *', hintText: 'JJ/MM/AAAA', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['lieu_mariage'],
                decoration: const InputDecoration(labelText: 'Lieu de Célébration *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _regimeMatrimonial,
          decoration: const InputDecoration(labelText: 'Régime Matrimonial *', border: OutlineInputBorder()),
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
          decoration: const InputDecoration(labelText: 'N° Acte de Mariage / Registre (si connu)', border: OutlineInputBorder()),
        ),
      ],
    );
  }

  // --- 4. Formulaire Certificat de Décès ---
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
                decoration: const InputDecoration(labelText: 'Prénom(s) du Défunt *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['nom_defunt'],
                decoration: const InputDecoration(labelText: 'Nom du Défunt *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['date_naissance_defunt'],
          decoration: const InputDecoration(labelText: 'Date de Naissance du Défunt', hintText: 'JJ/MM/AAAA', border: OutlineInputBorder()),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controllers['date_deces'],
                decoration: const InputDecoration(labelText: 'Date du Décès *', hintText: 'JJ/MM/AAAA', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _controllers['heure_deces'],
                decoration: const InputDecoration(labelText: 'Heure du Décès', hintText: 'Ex: 08h15', border: OutlineInputBorder()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controllers['lieu_deces'],
          decoration: const InputDecoration(labelText: 'Lieu du Décès (Hôpital / Commune) *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 20),
        _sectionTitre('Informations du Déclarant'),
        TextFormField(
          controller: _controllers['prenom_nom_declarant'],
          decoration: const InputDecoration(labelText: 'Prénom et Nom du Déclarant *', border: OutlineInputBorder()),
          validator: (v) => v!.isEmpty ? 'Requis' : null,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _lienParenteDeclarant,
                decoration: const InputDecoration(labelText: 'Lien de Parenté *', border: OutlineInputBorder()),
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
                decoration: const InputDecoration(labelText: 'N° CNI du Déclarant *', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requis' : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Helper pour les titres de section
  Widget _sectionTitre(String titre) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titre,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900),
          ),
          const Divider(),
        ],
      ),
    );
  }
}

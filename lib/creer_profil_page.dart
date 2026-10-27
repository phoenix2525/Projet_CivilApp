import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'tableau_de_bord_citoyen_page.dart';
import 'models/citoyen.dart';
import 'models/demande.dart';

/// Page d'inscription et de connexion du citoyen.
/// Enregistrement dans la base simulée avec mode démo rapide.
class CreerProfilPage extends StatefulWidget {
  const CreerProfilPage({super.key});

  @override
  State<CreerProfilPage> createState() => _CreerProfilPageState();
}

class _CreerProfilPageState extends State<CreerProfilPage> {
  final _formKey = GlobalKey<FormState>();
  bool _estModeConnexion = false; // false = Inscription, true = Connexion
  bool _acceptConditions = false;

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  void _soumettre() {
    if (!_formKey.currentState!.validate()) return;

    if (!_estModeConnexion && !_acceptConditions) {
      _afficherMessage('Veuillez accepter les conditions d\'utilisation.', estErreur: true);
      return;
    }

    final emailSaisi = _emailController.text.trim();

    if (_estModeConnexion) {
      Citoyen? profilTrouve;
      for (final profil in DatabaseSimulee.citoyensInscrits) {
        if (profil.email == emailSaisi) {
          profilTrouve = profil;
          break;
        }
      }

      if (profilTrouve == null) {
        _afficherMessage('Aucun compte trouvé avec cet email. Veuillez vous inscrire.', estErreur: true);
        return;
      }

      DatabaseSimulee.citoyenConnecte = profilTrouve;
      _afficherMessage('Connexion réussie.');
    } else {
      final emailDejaUtilise = DatabaseSimulee.citoyensInscrits.any((profil) => profil.email == emailSaisi);
      if (emailDejaUtilise) {
        _afficherMessage('Cette adresse email est déjà associée à un compte.', estErreur: true);
        return;
      }

      final nouveauCitoyen = Citoyen(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: emailSaisi,
        adresse: _adresseController.text.trim(),
      );
      DatabaseSimulee.citoyensInscrits.add(nouveauCitoyen);
      DatabaseSimulee.citoyenConnecte = nouveauCitoyen;
      _afficherMessage('Compte citoyen créé avec succès.');
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
    );
  }

  void _connexionRapideDemo() {
    DatabaseSimulee.citoyenConnecte = Citoyen(
      prenom: _prenomController.text.trim().isNotEmpty ? _prenomController.text.trim() : 'Moussa',
      nom: _nomController.text.trim().isNotEmpty ? _nomController.text.trim() : 'Fall',
      telephone: _telephoneController.text.trim().isNotEmpty ? _telephoneController.text.trim() : '771234567',
      email: _emailController.text.trim().isNotEmpty ? _emailController.text.trim() : 'citoyen.demo@etatcivil.sn',
      adresse: _adresseController.text.trim().isNotEmpty ? _adresseController.text.trim() : 'Dakar, Sénégal',
    );

    _afficherMessage('Connecté en mode Démo rapide.');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
    );
  }

  void _afficherMessage(String texte, {bool estErreur = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(estErreur ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(texte)),
          ],
        ),
        backgroundColor: estErreur ? Palette.statutRejetee : Palette.primaire,
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
      body: SafeArea(
        child: Column(
          children: [
            // Bandeau bleu nuit sobre
            Container(
              color: Palette.primaire,
              padding: const EdgeInsets.fromLTRB(12, 12, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: Icon(
                            _estModeConnexion ? Icons.login_rounded : Icons.person_add_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _estModeConnexion ? 'Connexion Citoyen' : 'Créer mon compte',
                                style: GoogleFonts.publicSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Identifiant numérique d\'état civil',
                                style: GoogleFonts.publicSans(
                                  color: Palette.texteSurSombreMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Formulaire dans une carte avec bordure fine
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Palette.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Palette.bordure, width: 1),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _construireOnglets(),
                        const SizedBox(height: 20),

                        if (!_estModeConnexion) ...[
                          Row(
                            children: [
                              Expanded(child: _champTexte(_prenomController, 'Prénom', Icons.person_outline)),
                              const SizedBox(width: 12),
                              Expanded(child: _champTexte(_nomController, 'Nom', Icons.badge_outlined)),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _champTexte(
                            _telephoneController,
                            'Numéro de téléphone',
                            Icons.phone_outlined,
                            clavier: TextInputType.phone,
                          ),
                          const SizedBox(height: 14),
                        ],

                        _champTexte(
                          _emailController,
                          'Adresse email',
                          Icons.mail_outline_rounded,
                          clavier: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        if (!_estModeConnexion) ...[
                          _champTexte(
                            _adresseController,
                            'Adresse de résidence',
                            Icons.location_on_outlined,
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Checkbox(
                                  value: _acceptConditions,
                                  onChanged: (val) => setState(() => _acceptConditions = val ?? false),
                                  activeColor: Palette.validation,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'J\'accepte les conditions officielles du service d\'état civil communal.',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 11,
                                    color: Palette.texteSecondaire,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _soumettre,
                            child: Text(
                              _estModeConnexion ? 'Se connecter' : 'Créer mon compte officiel',
                              style: GoogleFonts.publicSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: TextButton.icon(
                            onPressed: _connexionRapideDemo,
                            icon: const Icon(Icons.bolt_outlined, size: 16),
                            label: Text(
                              'Accès démo rapide (sans mot de passe)',
                              style: GoogleFonts.publicSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construireOnglets() {
    return Container(
      decoration: BoxDecoration(
        color: Palette.surfaceSecondaire,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Palette.bordure, width: 1),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _estModeConnexion = false),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !_estModeConnexion ? Palette.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: !_estModeConnexion ? Border.all(color: Palette.bordure, width: 1) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Inscription',
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: !_estModeConnexion ? FontWeight.w700 : FontWeight.w500,
                    color: !_estModeConnexion ? Palette.primaire : Palette.texteSecondaire,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _estModeConnexion = true),
              borderRadius: BorderRadius.circular(4),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _estModeConnexion ? Palette.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                  border: _estModeConnexion ? Border.all(color: Palette.bordure, width: 1) : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Connexion',
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    fontWeight: _estModeConnexion ? FontWeight.w700 : FontWeight.w500,
                    color: _estModeConnexion ? Palette.primaire : Palette.texteSecondaire,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _champTexte(
    TextEditingController ctrl,
    String label,
    IconData icone, {
    TextInputType clavier = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: clavier,
      style: GoogleFonts.publicSans(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone, size: 20),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return '$label requis';
        if (clavier == TextInputType.emailAddress && (!val.contains('@') || !val.contains('.'))) {
          return 'Email invalide';
        }
        return null;
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tableau_de_bord_citoyen_page.dart';
import 'models/citoyen.dart';
import 'models/demande.dart';
import 'services/firebase_service.dart';

/// Page d'authentification et de profil citoyen.
/// Supporte l'inscription et la connexion réelles avec Firebase Auth & Firestore,
/// tout en intégrant un mode démo pour les évaluations rapides.
class CreerProfilPage extends StatefulWidget {
  const CreerProfilPage({super.key});

  @override
  State<CreerProfilPage> createState() => _CreerProfilPageState();
}

class _CreerProfilPageState extends State<CreerProfilPage> {
  final _formKey = GlobalKey<FormState>();
  bool _estModeConnexion = false; // false = Inscription, true = Connexion
  bool _chargement = false;
  bool _motDePasseVisible = false;
  bool _acceptConditions = false;

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _motDePasseController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  /// Traite la soumission selon le mode (Connexion ou Inscription)
  Future<void> _soumettre() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_estModeConnexion && !_acceptConditions) {
      _afficherMessage('Veuillez accepter les conditions d\'utilisation.', estErreur: true);
      return;
    }

    setState(() => _chargement = true);

    try {
      if (_estModeConnexion) {
        // --- Connexion Firebase Auth ---
        await FirebaseService.connecterCitoyen(
          email: _emailController.text.trim(),
          password: _motDePasseController.text,
        );
        _afficherMessage('Connexion réussie ! Heureux de vous revoir.');
      } else {
        // --- Inscription Firebase Auth & Firestore ---
        await FirebaseService.inscrireCitoyen(
          email: _emailController.text.trim(),
          password: _motDePasseController.text,
          prenom: _prenomController.text.trim(),
          nom: _nomController.text.trim(),
          telephone: _telephoneController.text.trim(),
          adresse: _adresseController.text.trim(),
        );
        _afficherMessage('Compte citoyen créé avec succès sur Firebase !');
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
        );
      }
    } catch (e) {
      String message = 'Une erreur est survenue lors de l\'authentification.';
      final erreurTexte = e.toString().toLowerCase();

      if (erreurTexte.contains('email-already-in-use')) {
        message = 'Cette adresse e-mail possède déjà un compte. Veuillez vous connecter.';
      } else if (erreurTexte.contains('user-not-found') || erreurTexte.contains('wrong-password') || erreurTexte.contains('invalid-credential')) {
        message = 'Identifiants incorrects. Vérifiez l\'email et le mot de passe.';
      } else if (erreurTexte.contains('weak-password')) {
        message = 'Le mot de passe doit comporter au moins 6 caractères.';
      } else if (erreurTexte.contains('invalid-email')) {
        message = 'Format d\'adresse email invalide.';
      } else if (erreurTexte.contains('network-request-failed')) {
        message = 'Connexion réseau impossible. Vérifiez votre accès Internet.';
      }

      _afficherMessage(message, estErreur: true);
    } finally {
      if (mounted) {
        setState(() => _chargement = false);
      }
    }
  }

  /// Démo rapide sans mot de passe pour présentation en classe
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
            Icon(estErreur ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(texte)),
          ],
        ),
        backgroundColor: estErreur ? Colors.red.shade700 : const Color(0xFF0A6640),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: Stack(
        children: [
          // En-tête bicolore dégradé vert
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF062917), Color(0xFF0A6640)],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Barre haute avec retour
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Titre et icône
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _estModeConnexion ? Icons.login_rounded : Icons.person_add_rounded,
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
                              style: GoogleFonts.hankenGrotesk(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  FirebaseService.estDisponible ? Icons.cloud_done : Icons.cloud_off,
                                  size: 13,
                                  color: FirebaseService.estDisponible ? Colors.greenAccent : Colors.orangeAccent,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  FirebaseService.estDisponible ? 'Connecté à Firebase Cloud' : 'Mode Local / Démo',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Carte formulaire blanche
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Sélecteur d'onglet Inscription / Connexion
                            _construireOnglets(),
                            const SizedBox(height: 20),

                            if (!_estModeConnexion) ...[
                              // Prénom et Nom
                              Row(
                                children: [
                                  Expanded(child: _champTexte(_prenomController, 'Prénom', Icons.badge_outlined)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _champTexte(_nomController, 'Nom', Icons.badge_outlined)),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Téléphone
                              _champTexte(
                                _telephoneController,
                                'Téléphone',
                                Icons.phone_rounded,
                                clavier: TextInputType.phone,
                              ),
                              const SizedBox(height: 14),
                            ],

                            // Email
                            _champTexte(
                              _emailController,
                              'Adresse email',
                              Icons.mail_outline_rounded,
                              clavier: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),

                            // Mot de passe
                            _champMotDePasse(),
                            const SizedBox(height: 14),

                            if (!_estModeConnexion) ...[
                              // Adresse
                              _champTexte(
                                _adresseController,
                                'Adresse de résidence',
                                Icons.location_on_outlined,
                              ),
                              const SizedBox(height: 16),

                              // Conditions d'utilisation
                              Row(
                                children: [
                                  Checkbox(
                                    value: _acceptConditions,
                                    onChanged: (val) => setState(() => _acceptConditions = val ?? false),
                                    activeColor: const Color(0xFF0A6640),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                  ),
                                  Expanded(
                                    child: Text(
                                      'J\'accepte les conditions d\'utilisation de la plateforme d\'état civil.',
                                      style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const SizedBox(height: 20),

                            // Bouton Principal
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _chargement ? null : _soumettre,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0A6640),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _chargement
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                      )
                                    : Text(
                                        _estModeConnexion ? 'Se connecter' : 'Créer mon compte officiel',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Option Démo rapide pour l'évaluation
                            Center(
                              child: TextButton.icon(
                                onPressed: _connexionRapideDemo,
                                icon: const Icon(Icons.flash_on, size: 16, color: Color(0xFF0A6640)),
                                label: Text(
                                  'Accès démo rapide (sans mot de passe)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 13,
                                    color: const Color(0xFF0A6640),
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
        ],
      ),
    );
  }

  /// Onglets modernes de bascule Inscription / Connexion
  Widget _construireOnglets() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F6F4),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _estModeConnexion = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_estModeConnexion ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: !_estModeConnexion
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Inscription',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: !_estModeConnexion ? FontWeight.bold : FontWeight.w500,
                    color: !_estModeConnexion ? const Color(0xFF0A6640) : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _estModeConnexion = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _estModeConnexion ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: _estModeConnexion
                      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Connexion',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: _estModeConnexion ? FontWeight.bold : FontWeight.w500,
                    color: _estModeConnexion ? const Color(0xFF0A6640) : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Champ mot de passe avec affichage/masquage
  Widget _champMotDePasse() {
    return TextFormField(
      controller: _motDePasseController,
      obscureText: !_motDePasseVisible,
      decoration: InputDecoration(
        labelText: 'Mot de passe',
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20, color: Color(0xFF0A6640)),
        suffixIcon: IconButton(
          icon: Icon(
            _motDePasseVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            size: 20,
            color: Colors.grey.shade600,
          ),
          onPressed: () => setState(() => _motDePasseVisible = !_motDePasseVisible),
        ),
        filled: true,
        fillColor: const Color(0xFFF7FAF8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A6640), width: 1.5),
        ),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Le mot de passe est obligatoire.';
        if (val.trim().length < 6) return 'Minimum 6 caractères.';
        return null;
      },
    );
  }

  /// Générateur standardisé de champs de texte
  Widget _champTexte(
    TextEditingController ctrl,
    String label,
    IconData icone, {
    TextInputType clavier = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: clavier,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone, size: 20, color: const Color(0xFF0A6640)),
        filled: true,
        fillColor: const Color(0xFFF7FAF8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0A6640), width: 1.5),
        ),
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

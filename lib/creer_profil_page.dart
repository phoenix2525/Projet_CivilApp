import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tableau_de_bord_citoyen_page.dart';
import 'models/citoyen.dart';
import 'models/demande.dart';

/// Page de création du profil citoyen.
/// Design moderne avec fond bicolore et champs de saisie flottants.
class CreerProfilPage extends StatefulWidget {
  const CreerProfilPage({super.key});

  @override
  State<CreerProfilPage> createState() => _CreerProfilPageState();
}

class _CreerProfilPageState extends State<CreerProfilPage> {
  final _formKey = GlobalKey<FormState>();
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

  /// Valide et enregistre le profil citoyen en mémoire
  void _creerProfil() {
    if (_formKey.currentState!.validate() && _acceptConditions) {
      DatabaseSimulee.citoyenConnecte = Citoyen(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        email: _emailController.text.trim(),
        adresse: _adresseController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
      );
    } else if (!_acceptConditions) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez accepter les conditions d\'utilisation.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  /// Simule une connexion sociale rapide (Google ou Apple)
  void _simulerConnexionSociale(String provider) {
    DatabaseSimulee.citoyenConnecte = Citoyen(
      prenom: 'Citoyen',
      nom: provider,
      telephone: '000000000',
      email: 'citoyen@${provider.toLowerCase()}.com',
      adresse: 'Dakar, Sénégal',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connexion via $provider réussie.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TableauDeBordCitoyenPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: Stack(
        children: [
          // Bande verte en haut de page
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 200,
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
                // Bouton retour
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                // Titre dans la zone verte
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Créer mon profil',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            'Accédez à vos services d\'état civil',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

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
                            // Connexions sociales
                            _construireBoutonSocial(
                              label: 'Continuer avec Google',
                              icone: const Icon(Icons.g_mobiledata, size: 26, color: Color(0xFFEA4335)),
                              onTap: () => _simulerConnexionSociale('Google'),
                            ),
                            const SizedBox(height: 10),
                            _construireBoutonSocial(
                              label: 'Continuer avec Apple',
                              icone: const Icon(Icons.apple, size: 24, color: Colors.black87),
                              onTap: () => _simulerConnexionSociale('Apple'),
                            ),

                            // Séparateur OU
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Row(
                                children: [
                                  Expanded(child: Divider(color: Colors.grey.shade200)),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Text(
                                      'ou remplissez le formulaire',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  Expanded(child: Divider(color: Colors.grey.shade200)),
                                ],
                              ),
                            ),

                            // Prénom et Nom côte à côte
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

                            // Email
                            _champTexte(
                              _emailController,
                              'Adresse email',
                              Icons.mail_outline_rounded,
                              clavier: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),

                            // Adresse
                            TextFormField(
                              controller: _adresseController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                labelText: 'Adresse complète',
                                prefixIcon: const Padding(
                                  padding: EdgeInsets.only(bottom: 24),
                                  child: Icon(Icons.location_on_outlined),
                                ),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                            ),
                            const SizedBox(height: 20),

                            // Checkbox conditions
                            GestureDetector(
                              onTap: () => setState(() => _acceptConditions = !_acceptConditions),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _acceptConditions ? colorScheme.primary : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _acceptConditions ? colorScheme.primary : Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _acceptConditions
                                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Je confirme l\'exactitude de ces informations et accepte les conditions d\'utilisation.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Bouton principal
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _creerProfil,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Créer mon compte',
                                      style: GoogleFonts.hankenGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Mention sécurité
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.verified_user_outlined, size: 14, color: Colors.grey.shade400),
                                const SizedBox(width: 6),
                                Text(
                                  'Données traitées selon les normes de l\'État sénégalais',
                                  style: GoogleFonts.plusJakartaSans(fontSize: 11, color: Colors.grey.shade500),
                                ),
                              ],
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

  /// Champ de texte standard du formulaire
  Widget _champTexte(TextEditingController ctrl, String label, IconData icone, {TextInputType? clavier}) {
    return TextFormField(
      controller: ctrl,
      keyboardType: clavier,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? 'Champ requis' : null,
    );
  }

  /// Bouton de connexion sociale (Google / Apple)
  Widget _construireBoutonSocial({required String label, required Widget icone, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icone,
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

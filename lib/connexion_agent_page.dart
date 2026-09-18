import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'gestion_demandes_page.dart';
import 'services/firebase_service.dart';

/// Page de connexion réservée aux agents de la mairie.
/// Design sombre sur fond vert profond, formulaire sur carte blanche.
class ConnexionAgentPage extends StatefulWidget {
  const ConnexionAgentPage({super.key});

  @override
  State<ConnexionAgentPage> createState() => _ConnexionAgentPageState();
}

class _ConnexionAgentPageState extends State<ConnexionAgentPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();
  String? _roleSelectionne;

  // Rôles disponibles au sein de la mairie
  final List<String> _roles = [
    'Officier d\'État Civil',
    'Agent d\'Accueil',
    'Archiviste',
    'Superviseur',
  ];

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _matriculeController.dispose();
    super.dispose();
  }

  /// Valide le formulaire et connecte l'agent
  void _connecter() {
    if (_formKey.currentState!.validate() && _roleSelectionne != null) {
      FirebaseService.connecterAgent(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        matricule: _matriculeController.text.trim(),
        role: _roleSelectionne!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bienvenue ${_prenomController.text}, connexion réussie.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GestionDemandesPage()),
      );
    } else if (_roleSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Veuillez sélectionner votre rôle.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F4),
      body: Stack(
        children: [
          // Fond dégradé sombre en haut
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 240,
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
                // Bouton retour et en-tête
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // Icône et titre sur fond sombre
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                        ),
                        child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Espace Agent',
                            style: GoogleFonts.hankenGrotesk(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Accès réservé au personnel municipal',
                            style: GoogleFonts.plusJakartaSans(color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Carte formulaire
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(28),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Identification',
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1A2E26),
                              ),
                            ),
                            Text(
                              'Veuillez renseigner vos informations professionnelles.',
                              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: Colors.grey.shade500),
                            ),
                            const SizedBox(height: 24),

                            // Prénom et Nom côte à côte
                            Row(
                              children: [
                                Expanded(child: _champTexte(_prenomController, 'Prénom', Icons.person_outline_rounded)),
                                const SizedBox(width: 12),
                                Expanded(child: _champTexte(_nomController, 'Nom', Icons.badge_outlined)),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Matricule
                            _champTexte(_matriculeController, 'Matricule Agent', Icons.pin_outlined),
                            const SizedBox(height: 14),

                            // Sélection du rôle
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                labelText: 'Rôle dans la mairie',
                                prefixIcon: const Icon(Icons.assignment_ind_outlined),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              initialValue: _roleSelectionne,
                              items: _roles.map((role) {
                                return DropdownMenuItem(value: role, child: Text(role));
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _roleSelectionne = val;
                                });
                              },
                            ),
                            const SizedBox(height: 24),

                            // Encart de sécurité discret
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF062917).withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0A6640).withValues(alpha: 0.18)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.security_rounded, color: colorScheme.primary, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Connexion sécurisée. Accès réservé au personnel municipal autorisé.',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF1A3A2A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Bouton de connexion
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _connecter,
                                icon: const Icon(Icons.login_rounded),
                                label: Text(
                                  'Accéder à l\'espace agent',
                                  style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

  /// Champ de texte standard avec style moderne
  Widget _champTexte(TextEditingController ctrl, String label, IconData icone) {
    return TextFormField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? 'Requis' : null,
    );
  }
}

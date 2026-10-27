import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';
import 'gestion_demandes_page.dart';
import 'models/agent.dart';
import 'models/demande.dart';

/// Page de connexion réservée aux agents de la mairie.
/// Design sobre et protocolaire.
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

  void _connecter() {
    if (_formKey.currentState!.validate() && _roleSelectionne != null) {
      DatabaseSimulee.agentConnecte = Agent(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        matricule: _matriculeController.text.trim(),
        role: _roleSelectionne!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Session ouverte pour ${_prenomController.text.trim()}.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
          content: const Text('Veuillez sélectionner votre fonction administrative.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _connexionRapideDemoAgent() {
    DatabaseSimulee.agentConnecte = Agent(
      prenom: _prenomController.text.trim().isNotEmpty
          ? _prenomController.text.trim()
          : 'Aminata',
      nom: _nomController.text.trim().isNotEmpty
          ? _nomController.text.trim()
          : 'Fall',
      matricule: _matriculeController.text.trim().isNotEmpty
          ? _matriculeController.text.trim()
          : 'AGT-2024-001',
      role: _roleSelectionne ?? "Officier d'État Civil",
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Expanded(child: Text('Connecté en mode Démo rapide (Agent).')),
          ],
        ),
        backgroundColor: Palette.primaire,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const GestionDemandesPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.fond,
      body: SafeArea(
        child: Column(
          children: [
            // En-tête bleu nuit sobre
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
                          child: const Icon(
                            Icons.admin_panel_settings_outlined,
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
                                'Espace Agent',
                                style: GoogleFonts.publicSans(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 20,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Guichet numérique du personnel municipal',
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

            // Formulaire dans une carte surélevée avec bordure sobre
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
                        Text(
                          'Authentification professionnelle',
                          style: GoogleFonts.publicSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Palette.textePrimaire,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Saisissez votre matricule et rôle pour accéder aux dossiers.',
                          style: GoogleFonts.publicSans(
                            fontSize: 12,
                            color: Palette.texteSecondaire,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: _champTexte(
                                _prenomController,
                                'Prénom',
                                Icons.person_outline,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _champTexte(
                                _nomController,
                                'Nom',
                                Icons.badge_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _champTexte(
                          _matriculeController,
                          'Matricule Agent (ex. AGT-2024-001)',
                          Icons.pin_outlined,
                        ),
                        const SizedBox(height: 14),

                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'Rôle d\'affectation',
                            prefixIcon: Icon(Icons.assignment_ind_outlined),
                          ),
                          value: _roleSelectionne,
                          items: _roles.map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role,
                                style: GoogleFonts.publicSans(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            setState(() {
                              _roleSelectionne = val;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Palette.surfaceSecondaire,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Palette.bordure, width: 1),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                color: Palette.primaire,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Accès tracé et sécurisé conformément aux règles d\'archivage communal.',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 11,
                                    color: Palette.texteSecondaire,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _connecter,
                            icon: const Icon(Icons.login_rounded, size: 18),
                            label: Text(
                              'Accéder aux dossiers',
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
                            onPressed: _connexionRapideDemoAgent,
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

  Widget _champTexte(TextEditingController ctrl, String label, IconData icone) {
    return TextFormField(
      controller: ctrl,
      style: GoogleFonts.publicSans(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icone, size: 20),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return 'Champ obligatoire';
        }
        return null;
      },
    );
  }
}

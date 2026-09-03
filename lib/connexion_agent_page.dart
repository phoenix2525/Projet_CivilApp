import 'package:flutter/material.dart';
import 'models/agent.dart';
import 'models/demande.dart';
import 'gestion_demandes_page.dart';

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

  void _connexion() {
    if (_formKey.currentState!.validate() && _roleSelectionne != null) {
      // Sauvegarde de l'agent en mémoire
      DatabaseSimulee.agentConnecte = Agent(
        prenom: _prenomController.text,
        nom: _nomController.text,
        matricule: _matriculeController.text,
        role: _roleSelectionne!,
      );

      // Rediriger vers l'interface de gestion
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GestionDemandesPage()),
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bienvenue ${_prenomController.text}, connexion réussie.')),
      );
    } else if (_roleSelectionne == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner un rôle.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Connexion Agent', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green.shade900,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.badge, size: 64, color: Colors.green.shade900),
                const SizedBox(height: 16),
                Text(
                  'Espace Agent Mairie',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade900),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veuillez vous identifier pour accéder à votre espace de travail sécurisé.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 32),
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Icons.badge_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _matriculeController,
                  decoration: const InputDecoration(
                    labelText: 'Matricule Agent',
                    prefixIcon: Icon(Icons.pin),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Rôle',
                    prefixIcon: Icon(Icons.assignment_ind),
                    border: OutlineInputBorder(),
                  ),
                  initialValue: _roleSelectionne,
                  items: _roles.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _roleSelectionne = val;
                    });
                  },
                ),
                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.security, color: Colors.green.shade700),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Connexion sécurisée. Accès réservé au personnel municipal autorisé.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _connexion,
                    icon: const Icon(Icons.login, color: Colors.white),
                    label: const Text('Se connecter à l\'espace agent', style: TextStyle(color: Colors.white, fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

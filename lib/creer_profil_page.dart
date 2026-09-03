import 'package:flutter/material.dart';
import 'catalogue_page.dart';
import 'models/citoyen.dart';
import 'models/demande.dart';

class CreerProfilPage extends StatefulWidget {
  const CreerProfilPage({super.key});

  @override
  State<CreerProfilPage> createState() => _CreerProfilPageState();
}

class _CreerProfilPageState extends State<CreerProfilPage> {
  final _formKey = GlobalKey<FormState>();
  bool _acceptTerms = false;

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

  void _submitForm() {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      // Recherche: Persistance en mémoire via notre classe utilitaire
      DatabaseSimulee.citoyenConnecte = Citoyen(
        prenom: _prenomController.text,
        nom: _nomController.text,
        telephone: _telephoneController.text,
        email: _emailController.text,
        adresse: _adresseController.text,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CataloguePage()),
      );
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez accepter les conditions d\'utilisation.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.green.shade900),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // En-tête
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_add, size: 32, color: Colors.green.shade900),
                ),
                const SizedBox(height: 16),
                Text(
                  'Création de profil',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Rejoignez CivilApp pour accéder à l\'ensemble de vos services d\'état civil de manière sécurisée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(height: 32),

                // Formulaire
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _telephoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Numéro de téléphone',
                    prefixIcon: Icon(Icons.call),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Adresse Email',
                    prefixIcon: Icon(Icons.mail),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _adresseController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Adresse complète',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 40.0), // Alignement de l'icône en haut
                      child: Icon(Icons.location_on),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),

                // Conditions
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 24,
                      width: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        activeColor: Colors.green.shade900,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Je confirme l\'exactitude de ces informations et accepte les conditions d\'utilisation.',
                        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Boutons
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Créer mon compte', style: TextStyle(fontSize: 16, color: Colors.white)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text('Annuler', style: TextStyle(fontSize: 16, color: Colors.black54)),
                  ),
                ),
                const SizedBox(height: 32),

                // Footer de confiance
                Column(
                  children: [
                    Icon(Icons.verified_user, color: Colors.grey.shade400, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      'Données sécurisées et traitées selon les normes de l\'administration publique sénégalaise.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

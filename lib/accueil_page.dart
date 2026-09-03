import 'package:flutter/material.dart';
import 'creer_profil_page.dart';
import 'connexion_agent_page.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo or Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.gavel,
                    size: 50,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'CivilApp',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtitle
                Text(
                  'L\'État Civil Sénégalais,\nà portée de main.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  'Simplifiez vos démarches administratives. Accédez à vos documents officiels de manière sécurisée et rapide, où que vous soyez.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 48),
                
                // Primary Action Button (Créer mon profil)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CreerProfilPage()),
                      );
                    },
                    icon: const Icon(Icons.person_add, color: Colors.white),
                    label: const Text(
                      'Créer mon profil',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade900,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Secondary Action Button (Se connecter)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ConnexionAgentPage()),
                      );
                    },
                    icon: Icon(Icons.login, color: Colors.green.shade900),
                    label: Text(
                      'Se connecter',
                      style: TextStyle(fontSize: 16, color: Colors.green.shade900),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.green.shade900),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Trust indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified_user, size: 16, color: Colors.grey.shade500),
                    const SizedBox(width: 8),
                    Text(
                      'Plateforme officielle sécurisée',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

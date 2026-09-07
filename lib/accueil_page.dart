import 'dart:ui';
import 'package:flutter/material.dart';
import 'creer_profil_page.dart';
import 'connexion_agent_page.dart';

class AccueilPage extends StatelessWidget {
  const AccueilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/bg_accueil.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: colorScheme.surface),
            ),
          ),
          // Light Overlay for readability
          Positioned.fill(
            child: Container(
              color: colorScheme.surface.withValues(alpha: 0.90),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo or Icon
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance,
                              size: 50,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Title
                          Text(
                            'CivilApp',
                            style: textTheme.displayLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 8),
                          
                          // Subtitle
                          Text(
                            'L\'État Civil Sénégalais,\nà portée de main.',
                            textAlign: TextAlign.center,
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Description
                          Text(
                            'Vos documents officiels de manière sécurisée et rapide.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 40),
                          
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
                              icon: const Icon(Icons.person_add),
                              label: const Text('Citoyen : Connexion'),
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
                              icon: const Icon(Icons.shield),
                              label: const Text('Mairie : Accès Agent'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

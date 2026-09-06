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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Logo or Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance,
                        size: 60,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Title
                    Text(
                      'CivilApp',
                      style: textTheme.displayLarge?.copyWith(
                        color: colorScheme.primary,
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
                      'Simplifiez vos démarches administratives. Accédez à vos documents officiels de manière sécurisée et rapide, où que vous soyez.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
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
                        icon: const Icon(Icons.person_add),
                        label: const Text('Créer mon profil / Connexion'),
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
                        label: const Text('Accès Agent Mairie'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Trust indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.verified_user, size: 16, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Plateforme officielle sécurisée',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

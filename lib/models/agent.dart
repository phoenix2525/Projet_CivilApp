/// Modèle représentant un agent de la mairie.
class Agent {
  final String prenom;
  final String nom;
  final String matricule;
  final String role;
  final String? email;

  Agent({
    required this.prenom,
    required this.nom,
    required this.matricule,
    required this.role,
    this.email,
  });
}

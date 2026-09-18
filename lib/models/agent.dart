class Agent {
  final String? id;
  final String prenom;
  final String nom;
  final String matricule;
  final String role;
  final String? email;

  Agent({
    this.id,
    required this.prenom,
    required this.nom,
    required this.matricule,
    required this.role,
    this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'prenom': prenom,
      'nom': nom,
      'matricule': matricule,
      'role': role,
      'typeUtilisateur': 'agent',
      if (email != null) 'email': email,
    };
  }

  factory Agent.fromMap(Map<String, dynamic> map, {String? id}) {
    return Agent(
      id: id,
      prenom: map['prenom'] ?? '',
      nom: map['nom'] ?? '',
      matricule: map['matricule'] ?? '',
      role: map['role'] ?? 'Agent d\'Accueil',
      email: map['email'],
    );
  }
}

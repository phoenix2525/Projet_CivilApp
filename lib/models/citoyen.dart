class Citoyen {
  final String? id;
  final String prenom;
  final String nom;
  final String telephone;
  final String email;
  final String adresse;

  Citoyen({
    this.id,
    required this.prenom,
    required this.nom,
    required this.telephone,
    required this.email,
    required this.adresse,
  });

  Map<String, dynamic> toMap() {
    return {
      'prenom': prenom,
      'nom': nom,
      'telephone': telephone,
      'email': email,
      'adresse': adresse,
      'role': 'citoyen',
    };
  }

  factory Citoyen.fromMap(Map<String, dynamic> map, {String? id}) {
    return Citoyen(
      id: id,
      prenom: map['prenom'] ?? '',
      nom: map['nom'] ?? '',
      telephone: map['telephone'] ?? '',
      email: map['email'] ?? '',
      adresse: map['adresse'] ?? '',
    );
  }
}

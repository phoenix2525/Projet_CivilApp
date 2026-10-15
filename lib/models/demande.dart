import 'citoyen.dart';
import 'document.dart';
import 'agent.dart';

/// Modèle représentant une demande d'acte d'état civil soumise par un citoyen.
class Demande {
  final String id;
  final Document document;
  final Citoyen citoyen;
  final DateTime dateDemande;
  String statut; // 'reçue', 'en cours', 'prête', 'livrée'
  
  // Données spécifiques saisies dans le formulaire selon le type d'acte demandé
  final Map<String, String> donneesFormulaire;

  // Map des pièces justificatives fournies par le citoyen
  final Map<String, String> piecesFournies;

  // Note interne rédigée par l'agent de mairie
  String noteAgent;

  Demande({
    required this.id,
    required this.document,
    required this.citoyen,
    required this.dateDemande,
    required this.donneesFormulaire,
    required this.piecesFournies,
    this.statut = 'reçue',
    this.noteAgent = '',
  });

}

/// Classe utilitaire (Singleton) simulant la base de données locale en mémoire.
/// Permet la persistance des données pendant toute la session de l'application.
class DatabaseSimulee {
  // Le citoyen actuellement connecté après avoir créé son profil
  static Citoyen? citoyenConnecte;

  // L'agent de mairie actuellement connecté
  static Agent? agentConnecte;

  // Profils citoyens enregistrés (permet la re-connexion avec l'email)
  static final List<Citoyen> citoyensInscrits = [];

  /// Compte citoyen de démonstration pour tests rapides
  static Citoyen get citoyenDemo => Citoyen(
        prenom: 'Mamadou',
        nom: 'Diop',
        telephone: '771234567',
        email: 'mamadou.diop@email.sn',
        adresse: 'Médina, Rue 22, Dakar',
      );

  /// Compte agent de démonstration pour tests rapides
  static Agent get agentDemo => Agent(
        prenom: 'Aminata',
        nom: 'Fall',
        matricule: 'AGT-2024-001',
        role: "Officier d'État Civil",
        email: 'aminata.fall@mairie-dakar.sn',
      );
  
  // Liste des demandes enregistrées (avec des données exemples pour la démonstration)
  static final List<Demande> demandes = [
    Demande(
      id: '1001',
      document: documentsDisponibles[1], // Extrait de naissance
      citoyen: Citoyen(
        prenom: 'Mamadou',
        nom: 'Diop',
        telephone: '771234567',
        email: 'mamadou.diop@email.sn',
        adresse: 'Médina, Rue 22, Dakar',
      ),
      dateDemande: DateTime.now().subtract(const Duration(days: 2)),
      donneesFormulaire: {
        'prenom_titulaire': 'Mamadou',
        'nom_titulaire': 'Diop',
        'sexe': 'Masculin',
        'date_naissance': '14/05/2000',
        'lieu_naissance': 'Dakar',
        'num_registre': '2451',
        'annee_registre': '2000',
        'centre_etat_civil': 'Mairie de Dakar-Plateau',
        'prenom_nom_pere': 'Ibrahima Diop',
        'prenom_nom_mere': 'Fatou Sall',
      },
      piecesFournies: {
        'Copie d\'une pièce d\'identité valide (CNI ou Passeport)': 'fournie',
        'Ancien extrait de naissance ou numéro de registre d\'acte': 'fournie',
      },
      statut: 'reçue',
      noteAgent: 'Vérification du registre en cours auprès du service des archives.',
    ),
    Demande(
      id: '1002',
      document: documentsDisponibles[2], // Certificat de mariage
      citoyen: Citoyen(
        prenom: 'Awa',
        nom: 'Ndiaye',
        telephone: '782345678',
        email: 'awa.ndiaye@email.sn',
        adresse: 'Mermoz, Dakar',
      ),
      dateDemande: DateTime.now().subtract(const Duration(days: 4)),
      donneesFormulaire: {
        'prenom_epoux': 'Cheikh',
        'nom_epoux': 'Seck',
        'date_naissance_epoux': '22/08/1995',
        'prenom_epouse': 'Awa',
        'nom_epouse': 'Ndiaye',
        'date_naissance_epouse': '10/11/1997',
        'date_mariage': '15/02/2023',
        'lieu_mariage': 'Mairie des Almadies',
        'regime_matrimonial': 'Monogamie - Séparation de biens',
        'num_acte_mariage': 'MAR-2023-088',
      },
      piecesFournies: {
        'Copie de la CNI de l\'époux': 'fournie',
        'Copie de la CNI de l\'épouse': 'fournie',
        'Attestation de célébration de mariage ou numéro de registre': 'fournie',
      },
      statut: 'en cours',
      noteAgent: 'Signature de l\'officier d\'état civil en attente.',
    ),
    Demande(
      id: '1003',
      document: documentsDisponibles[0], // Acte de naissance
      citoyen: Citoyen(
        prenom: 'Ousmane',
        nom: 'Fall',
        telephone: '763456789',
        email: 'ousmane.fall@email.sn',
        adresse: 'Saint-Louis, Sor',
      ),
      dateDemande: DateTime.now().subtract(const Duration(days: 6)),
      donneesFormulaire: {
        'prenom_enfant': 'Mariama',
        'nom_enfant': 'Fall',
        'sexe': 'Féminin',
        'date_naissance': '02/09/2026',
        'heure_naissance': '06h45',
        'lieu_naissance': 'Hôpital Régional de Saint-Louis',
        'prenom_nom_pere': 'Ousmane Fall',
        'profession_pere': 'Enseignant',
        'prenom_nom_mere': 'Aminata Ba',
        'profession_mere': 'Comptable',
        'domicile_parents': 'Quartier Sor, Saint-Louis',
      },
      piecesFournies: {
        'Copie de la CNI/Passeport du déclarant (Parent)': 'fournie',
        'Certificat d\'accouchement ou d\'attestation médicale de naissance': 'fournie',
        'Livret de famille ou certificat de mariage des parents': 'fournie',
      },
      statut: 'prête',
      noteAgent: 'Document imprimé et légalisé, prêt pour retrait au guichet n° 3.',
    ),
  ];

  // Notification simulées destinées aux citoyens
  static final List<Map<String, dynamic>> notifications = [
    {
      'message': 'Votre demande d\'acte de naissance pour Mariama Fall est prête pour retrait.',
      'date': DateTime.now().subtract(const Duration(hours: 3)),
      'demandeId': '1003',
      'telephone': '763456789',
    },
    {
      'message': 'Votre demande de certificat de mariage est en cours de traitement par nos services.',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'demandeId': '1002',
      'telephone': '782345678',
    },
  ];

  /// Réinitialise toutes les données à leur état de démonstration initial
  static void reinitialiserDemo() {
    demandes.clear();
    demandes.addAll([
      Demande(
        id: '1001',
        document: documentsDisponibles[1],
        citoyen: Citoyen(
          prenom: 'Mamadou',
          nom: 'Diop',
          telephone: '771234567',
          email: 'mamadou.diop@email.sn',
          adresse: 'Médina, Rue 22, Dakar',
        ),
        dateDemande: DateTime.now().subtract(const Duration(days: 2)),
        donneesFormulaire: {
          'prenom_titulaire': 'Mamadou',
          'nom_titulaire': 'Diop',
          'sexe': 'Masculin',
          'date_naissance': '14/05/2000',
          'lieu_naissance': 'Dakar',
          'num_registre': '2451',
          'annee_registre': '2000',
          'centre_etat_civil': 'Mairie de Dakar-Plateau',
          'prenom_nom_pere': 'Ibrahima Diop',
          'prenom_nom_mere': 'Fatou Sall',
        },
        piecesFournies: {
          'Copie d\'une pièce d\'identité valide (CNI ou Passeport)': 'fournie',
          'Ancien extrait de naissance ou numéro de registre d\'acte': 'fournie',
        },
        statut: 'reçue',
        noteAgent: 'Vérification du registre en cours auprès du service des archives.',
      ),
      Demande(
        id: '1002',
        document: documentsDisponibles[2],
        citoyen: Citoyen(
          prenom: 'Awa',
          nom: 'Ndiaye',
          telephone: '782345678',
          email: 'awa.ndiaye@email.sn',
          adresse: 'Mermoz, Dakar',
        ),
        dateDemande: DateTime.now().subtract(const Duration(days: 4)),
        donneesFormulaire: {
          'prenom_epoux': 'Cheikh',
          'nom_epoux': 'Seck',
          'date_naissance_epoux': '22/08/1995',
          'prenom_epouse': 'Awa',
          'nom_epouse': 'Ndiaye',
          'date_naissance_epouse': '10/11/1997',
          'date_mariage': '15/02/2023',
          'lieu_mariage': 'Mairie des Almadies',
          'regime_matrimonial': 'Monogamie - Séparation de biens',
          'num_acte_mariage': 'MAR-2023-088',
        },
        piecesFournies: {
          'Copie de la CNI de l\'époux': 'fournie',
          'Copie de la CNI de l\'épouse': 'fournie',
          'Attestation de célébration de mariage ou numéro de registre': 'fournie',
        },
        statut: 'en cours',
        noteAgent: 'Signature de l\'officier d\'état civil en attente.',
      ),
      Demande(
        id: '1003',
        document: documentsDisponibles[0],
        citoyen: Citoyen(
          prenom: 'Ousmane',
          nom: 'Fall',
          telephone: '763456789',
          email: 'ousmane.fall@email.sn',
          adresse: 'Saint-Louis, Sor',
        ),
        dateDemande: DateTime.now().subtract(const Duration(days: 6)),
        donneesFormulaire: {
          'prenom_enfant': 'Mariama',
          'nom_enfant': 'Fall',
          'sexe': 'Féminin',
          'date_naissance': '02/09/2026',
          'heure_naissance': '06h45',
          'lieu_naissance': 'Hôpital Régional de Saint-Louis',
          'prenom_nom_pere': 'Ousmane Fall',
          'profession_pere': 'Enseignant',
          'prenom_nom_mere': 'Aminata Ba',
          'profession_mere': 'Comptable',
          'domicile_parents': 'Quartier Sor, Saint-Louis',
        },
        piecesFournies: {
          'Copie de la CNI/Passeport du déclarant (Parent)': 'fournie',
          'Certificat d\'accouchement ou d\'attestation médicale de naissance': 'fournie',
          'Livret de famille ou certificat de mariage des parents': 'fournie',
        },
        statut: 'prête',
        noteAgent: 'Document imprimé et légalisé, prêt pour retrait au guichet n° 3.',
      ),
    ]);

    notifications.clear();
    notifications.addAll([
      {
        'message': 'Votre demande d\'acte de naissance pour Mariama Fall est prête pour retrait.',
        'date': DateTime.now().subtract(const Duration(hours: 3)),
        'demandeId': '1003',
        'telephone': '763456789',
      },
      {
        'message': 'Votre demande de certificat de mariage est en cours de traitement par nos services.',
        'date': DateTime.now().subtract(const Duration(days: 1)),
        'demandeId': '1002',
        'telephone': '782345678',
      },
    ]);
  }

  /// Injecte une nouvelle demande de test pour démontrer le temps réel
  static Demande injecterDemandeDemo() {
    final nouvelleId = (1000 + demandes.length + 1).toString();
    final nouvelleDemande = Demande(
      id: nouvelleId,
      document: documentsDisponibles[0], // Acte de naissance
      citoyen: Citoyen(
        prenom: 'Sokhna',
        nom: 'Diagne',
        telephone: '776543210',
        email: 'sokhna.diagne@demo.sn',
        adresse: 'Point E, Rue 5, Dakar',
      ),
      dateDemande: DateTime.now(),
      donneesFormulaire: {
        'prenom_enfant': 'Alioune Badara',
        'nom_enfant': 'Diagne',
        'sexe': 'Masculin',
        'date_naissance': '12/10/2026',
        'heure_naissance': '14h30',
        'lieu_naissance': 'Clinique de la Madeleine, Dakar',
        'prenom_nom_pere': 'Moussa Diagne',
        'profession_pere': 'Architecte',
        'prenom_nom_mere': 'Sokhna Diagne',
        'profession_mere': 'Pharmacienne',
        'domicile_parents': 'Point E, Dakar',
      },
      piecesFournies: {
        'Copie de la CNI/Passeport du déclarant (Parent)': 'fournie',
        'Certificat d\'accouchement ou d\'attestation médicale de naissance': 'fournie',
        'Livret de famille ou certificat de mariage des parents': 'fournie',
      },
      statut: 'reçue',
      noteAgent: 'Nouvelle demande injectée pour démonstration.',
    );
    demandes.insert(0, nouvelleDemande);
    return nouvelleDemande;
  }
}

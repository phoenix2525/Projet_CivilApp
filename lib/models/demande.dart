import 'citoyen.dart';
import 'document.dart';
import 'agent.dart';

class Demande {
  final String id;
  final Document document;
  final Citoyen citoyen;
  final DateTime dateDemande;
  String statut; // Statuts possibles: 'reçue', 'en cours', 'prête', 'livrée'
  
  // Données spécifiques saisies dans le formulaire selon le type d'acte demandé
  final Map<String, String> donneesFormulaire;

  // Map liant l'intitulé de la pièce à fournir au chemin du fichier image sélectionné
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

/// Classe utilitaire (Singleton-like) pour simuler une base de données en mémoire.
class DatabaseSimulee {
  // Le citoyen actuellement "connecté" après avoir créé son profil
  static Citoyen? citoyenConnecte;

  // L'agent actuellement "connecté"
  static Agent? agentConnecte;
  
  // Historique de toutes les demandes
  static final List<Demande> demandes = [];

  // Liste des notifications simulées pour le citoyen
  static final List<Map<String, dynamic>> notifications = [];
}

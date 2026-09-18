import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../firebase_options.dart';
import '../models/citoyen.dart';
import '../models/agent.dart';
import '../models/demande.dart';

/// Service central gérant Firebase (Authentification et Base de données Cloud Firestore).
/// Conçu pour fonctionner avec une synchronisation temps réel et un mode de secours (fallback)
/// en mémoire si le réseau ou les services Firebase sont indisponibles.
class FirebaseService {
  static bool _initialise = false;
  static bool get estDisponible => _initialise;

  static FirebaseAuth get _auth => FirebaseAuth.instance;
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  /// Initialise Firebase avec gestion propre des erreurs
  static Future<void> initialiser() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialise = true;
      debugPrint('CivilApp: Firebase initialisé avec succès.');

      // Lancer l'écoute automatique des demandes en temps réel
      ecouterDemandesEnTempsReel();
    } catch (e) {
      _initialise = false;
      debugPrint('CivilApp: Avertissement - Firebase non disponible ($e). Mode local actif.');
    }
  }

  // ==========================================
  // --- AUTHENTIFICATION CITOYEN & AGENT ---
  // ==========================================

  /// Inscription d'un citoyen avec Email et Mot de passe
  static Future<Citoyen> inscrireCitoyen({
    required String email,
    required String password,
    required String prenom,
    required String nom,
    required String telephone,
    required String adresse,
  }) async {
    Citoyen nouveauCitoyen = Citoyen(
      prenom: prenom,
      nom: nom,
      telephone: telephone,
      email: email,
      adresse: adresse,
    );

    if (_initialise) {
      try {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final uid = cred.user!.uid;
        nouveauCitoyen = Citoyen(
          id: uid,
          prenom: prenom,
          nom: nom,
          telephone: telephone,
          email: email,
          adresse: adresse,
        );

        // Sauvegarde des informations supplémentaires dans Firestore
        await _firestore.collection('utilisateurs').doc(uid).set(nouveauCitoyen.toMap());
      } catch (e) {
        debugPrint('Erreur Firebase Inscription: $e');
        rethrow;
      }
    }

    // Mise à jour de la session locale
    DatabaseSimulee.citoyenConnecte = nouveauCitoyen;
    return nouveauCitoyen;
  }

  /// Connexion d'un citoyen existant
  static Future<Citoyen> connecterCitoyen({
    required String email,
    required String password,
  }) async {
    if (_initialise) {
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final uid = cred.user!.uid;
        final doc = await _firestore.collection('utilisateurs').doc(uid).get();

        if (doc.exists && doc.data() != null) {
          final citoyen = Citoyen.fromMap(doc.data()!, id: uid);
          DatabaseSimulee.citoyenConnecte = citoyen;
          return citoyen;
        } else {
          // Si le profil Firestore n'existe pas encore, on compose avec les données de base
          final citoyen = Citoyen(
            id: uid,
            prenom: 'Citoyen',
            nom: '',
            telephone: '',
            email: email,
            adresse: 'Sénégal',
          );
          DatabaseSimulee.citoyenConnecte = citoyen;
          return citoyen;
        }
      } catch (e) {
        debugPrint('Erreur Firebase Connexion: $e');
        rethrow;
      }
    } else {
      // Mode secours / hors-ligne
      final citoyen = Citoyen(
        prenom: 'Citoyen',
        nom: 'Connecté',
        telephone: '770000000',
        email: email,
        adresse: 'Dakar, Sénégal',
      );
      DatabaseSimulee.citoyenConnecte = citoyen;
      return citoyen;
    }
  }

  /// Connexion d'un agent de la mairie
  static Future<Agent> connecterAgent({
    required String prenom,
    required String nom,
    required String matricule,
    required String role,
    String? email,
    String? password,
  }) async {
    final agent = Agent(
      prenom: prenom,
      nom: nom,
      matricule: matricule,
      role: role,
      email: email,
    );

    if (_initialise && email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
      try {
        UserCredential cred;
        try {
          cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
        } catch (_) {
          cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
        }

        final uid = cred.user!.uid;
        await _firestore.collection('agents').doc(uid).set(agent.toMap(), SetOptions(merge: true));
      } catch (e) {
        debugPrint('Erreur Firebase Connexion Agent: $e');
      }
    }

    DatabaseSimulee.agentConnecte = agent;
    return agent;
  }

  /// Déconnexion
  static Future<void> deconnecter() async {
    if (_initialise) {
      try {
        await _auth.signOut();
      } catch (e) {
        debugPrint('Erreur deconnexion Firebase: $e');
      }
    }
    DatabaseSimulee.citoyenConnecte = null;
    DatabaseSimulee.agentConnecte = null;
  }

  // ==========================================
  // --- CLOUD FIRESTORE : GESTION DES DEMANDES
  // ==========================================

  /// Enregistre une nouvelle demande dans Firestore et localement
  static Future<void> soumettreDemande(Demande demande) async {
    // 1. Toujours enregistrer localement pour réactivité instantanée
    if (!DatabaseSimulee.demandes.any((d) => d.id == demande.id)) {
      DatabaseSimulee.demandes.insert(0, demande);
    }

    // 2. Si Firebase est disponible, persister dans le cloud
    if (_initialise) {
      try {
        await _firestore.collection('demandes').doc(demande.id).set(demande.toMap());
        debugPrint('CivilApp: Demande ${demande.id} sauvegardée sur Cloud Firestore.');
      } catch (e) {
        debugPrint('Erreur sauvegarde Firestore: $e');
      }
    }
  }

  /// Met à jour le statut et la note d'une demande (par l'agent)
  static Future<void> mettreAJourStatutDemande({
    required String demandeId,
    required String nouveauStatut,
    String? noteAgent,
  }) async {
    // Mise à jour locale
    final index = DatabaseSimulee.demandes.indexWhere((d) => d.id == demandeId);
    if (index != -1) {
      DatabaseSimulee.demandes[index].statut = nouveauStatut;
      if (noteAgent != null) {
        DatabaseSimulee.demandes[index].noteAgent = noteAgent;
      }
    }

    // Mise à jour Cloud Firestore
    if (_initialise) {
      try {
        final data = <String, dynamic>{
          'statut': nouveauStatut,
        };
        if (noteAgent != null) {
          data['noteAgent'] = noteAgent;
        }
        await _firestore.collection('demandes').doc(demandeId).update(data);
        debugPrint('CivilApp: Demande $demandeId mise à jour sur Firestore.');
      } catch (e) {
        debugPrint('Erreur mise à jour Firestore: $e');
      }
    }
  }

  /// Écoute en continu la collection 'demandes' sur Firestore et synchronise la base locale
  static void ecouterDemandesEnTempsReel() {
    if (!_initialise) return;

    try {
      _firestore.collection('demandes').orderBy('dateDemande', descending: true).snapshots().listen((snapshot) {
        for (var change in snapshot.docChanges) {
          final data = change.doc.data();
          if (data == null) continue;

          final demande = Demande.fromMap(data, change.doc.id);
          final index = DatabaseSimulee.demandes.indexWhere((d) => d.id == demande.id);

          if (index != -1) {
            // Mettre à jour la demande existante
            DatabaseSimulee.demandes[index] = demande;
          } else {
            // Ajouter la nouvelle demande venant du cloud
            DatabaseSimulee.demandes.insert(0, demande);
          }
        }
        debugPrint('CivilApp: Demandes synchronisées depuis Firestore (${DatabaseSimulee.demandes.length} au total).');
      }, onError: (err) {
        debugPrint('Erreur écoute temps réel Firestore: $err');
      });
    } catch (e) {
      debugPrint('Erreur lancement stream Firestore: $e');
    }
  }
}

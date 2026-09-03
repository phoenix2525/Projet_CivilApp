# CivilApp - Suivi de Projet Académique

## Contexte
Ce projet est une application mobile Flutter d'évaluation (projet académique) nommée **CivilApp**. L'objectif est de dématérialiser certaines procédures administratives de la mairie (demandes d'actes de naissance, certificats de mariage, certificats de décès, etc.).
Le code est **strictement basé sur les concepts enseignés dans les cours et les Labs** (widgets de base, listes, navigation, POO Dart, gestion d'état simple `setState` et singleton en mémoire).

---

## Conformité avec la Description du Projet (PDF & Exigences)

### 1. Formulaires de demande spécifiques & rigoureux
Auparavant, le formulaire était générique. Désormais, chaque acte possède un formulaire dédié adapté aux réalités administratives de l'état civil sénégalais :
- **Acte de Naissance (Déclaration / Copie Intégrale)** :
  - Identité du nouveau-né : Prénom(s), Nom, Sexe, Date de naissance, Heure de naissance, Lieu/Structure sanitaire.
  - Filiation : Prénom & Nom du Père, Profession du Père, Prénom & Nom de la Mère, Profession de la Mère, Domicile des parents.
- **Extrait de Naissance** :
  - Titulaire : Prénom(s), Nom, Sexe, Date & Lieu de naissance.
  - Registre : N° d'Acte/Registre, Année du registre, Centre d'état civil.
  - Filiation : Prénom & Nom du Père, Prénom & Nom de la Mère.
- **Certificat de Mariage** :
  - Époux : Prénom(s), Nom, Date & Lieu de naissance.
  - Épouse : Prénom(s), Nom, Date & Lieu de naissance.
  - Union : Date du mariage, Lieu de célébration, Régime matrimonial (Monogamie/Polygamie & Séparation/Communauté de biens), N° d'acte de mariage.
- **Certificat de Décès** :
  - Défunt : Prénom(s), Nom, Date de naissance, Date & Heure du décès, Lieu du décès.
  - Déclarant : Prénom & Nom, Lien de parenté (Conjoint, Enfant, Parent, Frère/Sœur, etc.), N° CNI du déclarant.

### 2. Check-list dynamique des pièces à fournir
- Chaque type de document (`Document.piecesAFournir` dans `models/document.dart`) génère dynamiquement une check-list interactive.
- Validation obligatoire : le citoyen doit cocher **TOUTES les pièces justificatives exigées** avant de pouvoir soumettre sa demande à la mairie.

### 3. Traitement côté Agent de Mairie
- L'agent visualise l'intégralité des données spécifiques saisies pour l'acte demandé dans `traitement_demande_page.dart`.
- L'agent vérifie la checklist des pièces fournies, modifie le statut (`reçue`, `en cours`, `prête`, `livrée`), saisit des notes internes et notifie le citoyen.

---

## Fonctionnalités Principales & Statut

### Espace Citoyen
- [x] **Profil citoyen persistant** : Création de compte (prénom, nom, tel, e-mail, adresse). → `creer_profil_page.dart`, `models/citoyen.dart`
- [x] **Catalogue de documents** : Consultation des actes disponibles avec pièces requises. → `catalogue_page.dart`, `models/document.dart`
- [x] **Formulaire de demande dynamique** : Formulaire adapté selon le type d'acte (Naissance, Extrait, Mariage, Décès). → `formulaire_demande_page.dart`
- [x] **Vérification des pièces à fournir** : Check-list dynamique spécifique et obligatoire par document. → `formulaire_demande_page.dart`
- [x] **Enregistrement/Envoi de la demande** : Sauvegarde dans `DatabaseSimulee.demandes`. → `models/demande.dart`
- [x] **Suivi du statut & notifications** : Consultation de l'historique et des notifications envoyées par la mairie. → `mes_demandes_page.dart`

### Espace Agent Mairie
- [x] **Profil Agent mairie** : Connexion agent (prénom, nom, matricule, rôle). → `connexion_agent_page.dart`, `models/agent.dart`
- [x] **Interface de gestion** : Liste des demandes reçues avec **barre de recherche** et **filtrage par statut** (FilterChips). → `gestion_demandes_page.dart`
- [x] **Traitement complet de demande** : Affichage exhaustif des données du formulaire spécifique, vérification des pièces, édition du statut, **notes internes agent**. → `traitement_demande_page.dart`
- [x] **Notification de disponibilité** : Envoi de notifications push/message simulées reçues par le citoyen. → `traitement_demande_page.dart` & `mes_demandes_page.dart`

---

## Architecture des fichiers

```
lib/
├── main.dart                        # Point d'entrée de l'app
├── accueil_page.dart                # Accueil (Choix Citoyen / Agent)
├── creer_profil_page.dart           # Création de profil citoyen
├── catalogue_page.dart              # Catalogue des actes d'état civil
├── formulaire_demande_page.dart     # Formulaire dynamique spécifique par acte + checklist pièces
├── mes_demandes_page.dart           # Suivi des demandes citoyen + notifications
├── connexion_agent_page.dart        # Connexion espace agent mairie
├── gestion_demandes_page.dart       # Interface agent (Liste, recherche, filtres statut)
├── traitement_demande_page.dart     # Traitement agent (Champs spécifiques, pièces, statut, notes)
└── models/
    ├── citoyen.dart                 # Modèle Citoyen
    ├── document.dart                # Modèle Document (id, titre, description, piecesAFournir)
    ├── demande.dart                 # Modèle Demande (donneesFormulaire Map, piecesFournies, noteAgent) + DatabaseSimulee
    └── agent.dart                   # Modèle Agent
```

---
**Note pour l'assistant IA :** Lors de chaque nouvelle session, lisez ce fichier pour reprendre le contexte exact du projet.

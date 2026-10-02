# CivilApp 🏛️

Application mobile Flutter de dématérialisation des demandes d'actes d'état civil de la mairie : acte de naissance, extrait de naissance, certificat de mariage, certificat de décès.

**Projet académique — L3 Informatique, Développement d'Applications Mobiles**

## 📱 Fonctionnement

L'application fonctionne 100% en mémoire locale (`DatabaseSimulee`, singleton statique) : aucune base de données externe n'est nécessaire pour lancer le projet.

### Espace Citoyen
- Création de profil (prénom, nom, téléphone, e-mail, adresse) et re-connexion par e-mail
- Catalogue des actes avec recherche instantanée, délais et frais
- Formulaire guidé spécifique à chaque acte + checklist obligatoire des pièces à fournir
- Numéro de suivi officiel généré après l'envoi de la demande
- Suivi du statut (reçue → en cours → prête → livrée) et notifications de la mairie

### Espace Agent Mairie
- Connexion agent (prénom, nom, matricule, rôle)
- Liste des demandes avec recherche instantanée et filtres par statut
- Traitement complet : consultation des données saisies, vérification des pièces, changement de statut, notes internes et notification du citoyen

## 🚀 Lancer le projet

```bash
flutter pub get
flutter run
```

## 🏗️ Architecture

```
lib/
├── main.dart                          # Point d'entrée — MaterialApp + thème
├── accueil_page.dart                  # Accueil (choix Citoyen / Agent)
├── creer_profil_page.dart             # Inscription / connexion citoyen
├── tableau_de_bord_citoyen_page.dart  # Tableau de bord citoyen (stats + BottomNav)
├── catalogue_page.dart                # Catalogue des actes (recherche + Hero)
├── details_document_page.dart         # Détails d'un acte (délais, frais, pièces, étapes)
├── formulaire_demande_page.dart       # Formulaires dynamiques + checklist pièces
├── confirmation_envoi_page.dart       # Confirmation d'envoi + N° de suivi
├── mes_demandes_page.dart             # Suivi des demandes + notifications
├── details_demande_citoyen_page.dart  # Détail et avancement d'une demande (timeline)
├── connexion_agent_page.dart          # Connexion espace agent
├── gestion_demandes_page.dart         # Liste des demandes (recherche + FilterChips)
├── traitement_demande_page.dart       # Traitement d'une demande (statut + notes)
└── models/
    ├── citoyen.dart                   # Modèle Citoyen
    ├── document.dart                  # Modèle Document + données du catalogue
    ├── demande.dart                   # Modèle Demande + DatabaseSimulee (singleton)
    └── agent.dart                     # Modèle Agent
```

## 🛠️ Notions utilisées

- `StatefulWidget` + `setState` : gestion d'état (formulaires, filtres, checklist)
- `Form` + `GlobalKey<FormState>` + `validator` : validation des champs de saisie
- `TextEditingController` + `dispose()` : gestion de la mémoire des champs
- `Navigator.push` / `Navigator.pushReplacement` : navigation entre les pages
- `ListView.builder` / `ListView.separated` : listes dynamiques
- `DropdownButtonFormField` : sélection (sexe, régime matrimonial, rôle...)
- `CheckboxListTile` : checklist des pièces à fournir
- `Hero` : transitions animées catalogue → formulaire
- `BackdropFilter` + `ImageFilter.blur` : effet glassmorphism (accueil, catalogue)
- Singleton statique (`DatabaseSimulee`) : données partagées entre les pages

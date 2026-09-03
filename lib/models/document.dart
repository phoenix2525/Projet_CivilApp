import 'package:flutter/material.dart';

class Document {
  final String id;
  final String titre;
  final String description;
  final IconData icon;
  final Color couleur;
  final List<String> piecesAFournir;

  Document({
    required this.id,
    required this.titre,
    required this.description,
    required this.icon,
    required this.couleur,
    required this.piecesAFournir,
  });
}

// Liste de données simulées pour le catalogue avec pièces requises spécifiques
final List<Document> documentsDisponibles = [
  Document(
    id: 'acte_naissance',
    titre: 'Acte de naissance',
    description: 'Copie intégrale de l\'acte de naissance, certifiée conforme par l\'officier d\'état civil.',
    icon: Icons.child_care,
    couleur: Colors.green,
    piecesAFournir: [
      'Copie de la CNI/Passeport du déclarant (Parent)',
      'Certificat d\'accouchement ou d\'attestation médicale de naissance',
      'Livret de famille ou certificat de mariage des parents',
    ],
  ),
  Document(
    id: 'extrait_naissance',
    titre: 'Extrait de naissance',
    description: 'Document synthétique reprenant les informations essentielles de l\'acte de naissance.',
    icon: Icons.assignment,
    couleur: Colors.blue,
    piecesAFournir: [
      'Copie d\'une pièce d\'identité valide (CNI ou Passeport)',
      'Ancien extrait de naissance ou numéro de registre d\'acte',
    ],
  ),
  Document(
    id: 'certificat_mariage',
    titre: 'Certificat de mariage',
    description: 'Attestation officielle de l\'union civile, délivrée suite à la célébration du mariage.',
    icon: Icons.favorite,
    couleur: Colors.red,
    piecesAFournir: [
      'Copie de la CNI de l\'époux',
      'Copie de la CNI de l\'épouse',
      'Attestation de célébration de mariage ou numéro de registre',
    ],
  ),
  Document(
    id: 'certificat_deces',
    titre: 'Certificat de décès',
    description: 'Document constatant officiellement le décès d\'une personne, nécessaire pour les démarches administratives.',
    icon: Icons.account_box,
    couleur: Colors.grey,
    piecesAFournir: [
      'Certificat médical de constatation de décès',
      'Copie de la CNI du défunt (si disponible)',
      'Copie de la CNI du déclarant',
    ],
  ),
];

// Test de base de l'application.
// Vérifie que l'écran d'accueil se lance bien et propose les deux espaces.

import 'package:flutter_test/flutter_test.dart';

import 'package:civil_app/main.dart';

void main() {
  testWidgets("L'écran d'accueil s'affiche au lancement", (WidgetTester tester) async {
    // Construction de l'application et déclenchement d'une frame
    await tester.pumpWidget(const MyApp());

    // L'accueil doit afficher le nom de l'application et les deux espaces
    expect(find.text('CivilApp'), findsOneWidget);
    expect(find.text('Espace Citoyen'), findsOneWidget);
    expect(find.text('Espace Agent Mairie'), findsOneWidget);
  });
}

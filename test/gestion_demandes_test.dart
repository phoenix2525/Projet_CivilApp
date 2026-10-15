import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civil_app/gestion_demandes_page.dart';
import 'package:civil_app/models/demande.dart';
import 'package:civil_app/models/agent.dart';

void main() {
  testWidgets('Test GestionDemandesPage for overflow', (WidgetTester tester) async {
    // Configure simulated agent
    DatabaseSimulee.agentConnecte = Agent(
      prenom: 'Ibrahima',
      nom: 'Sow',
      matricule: 'AGT-2024-001',
      role: "Officier d'État Civil",
    );

    // Standard phone screen size with top padding for status bar (e.g. 38.8 or 36.8)
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75; // e.g. Pixel 7 / standard 1080p display
    // That gives 392.7 x 872.7 logical size
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: GestionDemandesPage(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(find.text('Gestion des Demandes'), findsOneWidget);
  });
}

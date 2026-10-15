import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:civil_app/tableau_de_bord_citoyen_page.dart';
import 'package:civil_app/catalogue_page.dart';
import 'package:civil_app/mes_demandes_page.dart';
import 'package:civil_app/creer_profil_page.dart';
import 'package:civil_app/connexion_agent_page.dart';
import 'package:civil_app/details_demande_citoyen_page.dart';
import 'package:civil_app/traitement_demande_page.dart';
import 'package:civil_app/models/citoyen.dart';
import 'package:civil_app/models/demande.dart';

void main() {
  setUp(() {
    DatabaseSimulee.citoyenConnecte = Citoyen(
      prenom: 'Mamadou',
      nom: 'Diop',
      telephone: '771234567',
      email: 'mamadou.diop@email.sn',
      adresse: 'Médina, Rue 22, Dakar',
    );
  });

  testWidgets('Test TableauDeBordCitoyenPage for overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(const MaterialApp(home: TableauDeBordCitoyenPage()));
    await tester.pumpAndSettle();

    expect(find.text('Mon Espace'), findsOneWidget);

    // Test scroll to verify SliverAppBar collapse
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
  });

  testWidgets('Test CreerProfilPage for overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(const MaterialApp(home: CreerProfilPage()));
    await tester.pumpAndSettle();

    expect(find.text('Créer mon compte'), findsOneWidget);
  });

  testWidgets('Test ConnexionAgentPage for overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(const MaterialApp(home: ConnexionAgentPage()));
    await tester.pumpAndSettle();

    expect(find.text('Espace Agent'), findsOneWidget);
  });

  testWidgets('Test MesDemandesPage for overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(const MaterialApp(home: MesDemandesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Mes Dossiers'), findsNWidgets(2));
  });

  testWidgets('Test DetailsDemandeCitoyenPage for overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(MaterialApp(home: DetailsDemandeCitoyenPage(demande: DatabaseSimulee.demandes.first)));
    await tester.pumpAndSettle();

    expect(find.text('Détail de ma demande'), findsOneWidget);
  });

  testWidgets('Test CataloguePage for overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(const MaterialApp(home: CataloguePage()));
    await tester.pumpAndSettle();

    expect(find.text('Catalogue'), findsNWidgets(2));
  });

  testWidgets('Test TraitementDemandePage for overflow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    tester.view.padding = FakeViewPadding(
      top: 36.8 * tester.view.devicePixelRatio,
      bottom: 20.0 * tester.view.devicePixelRatio,
    );

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetPadding();
    });

    await tester.pumpWidget(MaterialApp(home: TraitementDemandePage(demande: DatabaseSimulee.demandes.first)));
    await tester.pumpAndSettle();

    expect(find.text('Détails & Traitement'), findsOneWidget);
  });
}

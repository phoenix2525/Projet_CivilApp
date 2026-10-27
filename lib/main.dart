import 'package:flutter/material.dart';

import 'accueil_page.dart';
import 'app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CivilApp',
      debugShowCheckedModeBanner: false,
      theme: construireThemeCivilApp(),
      home: const AccueilPage(),
    );
  }
}

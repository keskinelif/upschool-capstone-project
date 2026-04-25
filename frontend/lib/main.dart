import 'package:flutter/material.dart';

import 'screens/explore_screen.dart';

void main() => runApp(const GriApp());

class GriApp extends StatelessWidget {
  const GriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gri.',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF232529),
        ),
        useMaterial3: true,
      ),
      home: const ExploreScreen(),
    );
  }
}

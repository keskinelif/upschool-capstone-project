import 'package:flutter/material.dart';

import 'screens/admin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_session.dart';
import 'theme/gri_theme.dart';

void main() => runApp(const GriApp());

class GriApp extends StatelessWidget {
  const GriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'gri.',
      debugShowCheckedModeBanner: false,
      theme: GriTheme.material(),
      home: _initialScreen(),
    );
  }

  Widget _initialScreen() {
    if (!AuthSession.isLoggedIn) return const LoginScreen();
    if (AuthSession.isAdmin) return const AdminScreen();
    return const HomeScreen();
  }
}

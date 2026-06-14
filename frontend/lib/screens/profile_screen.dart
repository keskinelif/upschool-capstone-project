import 'package:flutter/material.dart';

import '../services/auth_session.dart';
import '../theme/gri_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GriSpacing.sp6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: GriColors.primary,
              ),
              alignment: Alignment.center,
              child: Text(
                'AK',
                style: GriTheme.h3().copyWith(color: GriColors.onPrimary),
              ),
            ),
            const SizedBox(height: GriSpacing.sp4),
            Text('Profil', style: GriTheme.h1()),
            const SizedBox(height: GriSpacing.sp2),
            Text(
              'Hesap ayarları yakında.',
              style: GriTheme.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GriSpacing.sp8),
            OutlinedButton(
              onPressed: () {
                AuthSession.clear();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: GriColors.primary,
                side: const BorderSide(color: GriColors.primary, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GriRadii.full),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Çıkış Yap'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../theme/gri_theme.dart';

enum HomeNavTab { favorites, profile }

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({
    required this.activeTab,
    required this.onTabChanged,
    super.key,
  });

  final HomeNavTab? activeTab;
  final ValueChanged<HomeNavTab> onTabChanged;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GriSpacing.sp8,
          vertical: GriSpacing.sp4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavCircle(
              label: 'Favoriler',
              icon: Icons.favorite_border,
              active: activeTab == HomeNavTab.favorites,
              onTap: () => onTabChanged(HomeNavTab.favorites),
            ),
            _NavCircle(
              label: 'Profile',
              icon: Icons.person_outline,
              active: activeTab == HomeNavTab.profile,
              onTap: () => onTabChanged(HomeNavTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavCircle extends StatelessWidget {
  const _NavCircle({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GriRadii.full),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active ? GriColors.primary : GriColors.onPrimary,
                border: Border.all(
                  color: active ? GriColors.primary : GriColors.border,
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? GriColors.onPrimary : GriColors.muted,
              ),
            ),
            const SizedBox(height: GriSpacing.sp2),
            Text(label, style: GriTheme.navLabel(active: active)),
          ],
        ),
      ),
    );
  }
}

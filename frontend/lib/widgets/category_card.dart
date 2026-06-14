import 'package:flutter/material.dart';

import '../theme/gri_theme.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.label,
    required this.onTap,
    super.key,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GriColors.onPrimary,
      borderRadius: BorderRadius.circular(GriRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GriRadii.lg),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.symmetric(
            horizontal: GriSpacing.sp6,
            vertical: GriSpacing.sp4,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GriRadii.lg),
            border: Border.all(
              color: GriColors.primary.withValues(alpha: 0.07),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14232529),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.centerLeft,
          child: Text(label, style: GriTheme.h3()),
        ),
      ),
    );
  }
}

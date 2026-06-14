import 'package:flutter/material.dart';

import '../theme/gri_theme.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GriSpacing.sp8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_outlined, size: 48, color: GriColors.muted),
            const SizedBox(height: GriSpacing.sp4),
            Text('Bağlantı Hatası', style: GriTheme.h1()),
            const SizedBox(height: GriSpacing.sp2),
            Text(
              message,
              style: GriTheme.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GriSpacing.sp6),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: GriColors.primary,
                foregroundColor: GriColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GriRadii.full),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyResultsState extends StatelessWidget {
  const EmptyResultsState({this.hasFilters = false, super.key});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GriSpacing.sp8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 48, color: GriColors.muted),
            const SizedBox(height: GriSpacing.sp4),
            Text('Sonuç Bulunamadı', style: GriTheme.h1()),
            const SizedBox(height: GriSpacing.sp2),
            Text(
              hasFilters
                  ? 'Filtrelerinizi değiştirmeyi deneyin.'
                  : 'Bu kategoride henüz mekan eklenmemiş.',
              style: GriTheme.body(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AiFallbackBanner extends StatelessWidget {
  const AiFallbackBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(GriSpacing.sp4, 0, GriSpacing.sp4, GriSpacing.sp2),
      padding: const EdgeInsets.all(GriSpacing.sp3),
      decoration: BoxDecoration(
        color: GriColors.onPrimary,
        borderRadius: BorderRadius.circular(GriRadii.md),
        border: Border.all(color: GriColors.border),
      ),
      child: Text(
        'Şimdilik kategori seçerek devam edebilirsin.',
        style: GriTheme.caption(),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class AiDiscoverErrorState extends StatelessWidget {
  const AiDiscoverErrorState({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GriSpacing.sp8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 48, color: GriColors.muted),
            const SizedBox(height: GriSpacing.sp4),
            Text('Keşif şu an kullanılamıyor', style: GriTheme.h1()),
            const SizedBox(height: GriSpacing.sp2),
            Text(
              message,
              style: GriTheme.body(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GriSpacing.sp2),
            Text(
              'Şimdilik kategori seçerek devam edebilirsin.',
              style: GriTheme.caption(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: GriSpacing.sp6),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: GriColors.primary,
                foregroundColor: GriColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GriRadii.full),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }
}

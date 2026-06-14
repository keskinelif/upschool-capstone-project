import 'package:flutter/material.dart';

import '../constants/venue_filters.dart';
import '../models/venue.dart';
import '../services/favorites_service.dart';
import '../theme/gri_theme.dart';

class VenueGridCard extends StatelessWidget {
  const VenueGridCard({
    required this.venue,
    this.onTap,
    super.key,
  });

  static const _starColor = Color(0xFFF59E0B);

  final Venue venue;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final favorites = FavoritesService.instance;

    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        final isFavorite = favorites.isFavorite(venue.id);

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(GriRadii.xl),
            child: ClipRRect(
          borderRadius: BorderRadius.circular(GriRadii.xl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(GriRadii.xl),
              border: Border.all(color: GriColors.primary.withValues(alpha: 0.07)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14232529),
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: AspectRatio(
              aspectRatio: 0.72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _VenueImage(imageUrl: venue.galleryImages.isNotEmpty ? venue.galleryImages.first : venue.imageUrl),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x66000000),
                          Color(0x00000000),
                          Color(0x99000000),
                        ],
                        stops: [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: GriSpacing.sp2,
                    right: GriSpacing.sp2,
                    child: _FavoriteStarButton(
                      isFavorite: isFavorite,
                      onTap: () => favorites.toggle(venue.id),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(GriSpacing.sp3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 36),
                          child: Text(
                            venue.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GriTheme.h3().copyWith(
                              color: GriColors.onPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          formatPriceDisplay(venue.priceBand),
                          style: GriTheme.body().copyWith(
                            color: GriColors.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: GriSpacing.sp1),
                        Text(
                          venue.area,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GriTheme.caption().copyWith(
                            color: GriColors.onPrimary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        ),
        );
      },
    );
  }
}

class _FavoriteStarButton extends StatelessWidget {
  const _FavoriteStarButton({
    required this.isFavorite,
    required this.onTap,
  });

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
      child: Material(
        color: GriColors.onPrimary.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              size: 18,
              color: isFavorite ? VenueGridCard._starColor : GriColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _VenueImage extends StatelessWidget {
  const _VenueImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const ColoredBox(
        color: GriColors.border,
        child: Center(
          child: Icon(Icons.storefront_outlined, color: GriColors.muted, size: 32),
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const ColoredBox(
        color: GriColors.border,
        child: Center(
          child: Icon(Icons.broken_image_outlined, color: GriColors.muted, size: 28),
        ),
      ),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const ColoredBox(
          color: GriColors.border,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: GriColors.muted),
            ),
          ),
        );
      },
    );
  }
}

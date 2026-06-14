import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/venue_filters.dart';
import '../models/review.dart';
import '../models/venue.dart';
import '../services/api_client.dart';
import '../services/auth_session.dart';
import '../services/favorites_service.dart';
import '../theme/gri_theme.dart';
import '../utils/maps_url_parser.dart';
import 'login_screen.dart';

class VenueDetailScreen extends StatefulWidget {
  const VenueDetailScreen({
    required this.venue,
    super.key,
  });

  final Venue venue;

  @override
  State<VenueDetailScreen> createState() => _VenueDetailScreenState();
}

class _VenueDetailScreenState extends State<VenueDetailScreen> {
  final ApiClient _api = ApiClient();
  final PageController _galleryController = PageController();
  final TextEditingController _reviewController = TextEditingController();
  final _favorites = FavoritesService.instance;

  bool _isLoadingReviews = true;
  bool _isSubmittingReview = false;
  String? _reviewsError;
  String? _submitError;
  List<Review> _reviews = const [];
  int _galleryIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void dispose() {
    _galleryController.dispose();
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final text = _reviewController.text.trim();
    if (text.length < 3) {
      setState(() => _submitError = 'Yorum en az 3 karakter olmalı.');
      return;
    }

    setState(() {
      _submitError = null;
      _isSubmittingReview = true;
    });

    try {
      await _api.submitReview(venueId: widget.venue.id, text: text);
      if (!mounted) return;
      _reviewController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yorumunuz gönderildi. Admin onayından sonra yayınlanacak.'),
        ),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _submitError = '$err');
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Future<void> _openLogin() async {
    final loggedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const LoginScreen(popOnSuccess: true)),
    );
    if (loggedIn == true && mounted) setState(() => _submitError = null);
  }

  Future<void> _loadReviews() async {
    setState(() {
      _isLoadingReviews = true;
      _reviewsError = null;
    });
    try {
      final reviews = await _api.fetchVenueReviews(widget.venue.id);
      if (!mounted) return;
      setState(() => _reviews = reviews);
    } catch (err) {
      if (!mounted) return;
      setState(() => _reviewsError = '$err');
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _openMaps() async {
    final url = widget.venue.mapsUrl?.isNotEmpty == true
        ? widget.venue.mapsUrl!
        : buildGoogleMapsUrl(lat: widget.venue.lat, lng: widget.venue.lng);
    final uri = Uri.parse(url);
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harita açılamadı')),
      );
    }
  }

  void _goToGalleryImage(int index) {
    if (index < 0 || index >= widget.venue.galleryImages.length) return;
    _galleryController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    setState(() => _galleryIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;
    final images = venue.galleryImages;

    return Scaffold(
      backgroundColor: GriColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            ListenableBuilder(
              listenable: _favorites,
              builder: (context, _) => _DetailHeader(
                isFavorite: _favorites.isFavorite(venue.id),
                onBack: () => Navigator.of(context).pop(),
                onToggleFavorite: () => _favorites.toggle(venue.id),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadReviews,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    GriSpacing.sp4,
                    0,
                    GriSpacing.sp4,
                    GriSpacing.sp8,
                  ),
                  children: [
                    _ImageGallery(
                      images: images,
                      controller: _galleryController,
                      currentIndex: _galleryIndex,
                      onPageChanged: (index) => setState(() => _galleryIndex = index),
                      onPrevious: _galleryIndex > 0
                          ? () => _goToGalleryImage(_galleryIndex - 1)
                          : null,
                      onNext: _galleryIndex < images.length - 1
                          ? () => _goToGalleryImage(_galleryIndex + 1)
                          : null,
                      onDotTap: _goToGalleryImage,
                    ),
                    const SizedBox(height: GriSpacing.sp5),
                    Text(venue.name, style: GriTheme.h1()),
                    const SizedBox(height: GriSpacing.sp2),
                    Row(
                      children: [
                        Text(
                          formatPriceDisplay(venue.priceBand),
                          style: GriTheme.body().copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(width: GriSpacing.sp3),
                        const Icon(Icons.place_outlined, size: 16, color: GriColors.secondary),
                        const SizedBox(width: GriSpacing.sp1),
                        Expanded(
                          child: Text(venue.area, style: GriTheme.caption()),
                        ),
                      ],
                    ),
                    if (venue.description.isNotEmpty) ...[
                      const SizedBox(height: GriSpacing.sp4),
                      Text(venue.description, style: GriTheme.body()),
                    ],
                    const SizedBox(height: GriSpacing.sp5),
                    OutlinedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.map_outlined, size: 18),
                      label: const Text('Google Maps\'te Aç'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GriColors.primary,
                        side: const BorderSide(color: GriColors.primary, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GriRadii.full),
                        ),
                      ),
                    ),
                    const SizedBox(height: GriSpacing.sp8),
                    Text('Yorum Yaz', style: GriTheme.h3()),
                    const SizedBox(height: GriSpacing.sp3),
                    _buildReviewComposer(),
                    const SizedBox(height: GriSpacing.sp8),
                    Text('Yorumlar', style: GriTheme.h3()),
                    const SizedBox(height: GriSpacing.sp3),
                    _buildReviewsSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewComposer() {
    if (!AuthSession.isLoggedIn) {
      return Container(
        padding: const EdgeInsets.all(GriSpacing.sp4),
        decoration: BoxDecoration(
          color: GriColors.onPrimary,
          borderRadius: BorderRadius.circular(GriRadii.lg),
          border: Border.all(color: GriColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yorum yazmak için giriş yapın.',
              style: GriTheme.body(),
            ),
            const SizedBox(height: GriSpacing.sp3),
            FilledButton(
              onPressed: _openLogin,
              style: FilledButton.styleFrom(
                backgroundColor: GriColors.primary,
                foregroundColor: GriColors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GriRadii.full),
                ),
              ),
              child: const Text('Giriş yap'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(GriSpacing.sp4),
      decoration: BoxDecoration(
        color: GriColors.onPrimary,
        borderRadius: BorderRadius.circular(GriRadii.lg),
        border: Border.all(color: GriColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _reviewController,
            maxLines: 4,
            maxLength: 1200,
            decoration: const InputDecoration(
              hintText: 'Deneyiminizi paylaşın...',
              counterText: '',
            ),
            onChanged: (_) {
              if (_submitError != null) setState(() => _submitError = null);
            },
          ),
          const SizedBox(height: GriSpacing.sp2),
          Text(
            'Yorumunuz admin onayından sonra yayınlanır.',
            style: GriTheme.caption(),
          ),
          if (_submitError != null) ...[
            const SizedBox(height: GriSpacing.sp2),
            Text(
              _submitError!,
              style: GriTheme.caption().copyWith(color: GriColors.errorText),
            ),
          ],
          const SizedBox(height: GriSpacing.sp3),
          FilledButton(
            onPressed: _isSubmittingReview ? null : _submitReview,
            style: FilledButton.styleFrom(
              backgroundColor: GriColors.primary,
              foregroundColor: GriColors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GriRadii.full),
              ),
            ),
            child: _isSubmittingReview
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: GriColors.onPrimary,
                    ),
                  )
                : const Text('Yorumu Gönder'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    if (_isLoadingReviews) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: GriSpacing.sp6),
        child: Center(child: CircularProgressIndicator(color: GriColors.muted)),
      );
    }

    if (_reviewsError != null) {
      return Container(
        padding: const EdgeInsets.all(GriSpacing.sp4),
        decoration: BoxDecoration(
          color: GriColors.errorBg,
          borderRadius: BorderRadius.circular(GriRadii.md),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Yorumlar yüklenemedi',
              style: GriTheme.body().copyWith(color: GriColors.errorText),
            ),
            const SizedBox(height: GriSpacing.sp2),
            TextButton(onPressed: _loadReviews, child: const Text('Tekrar dene')),
          ],
        ),
      );
    }

    if (_reviews.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: GriSpacing.sp4),
        child: Text(
          'Henüz onaylı yorum yok.',
          style: GriTheme.caption(),
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < _reviews.length; i++) ...[
          _ReviewCard(review: _reviews[i]),
          if (i < _reviews.length - 1) const SizedBox(height: GriSpacing.sp3),
        ],
      ],
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.isFavorite,
    required this.onBack,
    required this.onToggleFavorite,
  });

  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback onToggleFavorite;

  static const _starColor = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GriSpacing.sp2,
        GriSpacing.sp2,
        GriSpacing.sp2,
        GriSpacing.sp2,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: GriColors.primary,
            tooltip: 'Geri',
          ),
          const Spacer(),
          IconButton(
            onPressed: onToggleFavorite,
            icon: Icon(isFavorite ? Icons.star : Icons.star_border),
            color: isFavorite ? _starColor : GriColors.primary,
            tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
          ),
        ],
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.controller,
    required this.currentIndex,
    required this.onPageChanged,
    this.onPrevious,
    this.onNext,
    this.onDotTap,
  });

  final List<String> images;
  final PageController controller;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final ValueChanged<int>? onDotTap;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(GriRadii.xl),
        child: const AspectRatio(
          aspectRatio: 4 / 3,
          child: ColoredBox(
            color: GriColors.border,
            child: Center(
              child: Icon(Icons.storefront_outlined, color: GriColors.muted, size: 40),
            ),
          ),
        ),
      );
    }

    final hasMultiple = images.length > 1;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(GriRadii.xl),
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                  controller: controller,
                  itemCount: images.length,
                  onPageChanged: onPageChanged,
                  itemBuilder: (_, index) => Image.network(
                    images[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: GriColors.border,
                      child: Center(
                        child: Icon(Icons.broken_image_outlined, color: GriColors.muted),
                      ),
                    ),
                  ),
                ),
                if (hasMultiple) ...[
                  Positioned(
                    left: GriSpacing.sp2,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _GalleryNavButton(
                        icon: Icons.chevron_left,
                        onPressed: onPrevious,
                      ),
                    ),
                  ),
                  Positioned(
                    right: GriSpacing.sp2,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _GalleryNavButton(
                        icon: Icons.chevron_right,
                        onPressed: onNext,
                      ),
                    ),
                  ),
                  Positioned(
                    right: GriSpacing.sp3,
                    bottom: GriSpacing.sp3,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: GriColors.primary.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(GriRadii.full),
                      ),
                      child: Text(
                        '${currentIndex + 1} / ${images.length}',
                        style: GriTheme.caption().copyWith(
                          color: GriColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasMultiple) ...[
          const SizedBox(height: GriSpacing.sp2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (index) {
              final active = index == currentIndex;
              return GestureDetector(
                onTap: onDotTap == null ? null : () => onDotTap!(index),
                child: Container(
                  width: active ? 8 : 6,
                  height: active ? 8 : 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? GriColors.primary : GriColors.border,
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _GalleryNavButton extends StatelessWidget {
  const _GalleryNavButton({
    required this.icon,
    required this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: GriColors.onPrimary.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: onPressed == null ? GriColors.muted : GriColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GriSpacing.sp4),
      decoration: BoxDecoration(
        color: GriColors.onPrimary,
        borderRadius: BorderRadius.circular(GriRadii.lg),
        border: Border.all(color: GriColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: GriColors.primary,
                child: Text(
                  review.displayName.isNotEmpty
                      ? review.displayName.substring(0, 1).toUpperCase()
                      : '?',
                  style: GriTheme.caption().copyWith(
                    color: GriColors.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: GriSpacing.sp2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.displayName, style: GriTheme.h3().copyWith(fontSize: 14)),
                    Text(_formatReviewDate(review.createdAt), style: GriTheme.caption()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GriSpacing.sp3),
          Text(review.text, style: GriTheme.body()),
        ],
      ),
    );
  }

  String _formatReviewDate(DateTime date) {
    final now = DateTime.now();
    final local = date.toLocal();
    final diff = now.difference(local);
    if (diff.inDays <= 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${local.day}.${local.month}.${local.year}';
  }
}

void openVenueDetail(BuildContext context, Venue venue) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => VenueDetailScreen(venue: venue),
    ),
  );
}

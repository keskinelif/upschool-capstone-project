import 'package:flutter/material.dart';

import '../constants/venue_filters.dart';
import '../models/review.dart';
import '../models/tag.dart';
import '../models/venue.dart';
import '../services/api_client.dart';
import '../services/auth_exception.dart';
import '../services/auth_session.dart';
import '../theme/gri_theme.dart';
import 'admin_add_venue_screen.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  final ApiClient _api = ApiClient();
  late final TabController _tabController;

  bool _isLoading = true;
  String? _error;
  List<Venue> _venues = const [];
  List<PendingReview> _pendingReviews = const [];
  Map<String, String> _tagNames = const {};
  String? _decidingReviewId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _api.fetchAllVenues(),
        _api.fetchTags(),
        _api.fetchPendingReviews(),
      ]);
      if (!mounted) return;
      final tags = results[1] as List<Tag>;
      setState(() {
        _venues = results[0] as List<Venue>;
        _pendingReviews = results[2] as List<PendingReview>;
        _tagNames = {for (final tag in tags) tag.id: tag.name};
        _isLoading = false;
      });
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() {
        _error = err.message;
        _isLoading = false;
      });
    } catch (err) {
      if (!mounted) return;
      setState(() {
        _error = '$err';
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddVenue() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AdminAddVenueScreen()),
    );
    if (saved == true) _load();
  }

  Future<void> _openEditVenue(Venue venue) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => AdminAddVenueScreen(venue: venue)),
    );
    if (saved == true) _load();
  }

  Future<void> _decideReview(PendingReview review, String status) async {
    setState(() => _decidingReviewId = review.id);
    try {
      await _api.decideReview(reviewId: review.id, status: status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved' ? 'Yorum onaylandı.' : 'Yorum reddedildi.',
          ),
        ),
      );
      await _load();
    } on AuthException catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.message)));
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
    } finally {
      if (mounted) setState(() => _decidingReviewId = null);
    }
  }

  void _logout() {
    AuthSession.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  String _categoryLabel(Venue venue) {
    final names = venue.tagIds
        .map((id) => _tagNames[id])
        .whereType<String>()
        .toList();
    if (names.isEmpty) return 'Kategori yok';
    return names.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GriSpacing.sp6,
                GriSpacing.sp4,
                GriSpacing.sp6,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Admin Panel', style: GriTheme.displayTitle()),
                  const SizedBox(height: GriSpacing.sp2),
                  Text('Mekan ve içerik yönetimi', style: GriTheme.caption()),
                  const SizedBox(height: GriSpacing.sp5),
                  TabBar(
                    controller: _tabController,
                    labelColor: GriColors.primary,
                    unselectedLabelColor: GriColors.muted,
                    indicatorColor: GriColors.primary,
                    labelStyle: GriTheme.body().copyWith(fontWeight: FontWeight.w600),
                    unselectedLabelStyle: GriTheme.body(),
                    tabs: [
                      const Tab(text: 'Mekanlar'),
                      Tab(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Yorumlar'),
                            if (_pendingReviews.isNotEmpty) ...[
                              const SizedBox(width: GriSpacing.sp2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: GriColors.primary,
                                  borderRadius: BorderRadius.circular(GriRadii.full),
                                ),
                                child: Text(
                                  '${_pendingReviews.length}',
                                  style: GriTheme.caption().copyWith(
                                    color: GriColors.onPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GriSpacing.sp3),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildVenuesTab(),
                  _buildReviewsTab(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(GriSpacing.sp6),
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: GriColors.secondary,
                  side: const BorderSide(color: GriColors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GriRadii.full),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: const Text('Çıkış Yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVenuesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GriSpacing.sp6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.icon(
                onPressed: _openAddVenue,
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Mekan Ekle'),
                style: FilledButton.styleFrom(
                  backgroundColor: GriColors.primary,
                  foregroundColor: GriColors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GriRadii.full),
                  ),
                ),
              ),
              const SizedBox(height: GriSpacing.sp5),
              Text(
                'Mekanlar (${_isLoading ? '...' : _venues.length})',
                style: GriTheme.h1(),
              ),
            ],
          ),
        ),
        const SizedBox(height: GriSpacing.sp3),
        Expanded(child: _buildVenuesBody()),
      ],
    );
  }

  Widget _buildReviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: GriSpacing.sp6),
          child: Text(
            'Bekleyen Yorumlar (${_isLoading ? '...' : _pendingReviews.length})',
            style: GriTheme.h1(),
          ),
        ),
        const SizedBox(height: GriSpacing.sp3),
        Expanded(child: _buildReviewsBody()),
      ],
    );
  }

  Widget _buildVenuesBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: GriColors.muted));
    }

    if (_error != null) {
      return _ErrorPane(message: _error!, onRetry: _load);
    }

    if (_venues.isEmpty) {
      return const Center(child: Text('Henüz mekan eklenmemiş.'));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: GriSpacing.sp6),
        itemCount: _venues.length,
        separatorBuilder: (_, __) => const SizedBox(height: GriSpacing.sp3),
        itemBuilder: (_, index) {
          final venue = _venues[index];
          return _AdminVenueTile(
            venue: venue,
            categoryLabel: _categoryLabel(venue),
            onTap: () => _openEditVenue(venue),
          );
        },
      ),
    );
  }

  Widget _buildReviewsBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: GriColors.muted));
    }

    if (_error != null) {
      return _ErrorPane(message: _error!, onRetry: _load);
    }

    if (_pendingReviews.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(GriSpacing.sp6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 48, color: GriColors.muted),
              const SizedBox(height: GriSpacing.sp4),
              Text(
                'Onay bekleyen yorum yok.',
                style: GriTheme.body(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: GriSpacing.sp6),
        itemCount: _pendingReviews.length,
        separatorBuilder: (_, __) => const SizedBox(height: GriSpacing.sp3),
        itemBuilder: (_, index) {
          final review = _pendingReviews[index];
          return _PendingReviewTile(
            review: review,
            isDeciding: _decidingReviewId == review.id,
            onApprove: () => _decideReview(review, 'approved'),
            onReject: () => _decideReview(review, 'rejected'),
          );
        },
      ),
    );
  }
}

class _ErrorPane extends StatelessWidget {
  const _ErrorPane({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GriSpacing.sp6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message, style: GriTheme.body(), textAlign: TextAlign.center),
            const SizedBox(height: GriSpacing.sp4),
            FilledButton(onPressed: onRetry, child: const Text('Tekrar dene')),
          ],
        ),
      ),
    );
  }
}

class _PendingReviewTile extends StatelessWidget {
  const _PendingReviewTile({
    required this.review,
    required this.isDeciding,
    required this.onApprove,
    required this.onReject,
  });

  final PendingReview review;
  final bool isDeciding;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GriSpacing.sp4),
      decoration: BoxDecoration(
        color: GriColors.onPrimary,
        borderRadius: BorderRadius.circular(GriRadii.lg),
        border: Border.all(color: GriColors.primary.withValues(alpha: 0.07)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14232529),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(review.venueName, style: GriTheme.h3()),
          const SizedBox(height: GriSpacing.sp1),
          Text(
            '${review.displayName} (@${review.username})',
            style: GriTheme.caption(),
          ),
          const SizedBox(height: GriSpacing.sp3),
          Text(review.text, style: GriTheme.body()),
          const SizedBox(height: GriSpacing.sp4),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isDeciding ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: GriColors.errorText,
                    side: const BorderSide(color: GriColors.errorText, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GriRadii.full),
                    ),
                  ),
                  child: const Text('Reddet'),
                ),
              ),
              const SizedBox(width: GriSpacing.sp3),
              Expanded(
                child: FilledButton(
                  onPressed: isDeciding ? null : onApprove,
                  style: FilledButton.styleFrom(
                    backgroundColor: GriColors.primary,
                    foregroundColor: GriColors.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GriRadii.full),
                    ),
                  ),
                  child: isDeciding
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GriColors.onPrimary,
                          ),
                        )
                      : const Text('Onayla'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminVenueTile extends StatelessWidget {
  const _AdminVenueTile({
    required this.venue,
    required this.categoryLabel,
    required this.onTap,
  });

  final Venue venue;
  final String categoryLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final thumbUrl = venue.galleryImages.isNotEmpty ? venue.galleryImages.first : venue.imageUrl;

    return Material(
      color: GriColors.onPrimary,
      borderRadius: BorderRadius.circular(GriRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GriRadii.lg),
        child: Container(
          padding: const EdgeInsets.all(GriSpacing.sp4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GriRadii.lg),
            border: Border.all(color: GriColors.primary.withValues(alpha: 0.07)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14232529),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _VenueThumbnail(imageUrl: thumbUrl),
              const SizedBox(width: GriSpacing.sp3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venue.name,
                      style: GriTheme.h3(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: GriSpacing.sp1),
                    Text(
                      '${venue.area} · ${formatPriceDisplay(venue.priceBand)}',
                      style: GriTheme.caption(),
                    ),
                    const SizedBox(height: GriSpacing.sp1),
                    Text(
                      categoryLabel,
                      style: GriTheme.caption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: GriColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class _VenueThumbnail extends StatelessWidget {
  const _VenueThumbnail({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(GriRadii.md),
      child: SizedBox(
        width: 56,
        height: 56,
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const _PlaceholderThumb(),
              )
            : const _PlaceholderThumb(),
      ),
    );
  }
}

class _PlaceholderThumb extends StatelessWidget {
  const _PlaceholderThumb();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: GriColors.border,
      child: Center(
        child: Icon(Icons.storefront_outlined, color: GriColors.muted, size: 22),
      ),
    );
  }
}

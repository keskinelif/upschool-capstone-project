import 'package:flutter/material.dart';

import '../constants/venue_filters.dart';
import '../models/tag.dart';
import '../models/venue.dart';
import '../services/api_client.dart';
import '../services/auth_session.dart';
import '../theme/gri_theme.dart';
import 'admin_add_venue_screen.dart';
import 'login_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final ApiClient _api = ApiClient();
  bool _isLoading = true;
  String? _error;
  List<Venue> _venues = const [];
  Map<String, String> _tagNames = const {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([_api.fetchAllVenues(), _api.fetchTags()]);
      if (!mounted) return;
      final tags = results[1] as List<Tag>;
      setState(() {
        _venues = results[0] as List<Venue>;
        _tagNames = {for (final tag in tags) tag.id: tag.name};
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
                  const SizedBox(height: GriSpacing.sp6),
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
                  const SizedBox(height: GriSpacing.sp6),
                  Text(
                    'Mekanlar (${_isLoading ? '...' : _venues.length})',
                    style: GriTheme.h1(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GriSpacing.sp3),
            Expanded(child: _buildBody()),
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

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: GriColors.muted));
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(GriSpacing.sp6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: GriTheme.body(), textAlign: TextAlign.center),
              const SizedBox(height: GriSpacing.sp4),
              FilledButton(
                onPressed: _load,
                child: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      );
    }

    if (_venues.isEmpty) {
      return Center(
        child: Text(
          'Henüz mekan eklenmemiş.',
          style: GriTheme.body(),
        ),
      );
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
              _VenueThumbnail(imageUrl: venue.imageUrl),
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

import 'package:flutter/material.dart';

import '../models/venue.dart';
import '../services/api_client.dart';
import '../services/favorites_service.dart';
import '../theme/gri_theme.dart';
import '../widgets/venue_grid_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiClient _api = ApiClient();
  final _favorites = FavoritesService.instance;
  bool _isLoading = true;
  List<Venue> _venues = const [];

  @override
  void initState() {
    super.initState();
    _favorites.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _favorites.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final ids = _favorites.venueIds;
    if (ids.isEmpty) {
      if (mounted) {
        setState(() {
          _venues = const [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final allVenues = await _api.fetchAllVenues();
      if (!mounted) return;
      setState(() {
        _venues = allVenues.where((venue) => ids.contains(venue.id)).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: GriColors.muted));
    }

    if (_venues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(GriSpacing.sp6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.star_border, size: 48, color: GriColors.muted),
              const SizedBox(height: GriSpacing.sp4),
              Text('Favoriler', style: GriTheme.h1()),
              const SizedBox(height: GriSpacing.sp2),
              Text(
                'Henüz favori mekanınız yok.',
                style: GriTheme.body(),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(GriSpacing.sp4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: GriSpacing.sp3,
        crossAxisSpacing: GriSpacing.sp3,
        childAspectRatio: 0.72,
      ),
      itemCount: _venues.length,
      itemBuilder: (_, index) => VenueGridCard(venue: _venues[index]),
    );
  }
}

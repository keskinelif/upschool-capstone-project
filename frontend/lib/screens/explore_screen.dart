import 'package:flutter/material.dart';

import '../models/venue.dart';
import '../services/api_client.dart';
import '../widgets/filter_bar.dart';
import '../widgets/venue_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final ApiClient _api = ApiClient();
  String _location = FilterBar.locations.first;
  String _product = FilterBar.products.first;
  String _vibe = FilterBar.vibes.first;
  bool _isLoading = true;
  String? _error;
  List<Venue> _venues = const [];

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
      final venues = await _api.fetchVenues(
        location: _location,
        productTag: _product,
        vibeTag: _vibe,
      );
      if (!mounted) return;
      setState(() => _venues = venues);
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = '$err');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('gri. keşfet')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilterBar(
              location: _location,
              product: _product,
              vibe: _vibe,
              onLocationChanged: (value) {
                setState(() => _location = value);
                _load();
              },
              onProductChanged: (value) {
                setState(() => _product = value);
                _load();
              },
              onVibeChanged: (value) {
                setState(() => _vibe = value);
                _load();
              },
            ),
            const SizedBox(height: 16),
            if (_isLoading) const LinearProgressIndicator(),
            if (_error != null)
              SelectableText.rich(
                TextSpan(
                  text: 'Hata: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (!_isLoading && _error == null && _venues.isEmpty)
              const Text('Sonuç bulunamadı. Farklı filtre deneyin.'),
            ..._venues.map((venue) => VenueCard(venue: venue)),
          ],
        ),
      ),
    );
  }
}

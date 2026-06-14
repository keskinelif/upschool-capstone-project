import 'package:flutter/material.dart';

import '../constants/venue_filters.dart';
import '../models/venue.dart';
import '../services/api_client.dart';
import '../screens/venue_detail_screen.dart';
import '../theme/gri_theme.dart';
import '../widgets/status_states.dart';
import '../widgets/venue_filter_sheet.dart';
import '../widgets/venue_grid_card.dart';
import '../widgets/venue_grid_skeleton.dart';

class CategoryVenuesScreen extends StatefulWidget {
  const CategoryVenuesScreen({
    required this.category,
    super.key,
  });

  final String category;

  @override
  State<CategoryVenuesScreen> createState() => _CategoryVenuesScreenState();
}

class _CategoryVenuesScreenState extends State<CategoryVenuesScreen> {
  final ApiClient _api = ApiClient();
  bool _isLoading = true;
  String? _error;
  List<Venue> _venues = const [];
  String? _locationFilter;
  String? _priceFilter;

  bool get _hasActiveFilters =>
      _locationFilter != null || _priceFilter != null;

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
      final venues = await _api.fetchVenuesForCategory(
        widget.category,
        location: _locationFilter,
        priceBand: _priceFilter == null ? null : priceLevelToApiBand(_priceFilter!),
      );
      if (!mounted) return;

      final filtered = _priceFilter == null
          ? venues
          : venues
              .where((venue) => venueMatchesPriceFilter(venue.priceBand, _priceFilter))
              .toList();

      setState(() => _venues = filtered);
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = '$err');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openFilters() async {
    await VenueFilterSheet.show(
      context,
      initialLocation: _locationFilter,
      initialPrice: _priceFilter,
      onApply: ({String? location, String? price}) {
        setState(() {
          _locationFilter = location;
          _priceFilter = price;
        });
        _load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GriColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            _CategoryHeader(
              title: widget.category,
              hasActiveFilters: _hasActiveFilters,
              onBack: () => Navigator.of(context).pop(),
              onFilter: _openFilters,
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const VenueGridSkeleton();

    if (_error != null) {
      return ErrorState(message: _error!, onRetry: _load);
    }

    if (_venues.isEmpty) {
      return EmptyResultsState(hasFilters: _hasActiveFilters);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(
          GriSpacing.sp4,
          GriSpacing.sp2,
          GriSpacing.sp4,
          GriSpacing.sp6,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: GriSpacing.sp3,
          crossAxisSpacing: GriSpacing.sp3,
          childAspectRatio: 0.72,
        ),
        itemCount: _venues.length,
        itemBuilder: (_, index) => VenueGridCard(
          venue: _venues[index],
          onTap: () => openVenueDetail(context, _venues[index]),
        ),
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.title,
    required this.hasActiveFilters,
    required this.onBack,
    required this.onFilter,
  });

  final String title;
  final bool hasActiveFilters;
  final VoidCallback onBack;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GriSpacing.sp2,
        GriSpacing.sp2,
        GriSpacing.sp2,
        GriSpacing.sp4,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            color: GriColors.primary,
            tooltip: 'Geri',
          ),
          Expanded(
            child: Text(
              title,
              style: GriTheme.h1(),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: onFilter,
            icon: Badge(
              isLabelVisible: hasActiveFilters,
              smallSize: 8,
              backgroundColor: GriColors.primary,
              child: const Icon(Icons.filter_list),
            ),
            color: GriColors.primary,
            tooltip: 'Filtrele',
          ),
        ],
      ),
    );
  }
}

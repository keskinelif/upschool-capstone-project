import 'package:flutter/material.dart';

import '../models/ai_discover_result.dart';
import '../services/api_client.dart';
import '../theme/gri_theme.dart';
import '../widgets/status_states.dart';
import '../widgets/venue_grid_card.dart';
import '../widgets/venue_grid_skeleton.dart';

class AiDiscoverScreen extends StatefulWidget {
  const AiDiscoverScreen({
    required this.query,
    super.key,
  });

  final String query;

  @override
  State<AiDiscoverScreen> createState() => _AiDiscoverScreenState();
}

class _AiDiscoverScreenState extends State<AiDiscoverScreen> {
  final ApiClient _api = ApiClient();
  bool _isLoading = true;
  String? _error;
  AiDiscoverResult? _result;

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
      final result = await _api.discoverWithAi(widget.query);
      if (!mounted) return;
      setState(() => _result = result);
    } catch (err) {
      if (!mounted) return;
      setState(() => _error = '$err');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _result?.summary.isNotEmpty == true ? _result!.summary : widget.query;

    return Scaffold(
      backgroundColor: GriColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                GriSpacing.sp2,
                GriSpacing.sp2,
                GriSpacing.sp2,
                GriSpacing.sp4,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: GriColors.primary,
                    tooltip: 'Geri',
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: GriTheme.h1(),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
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
      return AiDiscoverErrorState(message: _error!, onRetry: _load);
    }

    final result = _result;
    if (result == null) {
      return const EmptyResultsState();
    }

    if (result.venues.isEmpty) {
      return Column(
        children: [
          if (result.usedFallback) const AiFallbackBanner(),
          const Expanded(child: EmptyResultsState()),
        ],
      );
    }

    return Expanded(
          child: RefreshIndicator(
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
              itemCount: result.venues.length,
              itemBuilder: (_, index) => VenueGridCard(venue: result.venues[index]),
        ),
      ),
    );
  }
}

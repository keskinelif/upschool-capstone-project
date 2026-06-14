import 'package:flutter/material.dart';

import '../constants/categories.dart';
import '../theme/gri_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/discover_search_bar.dart';
import '../widgets/home_bottom_nav.dart';
import 'ai_discover_screen.dart';
import 'category_venues_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  HomeNavTab? _activeTab;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCategory(String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryVenuesScreen(category: category),
      ),
    );
  }

  Future<void> _submitSearch() async {
    final query = _searchController.text.trim();
    if (query.length < 2 || _isSearching) return;

    setState(() => _isSearching = true);
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AiDiscoverScreen(query: query),
      ),
    );
    if (mounted) setState(() => _isSearching = false);
  }

  void _onTabChanged(HomeNavTab tab) {
    setState(() => _activeTab = tab);
  }

  void _goHome() {
    setState(() => _activeTab = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _activeTab == null ? _buildHomeContent() : _buildTabContent(),
      ),
      bottomNavigationBar: HomeBottomNav(
        activeTab: _activeTab,
        onTabChanged: _onTabChanged,
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        GriSpacing.sp6,
        GriSpacing.sp8,
        GriSpacing.sp6,
        GriSpacing.sp4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bugün ne yapmak istiyorsun?',
            style: GriTheme.h1(),
          ),
          const SizedBox(height: GriSpacing.sp4),
          DiscoverSearchBar(
            controller: _searchController,
            onSubmit: _submitSearch,
            isLoading: _isSearching,
          ),
          const SizedBox(height: GriSpacing.sp8),
          ...Categories.all.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: GriSpacing.sp3),
              child: CategoryCard(
                label: category,
                onTap: () => _openCategory(category),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              GriSpacing.sp4,
              GriSpacing.sp2,
              GriSpacing.sp4,
              0,
            ),
            child: IconButton(
              onPressed: _goHome,
              icon: const Icon(Icons.arrow_back),
              color: GriColors.primary,
              tooltip: 'Ana sayfa',
            ),
          ),
        ),
        Expanded(
          child: switch (_activeTab) {
            HomeNavTab.favorites => const FavoritesScreen(),
            HomeNavTab.profile => const ProfileScreen(),
            null => const SizedBox.shrink(),
          },
        ),
      ],
    );
  }
}

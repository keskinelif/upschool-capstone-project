import 'package:flutter/foundation.dart';

class FavoritesService extends ChangeNotifier {
  FavoritesService._();

  static final FavoritesService instance = FavoritesService._();

  final Set<String> _venueIds = {};

  bool isFavorite(String venueId) => _venueIds.contains(venueId);

  void toggle(String venueId) {
    if (_venueIds.contains(venueId)) {
      _venueIds.remove(venueId);
    } else {
      _venueIds.add(venueId);
    }
    notifyListeners();
  }

  Set<String> get venueIds => Set.unmodifiable(_venueIds);
}

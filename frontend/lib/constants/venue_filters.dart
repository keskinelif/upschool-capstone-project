abstract final class VenueFilters {
  static const locations = ['Tunalı', 'Bahçelievler'];
  static const priceLevels = ['₺', '₺₺', '₺₺₺'];
}

String formatPriceDisplay(String priceBand) {
  if (VenueFilters.priceLevels.contains(priceBand)) {
    return priceBand;
  }
  return '₺₺';
}

String? priceLevelToApiBand(String displayLevel) {
  if (VenueFilters.priceLevels.contains(displayLevel)) {
    return displayLevel;
  }
  return null;
}

bool venueMatchesPriceFilter(String priceBand, String? selectedPrice) {
  if (selectedPrice == null) return true;
  return priceBand == selectedPrice;
}

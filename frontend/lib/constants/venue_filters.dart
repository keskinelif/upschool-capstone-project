abstract final class VenueFilters {
  static const locations = ['Tunalı', 'Bahçelievler'];
  static const priceLevels = [r'$', r'$$', r'$$$', r'$$$$', r'$$$$$'];
}

String formatPriceDisplay(String priceBand) {
  switch (priceBand) {
    case '₺':
      return r'$';
    case '₺₺':
      return r'$$$';
    case '₺₺₺':
      return r'$$$$$';
    default:
      return r'$$$';
  }
}

String? priceLevelToApiBand(String displayLevel) {
  switch (displayLevel) {
    case r'$':
      return '₺';
    case r'$$$':
      return '₺₺';
    case r'$$$$$':
      return '₺₺₺';
    default:
      return null;
  }
}

bool venueMatchesPriceFilter(String priceBand, String? selectedPrice) {
  if (selectedPrice == null) return true;
  return formatPriceDisplay(priceBand) == selectedPrice;
}

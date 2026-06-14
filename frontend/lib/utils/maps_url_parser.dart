class MapsCoordinates {
  const MapsCoordinates({required this.lat, required this.lng});

  final double lat;
  final double lng;
}

String buildGoogleMapsUrl({required double lat, required double lng}) {
  return 'https://www.google.com/maps?q=$lat,$lng';
}

MapsCoordinates? parseGoogleMapsUrl(String rawUrl) {
  final url = rawUrl.trim();
  if (url.isEmpty) return null;

  final patterns = <RegExp>[
    RegExp(r'@(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)'),
    RegExp(r'[?&]q=(-?\d+(?:\.\d+)?)[,%2C+%20](-?\d+(?:\.\d+)?)', caseSensitive: false),
    RegExp(r'[?&]ll=(-?\d+(?:\.\d+)?),(-?\d+(?:\.\d+)?)', caseSensitive: false),
    RegExp(r'!3d(-?\d+(?:\.\d+)?)!4d(-?\d+(?:\.\d+)?)', caseSensitive: false),
    RegExp(r'center=(-?\d+(?:\.\d+)?)[,%2C](-?\d+(?:\.\d+)?)', caseSensitive: false),
  ];

  for (final pattern in patterns) {
    final match = pattern.firstMatch(url);
    if (match == null) continue;
    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat == null || lng == null) continue;
    if (lat.abs() > 90 || lng.abs() > 180) continue;
    return MapsCoordinates(lat: lat, lng: lng);
  }

  return null;
}

String? validateGoogleMapsUrl(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Google Maps linki gerekli';
  }

  final url = value.trim().toLowerCase();
  final isMapsHost = url.contains('google.com/maps') ||
      url.contains('maps.google.') ||
      url.contains('goo.gl/maps') ||
      url.contains('maps.app.goo.gl');

  if (!isMapsHost) {
    return 'Geçerli bir Google Maps linki girin';
  }

  if (parseGoogleMapsUrl(value) == null) {
    return 'Linkten konum okunamadı. Tam Google Maps linki yapıştırın.';
  }

  return null;
}

import '../models/venue.dart';

class AiDiscoverResult {
  const AiDiscoverResult({
    required this.summary,
    required this.venues,
    required this.usedFallback,
    required this.query,
  });

  final String summary;
  final List<Venue> venues;
  final bool usedFallback;
  final String query;

  factory AiDiscoverResult.fromJson(Map<String, dynamic> json, String query) {
    final venuesJson = json['venues'] as List<dynamic>? ?? const [];
    return AiDiscoverResult(
      summary: json['summary'] as String? ?? '',
      venues: venuesJson
          .map((item) => Venue.fromJson(item as Map<String, dynamic>))
          .toList(),
      usedFallback: json['used_fallback'] as bool? ?? false,
      query: query,
    );
  }
}

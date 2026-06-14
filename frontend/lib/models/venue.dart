class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.area,
    required this.priceBand,
    required this.lat,
    required this.lng,
    required this.description,
    required this.tagIds,
    this.imageUrl,
    this.mapsUrl,
  });

  final String id;
  final String name;
  final String area;
  final String priceBand;
  final double lat;
  final double lng;
  final String description;
  final List<String> tagIds;
  final String? imageUrl;
  final String? mapsUrl;

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as String,
        name: json['name'] as String,
        area: json['area'] as String,
        priceBand: json['price_band'] as String,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        description: json['description'] as String? ?? '',
        tagIds: (json['tag_ids'] as List<dynamic>? ?? const [])
            .map((id) => id as String)
            .toList(),
        imageUrl: json['image_url'] as String?,
        mapsUrl: json['maps_url'] as String?,
      );
}

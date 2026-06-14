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
    this.imageUrls = const [],
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
  final List<String> imageUrls;
  final String? mapsUrl;

  List<String> get galleryImages {
    if (imageUrls.isNotEmpty) return imageUrls;
    if (imageUrl != null && imageUrl!.isNotEmpty) return [imageUrl!];
    return const [];
  }

  factory Venue.fromJson(Map<String, dynamic> json) {
    final urls = (json['image_urls'] as List<dynamic>? ?? const [])
        .map((url) => url as String)
        .where((url) => url.isNotEmpty)
        .toList();
    final primary = json['image_url'] as String?;

    return Venue(
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
      imageUrl: primary,
      imageUrls: urls.isNotEmpty
          ? urls
          : primary != null && primary.isNotEmpty
              ? [primary]
              : const [],
      mapsUrl: json['maps_url'] as String?,
    );
  }
}

class Venue {
  const Venue({
    required this.id,
    required this.name,
    required this.area,
    required this.priceBand,
  });

  final String id;
  final String name;
  final String area;
  final String priceBand;

  factory Venue.fromJson(Map<String, dynamic> json) => Venue(
        id: json['id'] as String,
        name: json['name'] as String,
        area: json['area'] as String,
        priceBand: json['price_band'] as String,
      );
}

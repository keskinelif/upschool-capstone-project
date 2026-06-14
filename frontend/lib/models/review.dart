class Review {
  const Review({
    required this.id,
    required this.venueId,
    required this.userId,
    required this.username,
    required this.displayName,
    required this.text,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String venueId;
  final String userId;
  final String username;
  final String displayName;
  final String text;
  final String status;
  final DateTime createdAt;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        venueId: json['venue_id'] as String,
        userId: json['user_id'] as String,
        username: json['username'] as String,
        displayName: json['display_name'] as String,
        text: json['text'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class PendingReview extends Review {
  const PendingReview({
    required super.id,
    required super.venueId,
    required super.userId,
    required super.username,
    required super.displayName,
    required super.text,
    required super.status,
    required super.createdAt,
    required this.venueName,
  });

  final String venueName;

  factory PendingReview.fromJson(Map<String, dynamic> json) => PendingReview(
        id: json['id'] as String,
        venueId: json['venue_id'] as String,
        userId: json['user_id'] as String,
        username: json['username'] as String,
        displayName: json['display_name'] as String,
        text: json['text'] as String,
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        venueName: json['venue_name'] as String,
      );
}

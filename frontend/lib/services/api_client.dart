import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/ai_discover_result.dart';
import '../models/auth_tokens.dart';
import '../models/review.dart';
import '../models/tag.dart';
import '../models/venue.dart';
import 'auth_exception.dart';
import 'auth_session.dart';

class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:8000',
        );

  final http.Client _client;
  final String _baseUrl;

  Map<String, String> get _authHeaders {
    final token = AuthSession.tokens?.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<AuthTokens> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 401) {
      throw AuthException('Şifre geçersiz');
    }
    if (response.statusCode == 422) {
      throw AuthException('E-posta ve şifre gerekli');
    }
    if (response.statusCode != 200) {
      throw Exception('Giriş başarısız: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AuthTokens.fromJson(data);
  }

  Future<String> register({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl/auth/register');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim().toLowerCase(),
        'password': password,
      }),
    );

    if (response.statusCode == 409) {
      throw AuthException('Bu kullanıcı adı zaten alınmış');
    }
    if (response.statusCode == 400) {
      throw AuthException('Bu kullanıcı adı rezerve edilmiş');
    }
    if (response.statusCode == 422) {
      throw AuthException('Kullanıcı adı veya şifre geçersiz');
    }
    if (response.statusCode != 201) {
      throw Exception('Kayıt başarısız: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data['username'] as String;
  }

  Future<List<Tag>> fetchTags() async {
    final response = await _client.get(Uri.parse('$_baseUrl/tags'));
    if (response.statusCode != 200) {
      throw Exception('Etiketler yüklenemedi: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Tag.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Venue> createVenue({
    required String name,
    required String area,
    required double lat,
    required double lng,
    required String description,
    required List<String> tagIds,
    required String priceBand,
    String? imageUrl,
    List<String> imageUrls = const [],
    required String mapsUrl,
  }) async {
    final urls = _buildImageUrls(imageUrl: imageUrl, imageUrls: imageUrls);
    final response = await _client.post(
      Uri.parse('$_baseUrl/venues'),
      headers: _authHeaders,
      body: jsonEncode({
        'name': name,
        'area': area,
        'lat': lat,
        'lng': lng,
        'description': description,
        'tag_ids': tagIds,
        'price_band': priceBand,
        if (urls.isNotEmpty) 'image_urls': urls,
        if (urls.isNotEmpty) 'image_url': urls.first,
        'maps_url': mapsUrl,
      }),
    );

    if (response.statusCode == 401) {
      throw AuthException('Oturum süresi doldu');
    }
    if (response.statusCode == 403) {
      throw AuthException('Admin yetkisi gerekli');
    }
    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception('Mekan eklenemedi: ${response.statusCode} $body');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Venue.fromJson(data);
  }

  Future<Venue> updateVenue({
    required String venueId,
    required String name,
    required String area,
    required double lat,
    required double lng,
    required String description,
    required List<String> tagIds,
    required String priceBand,
    String? imageUrl,
    List<String> imageUrls = const [],
    required String mapsUrl,
  }) async {
    final urls = _buildImageUrls(imageUrl: imageUrl, imageUrls: imageUrls);
    final response = await _client.patch(
      Uri.parse('$_baseUrl/venues/$venueId'),
      headers: _authHeaders,
      body: jsonEncode({
        'name': name,
        'area': area,
        'lat': lat,
        'lng': lng,
        'description': description,
        'tag_ids': tagIds,
        'price_band': priceBand,
        'image_urls': urls,
        'image_url': urls.isNotEmpty ? urls.first : null,
        'maps_url': mapsUrl,
      }),
    );

    if (response.statusCode == 401) {
      throw AuthException('Oturum süresi doldu');
    }
    if (response.statusCode == 403) {
      throw AuthException('Admin yetkisi gerekli');
    }
    if (response.statusCode == 404) {
      throw Exception('Mekan bulunamadı');
    }
    if (response.statusCode != 200) {
      final body = response.body;
      throw Exception('Mekan güncellenemedi: ${response.statusCode} $body');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Venue.fromJson(data);
  }

  Future<List<Venue>> fetchVenues({
    required String location,
    required String productTag,
    required String vibeTag,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/venues?location=$location&product_tags=$productTag&vibe_tags=$vibeTag',
    );
    return _parseVenueList(await _client.get(uri));
  }

  Future<List<Venue>> fetchAllVenues() async {
    final uri = Uri.parse('$_baseUrl/venues');
    return _parseVenueList(await _client.get(uri));
  }

  Future<List<Venue>> fetchVenuesForCategory(
    String category, {
    String? location,
    String? priceBand,
  }) async {
    final params = <String, String>{'product_tags': category};
    if (location != null) params['location'] = location;
    if (priceBand != null) params['price_band'] = priceBand;

    final uri = Uri.parse('$_baseUrl/venues').replace(queryParameters: params);
    return _parseVenueList(await _client.get(uri));
  }

  Future<List<Venue>> _parseVenueList(http.Response response) async {
    if (response.statusCode != 200) {
      throw Exception('Failed to load venues: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Venue.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AiDiscoverResult> discoverWithAi(String query) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/ai/discover'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 422) {
      throw Exception('Lütfen daha açıklayıcı bir arama yazın.');
    }
    if (response.statusCode != 200) {
      throw Exception('Keşif isteği başarısız: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return AiDiscoverResult.fromJson(data, query);
  }

  Future<List<Review>> fetchVenueReviews(String venueId) async {
    final response = await _client.get(Uri.parse('$_baseUrl/reviews/venue/$venueId'));
    if (response.statusCode == 404) {
      throw Exception('Mekan bulunamadı');
    }
    if (response.statusCode != 200) {
      throw Exception('Yorumlar yüklenemedi: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Review.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Review> submitReview({
    required String venueId,
    required String text,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/reviews'),
      headers: _authHeaders,
      body: jsonEncode({
        'venue_id': venueId,
        'text': text.trim(),
      }),
    );

    if (response.statusCode == 401) {
      throw AuthException('Giriş yapmanız gerekiyor');
    }
    if (response.statusCode == 404) {
      throw Exception('Mekan bulunamadı');
    }
    if (response.statusCode == 422) {
      throw Exception('Yorum en az 3 karakter olmalı');
    }
    if (response.statusCode != 201) {
      throw Exception('Yorum gönderilemedi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Review.fromJson(data);
  }

  Future<List<PendingReview>> fetchPendingReviews() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/admin/reviews/pending'),
      headers: _authHeaders,
    );

    if (response.statusCode == 401) {
      throw AuthException('Oturum süresi doldu');
    }
    if (response.statusCode == 403) {
      throw AuthException('Admin yetkisi gerekli');
    }
    if (response.statusCode != 200) {
      throw Exception('Bekleyen yorumlar yüklenemedi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => PendingReview.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> decideReview({
    required String reviewId,
    required String status,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/admin/reviews/decision'),
      headers: _authHeaders,
      body: jsonEncode({
        'review_id': reviewId,
        'status': status,
      }),
    );

    if (response.statusCode == 401) {
      throw AuthException('Oturum süresi doldu');
    }
    if (response.statusCode == 403) {
      throw AuthException('Admin yetkisi gerekli');
    }
    if (response.statusCode == 404) {
      throw Exception('Yorum bulunamadı');
    }
    if (response.statusCode != 200) {
      throw Exception('Karar kaydedilemedi: ${response.statusCode}');
    }
  }

  Future<List<Review>> fetchAdminVenueReviews(String venueId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/admin/reviews/venue/$venueId'),
      headers: _authHeaders,
    );

    if (response.statusCode == 401) {
      throw AuthException('Oturum süresi doldu');
    }
    if (response.statusCode == 403) {
      throw AuthException('Admin yetkisi gerekli');
    }
    if (response.statusCode == 404) {
      throw Exception('Mekan bulunamadı');
    }
    if (response.statusCode != 200) {
      throw Exception('Yorumlar yüklenemedi: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Review.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteReview(String reviewId) async {
    final response = await _client.delete(
      Uri.parse('$_baseUrl/admin/reviews/$reviewId'),
      headers: _authHeaders,
    );

    if (response.statusCode == 401) {
      throw AuthException('Oturum süresi doldu');
    }
    if (response.statusCode == 403) {
      throw AuthException('Admin yetkisi gerekli');
    }
    if (response.statusCode == 404) {
      throw Exception('Yorum bulunamadı');
    }
    if (response.statusCode != 204) {
      throw Exception('Yorum silinemedi: ${response.statusCode}');
    }
  }

  List<String> _buildImageUrls({
    String? imageUrl,
    List<String> imageUrls = const [],
  }) {
    final urls = <String>[
      if (imageUrl != null && imageUrl.trim().isNotEmpty) imageUrl.trim(),
      ...imageUrls.map((url) => url.trim()).where((url) => url.isNotEmpty),
    ];
    final seen = <String>{};
    return [
      for (final url in urls)
        if (seen.add(url)) url,
    ];
  }
}

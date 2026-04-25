import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/venue.dart';

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

  Future<List<Venue>> fetchVenues({
    required String location,
    required String productTag,
    required String vibeTag,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/venues?location=$location&product_tags=$productTag&vibe_tags=$vibeTag',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load venues: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((item) => Venue.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/auth_tokens.dart';
import '../models/venue.dart';
import 'auth_exception.dart';

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

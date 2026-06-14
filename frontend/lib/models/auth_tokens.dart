class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    this.isAdmin = false,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      isAdmin: json['is_admin'] as bool? ?? false,
    );
  }

  final String accessToken;
  final String refreshToken;
  final bool isAdmin;
}

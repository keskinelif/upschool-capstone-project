import '../models/auth_tokens.dart';

class AuthSession {
  AuthSession._();

  static AuthTokens? _tokens;

  static AuthTokens? get tokens => _tokens;

  static bool get isLoggedIn => _tokens != null;

  static void save(AuthTokens tokens) {
    _tokens = tokens;
  }

  static void clear() {
    _tokens = null;
  }
}

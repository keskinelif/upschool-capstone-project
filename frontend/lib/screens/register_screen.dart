import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_exception.dart';
import '../theme/gri_theme.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiClient();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _authError;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _authError = null);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final username = await _api.register(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(
          builder: (_) => LoginScreen(
            initialUsername: username,
            successMessage: 'Kayıt başarılı. Şimdi giriş yapın.',
          ),
        ),
        (_) => false,
      );
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() => _authError = err.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _authError = 'Bağlantı hatası. Tekrar deneyin.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('gri.', style: GriTheme.displayTitle(), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(
                      'Yeni hesap oluştur',
                      style: GriTheme.caption(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      'KULLANICI ADI',
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _usernameController,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'ör. elifk',
                      ),
                      validator: (value) {
                        final username = value?.trim().toLowerCase() ?? '';
                        if (username.length < 3) {
                          return 'En az 3 karakter';
                        }
                        if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
                          return 'Yalnızca harf, rakam ve _ kullanın';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_authError != null) setState(() => _authError = null);
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ŞİFRE',
                      style: Theme.of(context).inputDecorationTheme.labelStyle,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      decoration: InputDecoration(
                        hintText: 'En az 4 karakter',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: GriColors.muted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return 'En az 4 karakter';
                        }
                        return null;
                      },
                      onChanged: (_) {
                        if (_authError != null) setState(() => _authError = null);
                      },
                    ),
                    if (_authError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: GriColors.errorBg,
                          borderRadius: BorderRadius.circular(GriRadii.md),
                        ),
                        child: Text(
                          _authError!,
                          style: GriTheme.body().copyWith(color: GriColors.errorText),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 44,
                      child: FilledButton(
                        onPressed: _isLoading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: GriColors.primary,
                          foregroundColor: GriColors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GriRadii.full),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: GriColors.onPrimary,
                                ),
                              )
                            : const Text('Kayıt ol'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                              ),
                      child: const Text('Zaten hesabın var mı? Giriş yap'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

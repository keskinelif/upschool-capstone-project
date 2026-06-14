import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_exception.dart';
import '../services/auth_session.dart';
import '../theme/gri_theme.dart';
import 'explore_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _api = ApiClient();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _authError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _authError = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final username = _emailController.text.trim();
      if (username.isEmpty || _passwordController.text.isEmpty) {
        setState(() => _authError = 'E-posta ve şifre gerekli');
        return;
      }

      final tokens = await _api.login(
        username: username,
        password: _passwordController.text,
      );
      AuthSession.save(tokens);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const ExploreScreen()),
      );
    } on AuthException catch (err) {
      if (!mounted) return;
      setState(() => _authError = err.message);
    } catch (err) {
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
                      'Mekan keşfine giriş yap',
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
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        hintText: 'demo veya admin',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Kullanıcı adı gerekli';
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
                        hintText: '••••••••',
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
                        if (value == null || value.isEmpty) {
                          return 'Şifre gerekli';
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
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: GriColors.errorText, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _authError!,
                                style: GriTheme.body().copyWith(color: GriColors.errorText),
                              ),
                            ),
                          ],
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
                          disabledBackgroundColor: GriColors.primary.withAlpha(102),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(GriRadii.full),
                          ),
                          textStyle: GriTheme.body().copyWith(
                            fontWeight: FontWeight.w600,
                            color: GriColors.onPrimary,
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
                            : const Text('Giriş yap'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Demo: demo / demo123',
                      style: GriTheme.caption(),
                      textAlign: TextAlign.center,
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

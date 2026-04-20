// lib/presentation/screens/auth/login_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/mq_button.dart';
import '../../widgets/mq_text_field.dart';
import '../../widgets/mq_snackbar.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;
  String _lang = 'en';

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref
          .read(supabaseServiceProvider)
          .signIn(email: _email.text.trim(), password: _pass.text);
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      if (!mounted) return;
      String msg;
      if (e.message.contains('Invalid') || e.message.contains('credentials')) {
        msg = _lang == 'sw'
            ? 'Barua pepe au neno la siri si sahihi.'
            : 'Invalid email or password.';
      } else {
        msg = _lang == 'sw'
            ? 'Hitilafu ya kuingia: ${e.message}'
            : 'Login error: ${e.message}';
      }
      MQSnackbar.error(context, msg);
    } catch (_) {
      if (!mounted) return;
      MQSnackbar.error(
          context,
          _lang == 'sw'
              ? 'Kuingia kumeshindwa. Angalia mtandao wako.'
              : 'Login failed. Check your connection.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _googleLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.mindquest://login-callback',
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      MQSnackbar.error(
          context,
          _lang == 'sw'
              ? 'Google Sign-In imeshindwa: ${e.message}'
              : 'Google Sign-In failed: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      MQSnackbar.error(
          context,
          _lang == 'sw'
              ? 'Imeshindwa kuingia na Google.'
              : 'Could not sign in with Google.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _loginAnonymously() async {
    setState(() => _loading = true);
    try {
      final username = 'Mgeni_${DateTime.now().millisecondsSinceEpoch}';
      await ref.read(supabaseServiceProvider).signInAnonymously(
            username: username,
            language: _lang,
          );
      if (mounted) context.go(AppRoutes.home);
    } on AuthException catch (e) {
      if (!mounted) return;
      MQSnackbar.error(context, 'Auth Error: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      MQSnackbar.error(
          context,
          _lang == 'sw'
              ? 'Imeshindwa kuingia kama mgeni: $e'
              : 'Failed to login as guest: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Handle Google OAuth redirect
    ref.listen(authStateProvider, (_, next) {
      final session = next.valueOrNull?.session;
      if (session != null && mounted) {
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Center(
                      child: Text('🧠', style: TextStyle(fontSize: 44))),
                ).animate().scale(curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(_lang == 'sw' ? 'Karibu Tena!' : 'Welcome Back!',
                        style: Theme.of(context).textTheme.displayMedium)
                    .animate(delay: 200.ms)
                    .fadeIn(),
                const SizedBox(height: 8),
                Text(
                  _lang == 'sw'
                      ? 'Endelea na safari yako ya afya ya akili'
                      : 'Continue your mental wellness journey',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ).animate(delay: 300.ms).fadeIn(),
                const SizedBox(height: 32),

                // Language toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LangChip(
                        label: 'English',
                        selected: _lang == 'en',
                        onTap: () => setState(() => _lang = 'en')),
                    const SizedBox(width: 12),
                    _LangChip(
                        label: 'Kiswahili',
                        selected: _lang == 'sw',
                        onTap: () => setState(() => _lang = 'sw')),
                  ],
                ).animate(delay: 350.ms).fadeIn(),
                const SizedBox(height: 28),

                MQTextField(
                  controller: _email,
                  label: _lang == 'sw' ? 'Barua Pepe' : 'Email',
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) => (v ?? '').contains('@')
                      ? null
                      : (_lang == 'sw'
                          ? 'Barua pepe si sahihi'
                          : 'Enter valid email'),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 16),

                MQTextField(
                  controller: _pass,
                  label: _lang == 'sw' ? 'Neno la Siri' : 'Password',
                  hint: '••••••••',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) => (v ?? '').length >= 6
                      ? null
                      : (_lang == 'sw'
                          ? 'Neno la siri ni fupi sana'
                          : 'Password too short'),
                ).animate(delay: 450.ms).fadeIn(),
                const SizedBox(height: 28),

                MQButton(
                  label: _lang == 'sw' ? 'Ingia' : 'Sign In',
                  onPressed: _login,
                  isLoading: _loading,
                  width: double.infinity,
                ).animate(delay: 500.ms).fadeIn(),
                const SizedBox(height: 16),

                // Divider
                Row(children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _lang == 'sw' ? 'au' : 'or',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ]).animate(delay: 510.ms).fadeIn(),
                const SizedBox(height: 16),

                // Google Sign-In
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: _googleLoading ? null : _signInWithGoogle,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      backgroundColor: Colors.white,
                    ),
                    child: _googleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: const Center(
                                  child: Text('G',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4285F4))),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _lang == 'sw'
                                    ? 'Endelea na Google'
                                    : 'Continue with Google',
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ).animate(delay: 520.ms).fadeIn(),
                const SizedBox(height: 16),

                // Privacy notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.privacy_tip_outlined,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _lang == 'sw'
                            ? '🔐 Data yako ni salama. Tunafuata Sheria ya Ulinzi wa Data ya Kenya 2019.'
                            : '🔐 Your data is safe. We comply with Kenya\'s Data Protection Act 2019.',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            color: AppColors.success.withOpacity(0.8)),
                      ),
                    ),
                  ]),
                ).animate(delay: 530.ms).fadeIn(),
                const SizedBox(height: 16),

                // Guest login
                OutlinedButton(
                  onPressed: _loading ? null : _loginAnonymously,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                    side: const BorderSide(color: AppColors.primary, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _lang == 'sw' ? 'Endelea kama Mgeni' : 'Continue as Guest',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ).animate(delay: 550.ms).fadeIn(),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        _lang == 'sw'
                            ? 'Huna akaunti? '
                            : "Don't have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.register),
                      child: const Text('Sign Up',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ).animate(delay: 560.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}

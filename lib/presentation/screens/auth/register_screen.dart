// lib/presentation/screens/auth/register_screen.dart
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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirmPass = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;
  bool _anonymous = false;
  String _lang = 'en';

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _pass.dispose();
    _confirmPass.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final uname = _anonymous
          ? 'mtumiaji_${DateTime.now().millisecondsSinceEpoch}'
          : _username.text.trim();
      await ref.read(supabaseServiceProvider).signUp(
            email: _email.text.trim(),
            password: _pass.text,
            username: uname,
            language: _lang,
          );
      if (mounted) context.go(AppRoutes.onboarding);
    } on AuthException catch (e) {
      if (!mounted) return;
      String msg;
      if (e.message.contains('already registered') ||
          e.message.contains('already exists') ||
          e.message.contains('email')) {
        msg = _lang == 'sw'
            ? 'Barua pepe hii tayari imesajiliwa. Ingia badala yake.'
            : 'This email is already registered. Try signing in.';
      } else if (e.message.contains('Password')) {
        msg = _lang == 'sw'
            ? 'Neno la siri ni dhaifu. Tumia herufi kubwa, ndogo na nambari.'
            : 'Password is too weak. Use uppercase, lowercase and numbers.';
      } else {
        msg = _lang == 'sw'
            ? 'Usajili umeshindwa: ${e.message}'
            : 'Registration failed: ${e.message}';
      }
      MQSnackbar.error(context, msg);
    } catch (e) {
      if (!mounted) return;
      MQSnackbar.error(
          context,
          _lang == 'sw'
              ? 'Kuna hitilafu. Angalia mtandao wako na ujaribu tena.'
              : 'An error occurred. Check your connection and try again.');
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
      // Auth state change will handle navigation via authStateProvider
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
              ? 'Imeshindwa kuingia na Google. Jaribu tena.'
              : 'Could not sign in with Google. Try again.');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to handle Google sign-in redirect
    ref.listen(authStateProvider, (_, next) {
      if (next.valueOrNull?.session != null && mounted) {
        context.go(AppRoutes.onboarding);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_rounded),
                  onPressed: () => context.go(AppRoutes.login),
                ),
                const SizedBox(height: 16),
                Text(
                        _lang == 'sw'
                            ? 'Anza Safari Yako 🌟'
                            : 'Start Your Journey 🌟',
                        style: Theme.of(context).textTheme.displayMedium)
                    .animate()
                    .fadeIn(),
                const SizedBox(height: 8),
                Text(
                        _lang == 'sw'
                            ? 'Jiunge na MindQuest leo'
                            : 'Join MindQuest today',
                        style: Theme.of(context).textTheme.bodyMedium)
                    .animate(delay: 100.ms)
                    .fadeIn(),
                const SizedBox(height: 24),

                // Language
                Row(children: [
                  Text(_lang == 'sw' ? 'Lugha: ' : 'Language: ',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(width: 12),
                  _SmallLangBtn(
                      label: 'EN',
                      selected: _lang == 'en',
                      onTap: () => setState(() => _lang = 'en')),
                  const SizedBox(width: 8),
                  _SmallLangBtn(
                      label: 'SW',
                      selected: _lang == 'sw',
                      onTap: () => setState(() => _lang = 'sw')),
                ]).animate(delay: 150.ms).fadeIn(),
                const SizedBox(height: 20),

                // Google Sign-In Button
                _GoogleSignInButton(
                  isLoading: _googleLoading,
                  lang: _lang,
                  onPressed: _signInWithGoogle,
                ).animate(delay: 175.ms).fadeIn(),
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
                ]).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 16),

                // Anonymous toggle
                GestureDetector(
                  onTap: () => setState(() => _anonymous = !_anonymous),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _anonymous
                          ? AppColors.primaryLight.withOpacity(0.3)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: _anonymous
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                    ),
                    child: Row(children: [
                      Icon(Icons.visibility_off_outlined,
                          color: _anonymous
                              ? AppColors.primary
                              : AppColors.textHint),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              _lang == 'sw'
                                  ? 'Ingia kwa Siri'
                                  : 'Anonymous Mode',
                              style: TextStyle(
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w700,
                                  color: _anonymous
                                      ? AppColors.primary
                                      : AppColors.textPrimary)),
                          Text(
                              _lang == 'sw'
                                  ? 'Jina lako halitaonekana'
                                  : 'Your identity stays hidden',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      )),
                      Switch(
                          value: _anonymous,
                          activeColor: AppColors.primary,
                          onChanged: (v) => setState(() => _anonymous = v)),
                    ]),
                  ),
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 16),

                if (!_anonymous) ...[
                  MQTextField(
                    controller: _username,
                    label: _lang == 'sw' ? 'Jina la Mtumiaji' : 'Username',
                    hint: 'mindwarrior_ke',
                    prefixIcon: Icons.person_outline,
                    validator: (v) => (v ?? '').length >= 3
                        ? null
                        : (_lang == 'sw'
                            ? 'Jina ni fupi sana (herufi 3+)'
                            : 'Username too short (3+ characters)'),
                  ).animate(delay: 250.ms).fadeIn(),
                  const SizedBox(height: 16),
                ],

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
                          : 'Enter a valid email'),
                ).animate(delay: 300.ms).fadeIn(),
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
                  validator: (v) => (v ?? '').length >= 8
                      ? null
                      : (_lang == 'sw'
                          ? 'Lazima herufi 8 au zaidi'
                          : 'At least 8 characters'),
                ).animate(delay: 350.ms).fadeIn(),
                const SizedBox(height: 16),

                MQTextField(
                  controller: _confirmPass,
                  label: _lang == 'sw'
                      ? 'Thibitisha Neno la Siri'
                      : 'Confirm Password',
                  hint: '••••••••',
                  obscureText: _obscure,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) => v == _pass.text
                      ? null
                      : (_lang == 'sw'
                          ? 'Maneno ya siri hayafanani'
                          : 'Passwords do not match'),
                ).animate(delay: 400.ms).fadeIn(),
                const SizedBox(height: 32),

                MQButton(
                  label: _lang == 'sw' ? 'Jisajili' : 'Create Account',
                  onPressed: _register,
                  isLoading: _loading,
                  width: double.infinity,
                ).animate(delay: 450.ms).fadeIn(),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        _lang == 'sw'
                            ? 'Una akaunti? '
                            : 'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.login),
                      child: const Text('Sign In',
                          style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ).animate(delay: 500.ms).fadeIn(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final String lang;
  final VoidCallback onPressed;
  const _GoogleSignInButton({
    required this.isLoading,
    required this.lang,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.grey.shade300, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google G logo using styled Text
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Center(
                      child: Text(
                        'G',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    lang == 'sw' ? 'Endelea na Google' : 'Continue with Google',
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
    );
  }
}

class _SmallLangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _SmallLangBtn(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.textHint),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.textHint)),
      ),
    );
  }
}

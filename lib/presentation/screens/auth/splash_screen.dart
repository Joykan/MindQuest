// lib/presentation/screens/auth/splash_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    try {
      // Wait for auth state to be available
      final authAsync = ref.read(authStateProvider);
      final auth = await authAsync.when(
        data: (state) async => state,
        loading: () async {
          // Wait for the stream to emit by using a stream listener
          return await ref.read(authStateProvider.stream).first;
        },
        error: (e, _) async {
          debugPrint('Auth state error: $e');
          return null;
        },
      );

      if (!mounted) return;

      if (auth?.session != null) {
        try {
          final uid = auth!.session!.user.id;
          final profile =
              await ref.read(supabaseServiceProvider).getProfile(uid);
          if (mounted) {
            context.go(profile?.onboardingComplete == true
                ? AppRoutes.home
                : AppRoutes.onboarding);
          }
        } catch (e) {
          debugPrint('Error loading profile: $e');
          if (mounted) context.go(AppRoutes.onboarding);
        }
      } else {
        if (mounted) context.go(AppRoutes.login);
      }
    } catch (e) {
      debugPrint('Navigation error: $e');
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Center(
                  child: Text('🧠', style: TextStyle(fontSize: 56))),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Colors.white),
            ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
            const SizedBox(height: 8),
            const Text(
              AppConstants.appTagline,
              style: TextStyle(
                  fontFamily: 'Nunito', fontSize: 15, color: Colors.white70),
            ).animate(delay: 500.ms).fadeIn(),
            const SizedBox(height: 60),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2.5),
            ).animate(delay: 800.ms).fadeIn(),
          ],
        ),
      ),
    );
  }
}

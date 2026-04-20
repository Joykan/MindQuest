// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/providers.dart';

// Auth
import 'presentation/screens/auth/splash_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/auth/register_screen.dart';

// Onboarding
import 'presentation/screens/onboarding/onboarding_screen.dart';

// Home
import 'presentation/screens/home/home_shell.dart';
import 'presentation/screens/home/dashboard_screen.dart';
import 'presentation/screens/home/daily_checkin_screen.dart';

// Other screens
import 'presentation/screens/chat/chat_screen.dart';
import 'presentation/screens/mood/mood_screen.dart';
import 'presentation/screens/mood/mood_history_screen.dart';
import 'presentation/screens/gamification/quests_screen.dart';
import 'presentation/screens/gamification/badges_screen.dart';
import 'presentation/screens/resources/resources_screen.dart';
import 'presentation/screens/crisis/crisis_screen.dart';
import 'presentation/screens/profile/profile_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase
  try {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
    );
    debugPrint('✅ Supabase initialized successfully');
  } catch (e) {
    debugPrint('❌ Supabase error: $e');
  }

  // Service Locator
  try {
    await setupServiceLocator();
  } catch (e, stack) {
    debugPrint('❌ Service locator error: $e');
    debugPrint(stack.toString());
  }

  runApp(const ProviderScope(child: MindQuestApp()));
}

class MindQuestApp extends ConsumerWidget {
  const MindQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // Properly handle all three modes: light, dark, system
      themeMode: themeMode == 'dark'
          ? ThemeMode.dark
          : themeMode == 'light'
              ? ThemeMode.light
              : ThemeMode.system,
      routerConfig: _buildRouter(ref),
    );
  }

  GoRouter _buildRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      debugLogDiagnostics: false,
      redirect: (context, state) {
        if (state.matchedLocation == AppRoutes.splash) return null;

        final authState = ref.read(authStateProvider);

        if (authState.isLoading) return AppRoutes.splash;

        final isLoggedIn = authState.valueOrNull?.session != null;
        final isPublicRoute = [
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.register,
          AppRoutes.onboarding,
        ].contains(state.matchedLocation);

        if (!isLoggedIn && !isPublicRoute) {
          return AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(
            path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
        GoRoute(
            path: AppRoutes.register,
            builder: (_, __) => const RegisterScreen()),
        GoRoute(
            path: AppRoutes.onboarding,
            builder: (_, __) => const OnboardingScreen()),
        ShellRoute(
          builder: (context, state, child) => HomeShell(child: child),
          routes: [
            GoRoute(
                path: '/home/home',
                name: 'home',
                builder: (_, __) => const DashboardScreen()),
            GoRoute(
                path: '/home/chat',
                name: 'chat',
                builder: (_, __) => const ChatScreen()),
            GoRoute(
                path: '/home/mood',
                name: 'mood',
                builder: (_, __) => const MoodScreen()),
            GoRoute(
                path: '/home/mood-history',
                name: 'moodHistory',
                builder: (_, __) => const MoodHistoryScreen()),
            GoRoute(
                path: '/home/quests',
                name: 'quests',
                builder: (_, __) => const QuestsScreen()),
            GoRoute(
                path: '/home/badges',
                name: 'badges',
                builder: (_, __) => const BadgesScreen()),
            GoRoute(
                path: '/home/resources',
                name: 'resources',
                builder: (_, __) => const ResourcesScreen()),
            GoRoute(
                path: '/home/crisis',
                name: 'crisis',
                builder: (_, __) => const CrisisScreen()),
            GoRoute(
                path: '/home/profile',
                name: 'profile',
                builder: (_, __) => const ProfileScreen()),
            GoRoute(
                path: '/home/checkin',
                name: 'checkin',
                builder: (_, __) => const DailyCheckinScreen()),
            GoRoute(
                path: '/home/settings',
                name: 'settings',
                builder: (_, __) => const SettingsScreen()),
          ],
        ),
      ],
    );
  }
}

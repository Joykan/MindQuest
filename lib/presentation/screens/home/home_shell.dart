// lib/presentation/screens/home/home_shell.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class HomeShell extends ConsumerWidget {
  final Widget child;
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final loc = GoRouterState.of(context).matchedLocation;

    const tabs = [
      AppRoutes.home,
      AppRoutes.chat,
      AppRoutes.mood,
      AppRoutes.quests,
      AppRoutes.profile,
    ];
    final idx = tabs.indexOf(loc).clamp(0, tabs.length - 1);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20)
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(Icons.home_rounded, lang == 'sw' ? 'Nyumbani' : 'Home',
                    idx == 0, () => context.go(AppRoutes.home)),
                _NavItem(
                    Icons.chat_bubble_rounded,
                    lang == 'sw' ? 'Chat' : 'Chat',
                    idx == 1,
                    () => context.go(AppRoutes.chat)),
                _CenterNav(idx == 2, () => context.go(AppRoutes.mood)),
                _NavItem(
                    Icons.explore_rounded,
                    lang == 'sw' ? 'Dhamira' : 'Quests',
                    idx == 3,
                    () => context.go(AppRoutes.quests)),
                _NavItem(
                    Icons.person_rounded,
                    lang == 'sw' ? 'Mimi' : 'Profile',
                    idx == 4,
                    () => context.go(AppRoutes.profile)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem(this.icon, this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primaryLight.withOpacity(0.3)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                color: selected ? AppColors.primary : AppColors.textHint,
                size: 22),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.primary : AppColors.textHint)),
          ]),
        ),
      );
}

class _CenterNav extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  const _CenterNav(this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: selected
                    ? [AppColors.primary, AppColors.secondary]
                    : [AppColors.primaryLight, AppColors.secondaryLight]),
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected
                ? [
                    BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ]
                : [],
          ),
          child: const Icon(Icons.mood_rounded, color: Colors.white, size: 26),
        ),
      );
}

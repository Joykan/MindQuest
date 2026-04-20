// lib/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/mq_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;
  String _lang = 'en';

  static const _pages = [
    (
      '🌟',
      'Welcome to MindQuest',
      'Karibu MindQuest',
      'Your safe space for mental wellness, powered by AI',
      'Nafasi yako salama ya afya ya akili'
    ),
    (
      '🎮',
      'Earn XP & Badges',
      'Pata XP na Tuzo',
      'Complete quests, log moods, and level up!',
      'Kamilisha dhamira, rekodi hisia, na panda ngazi!'
    ),
    (
      '💬',
      'Chat with AI',
      'Zungumza na AI',
      'MindQuest AI is available 24/7 — judgment-free.',
      'MindQuest AI ipo saa 24/7 — bila hukumu.'
    ),
    (
      '🇰🇪',
      'Built for Kenya',
      'Imeundwa kwa Kenya',
      'Crisis helplines, bilingual English/Kiswahili support.',
      'Nambari za dharura za Kenya, Kiswahili/Kiingereza.'
    ),
  ];

  Future<void> _finish() async {
    final uid = ref.read(supabaseServiceProvider).currentUserId;
    if (uid != null) {
      final p = await ref.read(supabaseServiceProvider).getProfile(uid);
      if (p != null) {
        await ref.read(supabaseServiceProvider).updateProfile(
            p.copyWith(language: _lang, onboardingComplete: true));
      }
    }
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    _LBtn('EN', _lang == 'en',
                        () => setState(() => _lang = 'en')),
                    const SizedBox(width: 8),
                    _LBtn('SW', _lang == 'sw',
                        () => setState(() => _lang = 'sw')),
                  ]),
                  TextButton(
                    onPressed: _finish,
                    child: Text(_lang == 'sw' ? 'Ruka' : 'Skip',
                        style: const TextStyle(color: AppColors.textHint)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (p) => setState(() => _page = p),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(p.$1, style: const TextStyle(fontSize: 80))
                            .animate(key: ValueKey(i))
                            .scale(),
                        const SizedBox(height: 32),
                        Text(_lang == 'sw' ? p.$3 : p.$2,
                                style:
                                    Theme.of(context).textTheme.displayMedium,
                                textAlign: TextAlign.center)
                            .animate(delay: 200.ms)
                            .fadeIn(),
                        const SizedBox(height: 16),
                        Text(_lang == 'sw' ? p.$5 : p.$4,
                                style: Theme.of(context).textTheme.bodyLarge,
                                textAlign: TextAlign.center)
                            .animate(delay: 350.ms)
                            .fadeIn(),
                      ],
                    ),
                  );
                },
              ),
            ),
            SmoothPageIndicator(
              controller: _ctrl,
              count: _pages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColors.primary,
                dotColor: AppColors.primaryLight,
                dotHeight: 8,
                dotWidth: 8,
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: MQButton(
                label: isLast
                    ? (_lang == 'sw' ? 'Anza Safari! 🚀' : 'Start Journey! 🚀')
                    : (_lang == 'sw' ? 'Endelea' : 'Next'),
                onPressed: isLast
                    ? _finish
                    : () => _ctrl.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut),
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore: non_constant_identifier_names
Widget _LBtn(String label, bool selected, VoidCallback onTap) =>
    GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.textHint),
        ),
        child: Text(label,
            style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: selected ? Colors.white : AppColors.textHint)),
      ),
    );

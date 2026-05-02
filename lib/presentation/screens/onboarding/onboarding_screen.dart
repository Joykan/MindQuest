// lib/presentation/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';


class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});
  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingState();
}

class _OnboardingState extends ConsumerState<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;
  String _lang = 'en';

  // (emoji/icon, titleEn, titleSw, subtitleEn, subtitleSw, useEmoji)
  static const _pages = [
    (
      '🌟',
      'Welcome to MindQuest',
      'Karibu MindQuest',
      'Your safe space for mental wellness, powered by AI',
      'Nafasi yako salama ya afya ya akili',
      true,
    ),
    (
      '🎮',
      'Earn XP & Badges',
      'Pata XP na Tuzo',
      'Complete quests, log moods, and level up!',
      'Kamilisha dhamira, rekodi hisia, na panda ngazi!',
      false,
    ),
    (
      '💬',
      'Chat with AI',
      'Zungumza na AI',
      'MindQuest AI is available 24/7 — judgment-free.',
      'MindQuest AI ipo saa 24/7 — bila hukumu.',
      false,
    ),
    (
      '🇰🇪',
      'Built for Kenya',
      'Imeundwa kwa Kenya',
      'Crisis helplines, bilingual English/Kiswahili support.',
      'Nambari za dharura za Kenya, Kiswahili/Kiingereza.',
      true,
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
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    _LangBtn('EN', _lang == 'en',
                        () => setState(() => _lang = 'en')),
                    const SizedBox(width: 8),
                    _LangBtn('SW', _lang == 'sw',
                        () => setState(() => _lang = 'sw')),
                  ]),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      _lang == 'sw' ? 'Ruka' : 'Skip',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        color: Color(0xFF8AAA9A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Page Content ─────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _ctrl,
                onPageChanged: (p) => setState(() => _page = p),
                itemCount: _pages.length,
                itemBuilder: (_, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon/Emoji
                        p.$6
                            ? Text(p.$1,
                                    style: const TextStyle(fontSize: 72))
                                .animate(key: ValueKey('emoji_$i'))
                                .scale(curve: Curves.elasticOut)
                            : Container(
                                width: 52,
                                height: 72,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.primaryLight.withValues(alpha: 0.6),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ).animate(key: ValueKey('box_$i')).fadeIn().scale(),
                        const SizedBox(height: 32),

                        // Title
                        Text(
                          _lang == 'sw' ? p.$3 : p.$2,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ).animate(delay: 200.ms).fadeIn(),
                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          _lang == 'sw' ? p.$5 : p.$4,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            color: Color(0xFF8AAA9A),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ).animate(delay: 350.ms).fadeIn(),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Page Indicator ────────────────────────────────
            SmoothPageIndicator(
              controller: _ctrl,
              count: _pages.length,
              effect: const ExpandingDotsEffect(
                activeDotColor: AppColors.primaryLight,
                dotColor: Color(0xFF3A5A48),
                dotHeight: 8,
                dotWidth: 8,
                expansionFactor: 3,
              ),
            ),
            const SizedBox(height: 32),

            // ── Bottom Button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: isLast
                      ? _finish
                      : () => _ctrl.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navButton,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  child: Text(
                    isLast
                        ? (_lang == 'sw' ? 'Anza Safari! 🚀' : 'Start Journey! 🚀')
                        : (_lang == 'sw' ? 'Endelea' : 'Next'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LangBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangBtn(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.darkSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primaryLight.withValues(alpha: 0.5)
                  : const Color(0xFF3A5A48),
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: selected ? Colors.white : const Color(0xFF8AAA9A),
            ),
          ),
        ),
      );
}

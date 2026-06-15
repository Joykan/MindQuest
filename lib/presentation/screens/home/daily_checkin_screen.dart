// lib/presentation/screens/home/daily_checkin_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/mq_button.dart';
import '../../widgets/mq_snackbar.dart';

class DailyCheckinScreen extends ConsumerStatefulWidget {
  const DailyCheckinScreen({super.key});
  @override
  ConsumerState<DailyCheckinScreen> createState() => _DailyCheckinState();
}

class _DailyCheckinState extends ConsumerState<DailyCheckinScreen> {
  int? _mood;
  final _grat = TextEditingController();
  final _goal = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _grat.dispose();
    _goal.dispose();
    super.dispose();
  }

  bool _isCrisisDetected() {
    final allText = '${_grat.text} ${_goal.text}'.toLowerCase();
    final crisisKeywords = [
      ...AppConstants.crisisKeywordsEn,
      ...AppConstants.crisisKeywordsSw,
    ];
    return crisisKeywords.any((keyword) => allText.contains(keyword));
  }

  void _showCrisisDialog(String lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFFA03860),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('🆘', style: TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    lang == 'sw' ? 'Tunakujali' : 'We Care About You',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Text(
                lang == 'sw'
                    ? 'Tunasikia unajisikia vibaya sana. Huhitaji kupitia hili peke yako.'
                    : 'We hear you. These thoughts can be overwhelming, but you\'re not alone.',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'sw' ? '📞 Piga Simu Sasa' : '📞 Call Now',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    _CrisisContact(
                      name: 'Befrienders Kenya',
                      phone: '0800 723 253',
                      subtitle: lang == 'sw' ? 'Masaa 24/7 — Bure' : '24/7 — Free',
                    ),
                    const SizedBox(height: 8),
                    _CrisisContact(
                      name: lang == 'sw' ? 'Mstari wa Dharura' : 'Kenya Crisis Line',
                      phone: '1190',
                      subtitle: lang == 'sw' ? 'Dharura' : 'Emergency',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      lang == 'sw' ? 'Rudi' : 'Go Back',
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      context.go(AppRoutes.chat);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      lang == 'sw' ? 'Chat na AI' : 'Chat with AI',
                      style: const TextStyle(
                          color: Color(0xFFA03860),
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final lang = ref.read(languageProvider);

    if (_isCrisisDetected()) {
      _showCrisisDialog(lang);
      return;
    }

    if (_mood == null) return;
    setState(() => _loading = true);
    try {
      final svc = ref.read(supabaseServiceProvider);
      final uid = svc.currentUserId!;
      await svc.completeDailyCheckin(
            userId: uid,
            moodValue: _mood!,
            moodLabel: AppConstants.moodLabels[_mood]!,
            gratitudeNote: _grat.text.isEmpty ? null : _grat.text,
            goalForDay: _goal.text.isEmpty ? null : _goal.text,
          );

      // Update quests and badges after successful check-in
      try {
        // First log/check-in quest — complete after 1 log
        final moodCount = await svc.getMoodLogsCount(uid);
        await svc.updateQuestProgress(
          userId: uid,
          questId: 'q_first_log',
          progress: moodCount >= 1 ? 100 : 0,
        );
        // 7-Day Streak quest — progress based on streak days
        final stats = await svc.getUserStats(uid);
        if (stats != null) {
          final streakProgress = ((stats.streakDays / 7) * 100).clamp(0, 100).toInt();
          await svc.updateQuestProgress(
            userId: uid,
            questId: 'q_7day_streak',
            progress: streakProgress,
          );
        }
        // Check and award any earned badges
        await svc.checkAndAwardBadges(uid);
      } catch (_) {
        // Best effort — don't block check-in for quest/badge failures
      }

      // Refresh all relevant data after checkin
      ref.invalidate(todayCheckinProvider);
      ref.invalidate(userStatsProvider);
      ref.invalidate(moodHistoryProvider);
      ref.invalidate(userQuestsProvider);
      ref.invalidate(userBadgesProvider);
      ref.invalidate(profileProvider);

      if (mounted) {
        MQSnackbar.success(
            context,
            lang == 'sw'
                ? '+30 XP! Umekamilisha check-in! 🌟'
                : '+30 XP! Check-in complete! 🌟');
        // Use go back — works whether pushed or navigated to
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      }
    } catch (e) {
      if (mounted) {
        MQSnackbar.error(
            context,
            ref.read(languageProvider) == 'sw'
                ? 'Imeshindwa. Jaribu tena.'
                : 'Failed. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    return Scaffold(
      // ← Back button is provided automatically by the AppBar
      // when the route can be popped; we also add a leading override
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
            lang == 'sw' ? 'Check-in ya Asubuhi' : 'Morning Check-in'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('☀️', style: TextStyle(fontSize: 56)).animate().scale(),
            const SizedBox(height: 16),
            Text(
                lang == 'sw' ? 'Habari za asubuhi! 🌟' : 'Good morning! 🌟',
                style: Theme.of(context).textTheme.displayMedium),
            const SizedBox(height: 8),
            Text(
                lang == 'sw'
                    ? 'Anza siku yako vizuri. Pata XP 30!'
                    : 'Start your day right. Earn 30 XP!',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),
            Text(
                lang == 'sw' ? 'Unajisikiaje leo?' : 'How do you feel today?',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (i) {
                final v = i + 1;
                final sel = _mood == v;
                final color = AppColors.moodColors[v]!;
                return GestureDetector(
                  onTap: () => setState(() => _mood = v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: sel ? 62 : 52,
                    height: sel ? 72 : 60,
                    decoration: BoxDecoration(
                      color: sel
                          ? color.withOpacity(0.2)
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: sel ? Border.all(color: color, width: 2) : null,
                    ),
                    child: Center(
                        child: Text(AppConstants.moodEmojis[v]!,
                            style: TextStyle(fontSize: sel ? 32 : 26))),
                  ),
                );
              }),
            ),
            const SizedBox(height: 28),
            Text(
                lang == 'sw'
                    ? '🙏 Unashukuru nini leo?'
                    : '🙏 What are you grateful for today?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _grat,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: lang == 'sw'
                    ? 'Ninashukuru...'
                    : 'I am grateful for...',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),
            Text(
                lang == 'sw'
                    ? '🎯 Lengo lako la leo?'
                    : '🎯 What\'s your goal today?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _goal,
              decoration: InputDecoration(
                hintText:
                    lang == 'sw' ? 'Leo nitafanya...' : 'Today I will...',
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            MQButton(
              label: lang == 'sw'
                  ? 'Kamilisha (+30 XP)'
                  : 'Complete Check-in (+30 XP)',
              onPressed: _mood != null ? _submit : null,
              isLoading: _loading,
              width: double.infinity,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _CrisisContact extends StatelessWidget {
  final String name;
  final String phone;
  final String subtitle;
  const _CrisisContact({
    required this.name,
    required this.phone,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 2),
          Text(phone,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          Text(subtitle,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 11, color: Colors.white70)),
        ],
      );
}

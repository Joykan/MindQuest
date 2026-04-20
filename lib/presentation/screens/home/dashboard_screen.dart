// lib/presentation/screens/home/dashboard_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/models.dart';
import '../../providers/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final stats = ref.watch(userStatsProvider).valueOrNull;
    final checkin = ref.watch(todayCheckinProvider).valueOrNull;
    final moodHistory = ref.watch(moodHistoryProvider).valueOrNull ?? [];
    final userBadges = ref.watch(userBadgesProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'MindQuest',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.profile),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.notifications_outlined,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tagline
                  Text(
                    lang == 'sw'
                        ? 'Safari yako ya afya ya akili'
                        : 'Your mental wellness journey',
                    style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Nunito',
                        fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lang == 'sw'
                        ? 'Jifunze kila siku'
                        : 'Level up your mental wellness\nevery day',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  // Tier & Streak badges
                  if (stats != null) ...[
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text('${stats.tier} • Level ${stats.level}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9F43).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              const Text('🔥', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text('${stats.streakDays}-day streak',
                                  style: const TextStyle(
                                      color: Color(0xFFFF9F43),
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // XP Progress
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${stats.xp} / ${(stats.level * 500)}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Nunito',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12),
                            ),
                            Text(
                              '${((stats.level + 1) * 500) - stats.xp} XP to ${_getNextTier(stats.tier)}',
                              style: const TextStyle(
                                  color: Colors.white70,
                                  fontFamily: 'Nunito',
                                  fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: stats.levelProgress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor:
                                const AlwaysStoppedAnimation(Color(0xFF4FB3B3)),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Daily check-in prompt
                if (checkin == null) ...[
                  _DailyCheckinCard(lang: lang),
                  const SizedBox(height: 20),
                ],

                // Quick crisis support banner
                _QuickCrisisSupportCard(lang: lang),
                const SizedBox(height: 20),

                // Stats row
                if (stats != null) ...[
                  _StatsRow(
                      stats: stats, badgeCount: userBadges.length, lang: lang),
                  const SizedBox(height: 24),
                ],

                // Quick actions
                Text(lang == 'sw' ? 'Vitendo vya Haraka' : 'Quick Actions',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                _QuickActions(lang: lang),
                const SizedBox(height: 24),

                // This week's mood
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang == 'sw' ? 'HIVI KARIBUNI' : 'THIS WEEK',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white54)),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.moodHistory),
                      child: Text(
                        lang == 'sw' ? 'Historia Kamili →' : 'Full history →',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _WeeklyMoodChart(moodHistory: moodHistory),
                const SizedBox(height: 24),

                // Wellness resources
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        lang == 'sw'
                            ? 'RASILIMALI ZA AFYA'
                            : 'WELLNESS\nRESOURCES',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: Colors.white54,
                            height: 1.4)),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.resources),
                      child: Text(
                        lang == 'sw' ? 'Tazama Zote' : 'See all',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _ResourceTeaser(lang: lang),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ─────────────────────────────────────────────

class _DailyCheckinCard extends StatelessWidget {
  final String lang;
  const _DailyCheckinCard({required this.lang});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.go(AppRoutes.dailyCheckin),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    lang == 'sw' ? "JUKUMU LA LEO" : "TODAY'S MISSION",
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        color: Colors.white70),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('+30\nXP',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(lang == 'sw' ? 'Check-in ya Leo' : 'Daily Check-in',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                  lang == 'sw'
                      ? 'Unajisikiaje leo?'
                      : 'How are you feeling today?',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textSecondary)),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.1);
}

class _StatsRow extends StatelessWidget {
  final dynamic stats;
  final int badgeCount;
  final String lang;
  const _StatsRow(
      {required this.stats, required this.badgeCount, required this.lang});

  @override
  Widget build(BuildContext context) => Row(children: [
        Expanded(
            child: _Stat(
                '🔥',
                '${stats.streakDays}',
                lang == 'sw' ? 'Siku za Msururu' : 'Day streak',
                const Color(0xFF2E2E4F))),
        const SizedBox(width: 12),
        Expanded(
            child: _Stat('🏅', '$badgeCount', lang == 'sw' ? 'Tuzo' : 'Badges',
                const Color(0xFF2E2E4F))),
        const SizedBox(width: 12),
        Expanded(
            child: _Stat('💬', '${stats.totalSessions}',
                lang == 'sw' ? 'Vikao' : 'Sessions', const Color(0xFF2E2E4F))),
      ]);
}

class _Stat extends StatelessWidget {
  final String icon, value, label;
  final Color color;
  const _Stat(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70)),
        ]),
      );
}

class _QuickActions extends StatelessWidget {
  final String lang;
  const _QuickActions({required this.lang});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        icon: '💬',
        label: lang == 'sw' ? 'Chat na AI' : 'Chat with AI',
        sublabel: 'Available 24/7',
        route: AppRoutes.chat,
        color: const Color(0xFF5E4B9E),
      ),
      (
        icon: '😊',
        label: lang == 'sw' ? 'Rekodi Hisia' : 'Log Mood',
        sublabel: '+20 XP reward',
        route: AppRoutes.mood,
        color: const Color(0xFF2E7D5C),
      ),
      (
        icon: '🎯',
        label: lang == 'sw' ? 'Dhamira' : 'My Quests',
        sublabel: '2 active now',
        route: AppRoutes.quests,
        color: const Color(0xFF8B6F47),
      ),
      (
        icon: '🎨',
        label: lang == 'sw' ? 'Rasilimali' : 'Resources',
        sublabel: 'Articles & tips',
        route: AppRoutes.resources,
        color: const Color(0xFF3D6B8E),
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.8,
      children: items.asMap().entries.map((e) {
        final a = e.value;
        return GestureDetector(
          onTap: () => context.go(a.route),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: a.color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(height: 8),
                Text(a.label,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                const SizedBox(height: 2),
                Text(a.sublabel,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: Colors.white70)),
              ],
            ),
          ),
        ).animate(delay: Duration(milliseconds: e.key * 60)).fadeIn().scale();
      }).toList(),
    );
  }
}

class _ResourceTeaser extends StatelessWidget {
  final String lang;
  const _ResourceTeaser({required this.lang});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title:
            lang == 'sw' ? 'Mazoezi ya Kupumua' : 'Box Breathing for Anxiety',
        category: lang == 'sw' ? 'MAZOEZI' : 'EXERCISE',
        tag: 'Mindfulness',
        icon: '🌬️',
      ),
      (
        title: lang == 'sw' ? 'Fahamu Wasiwasi' : 'Understanding Depression',
        category: lang == 'sw' ? 'MAKALA' : 'ARTICLE',
        tag: 'Awareness',
        icon: '📖',
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: items
          .asMap()
          .entries
          .map((e) => GestureDetector(
                onTap: () => context.go(AppRoutes.resources),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.1), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.value.category,
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                                color: Colors.white54),
                          ),
                          const SizedBox(height: 8),
                          Text(e.value.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          e.value.tag,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _WeeklyMoodChart extends StatelessWidget {
  final List<MoodLog> moodHistory;
  const _WeeklyMoodChart({required this.moodHistory});

  @override
  Widget build(BuildContext context) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    // Create a map of mood logs by day of week (0 = Monday)
    final moodByDay = <int, MoodLog>{};
    for (var mood in moodHistory) {
      final dayOfWeek = mood.loggedAt.weekday - 1;
      if (dayOfWeek >= 0 && dayOfWeek < 7) {
        // Keep the most recent mood for each day
        if (!moodByDay.containsKey(dayOfWeek) ||
            mood.loggedAt.isAfter(moodByDay[dayOfWeek]!.loggedAt)) {
          moodByDay[dayOfWeek] = mood;
        }
      }
    }

    const colors = [
      Color(0xFF5E4B9E),
      Color(0xFF8B6F47),
      Color(0xFF3D8B9D),
      Color(0xFF8B6F47),
      Color(0xFFA03860),
      Color(0xFF3D8B9D),
      Color(0xFF2E2E4F),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final mood = moodByDay[i];
        return Container(
          width: (MediaQuery.of(context).size.width - 40 - 72) / 7,
          height: 70,
          decoration: BoxDecoration(
            color: colors[i],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mood?.emoji ?? '—', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 4),
              Text(weekDays[i],
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ],
          ),
        );
      }),
    );
  }
}

// ── Quick Crisis Support Card ───────────────────────────────
class _QuickCrisisSupportCard extends StatelessWidget {
  final String lang;
  const _QuickCrisisSupportCard({required this.lang});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.go(AppRoutes.crisis),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.crisis.withOpacity(0.12),
                AppColors.accent.withOpacity(0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.crisis.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.crisis.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🆘', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'sw' ? 'Haja ya Msaada?' : 'Need Help?',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.crisis,
                      ),
                    ),
                    Text(
                      lang == 'sw'
                          ? 'Kuwasiliana na jamii ya dharura'
                          : 'Crisis support & hotlines',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.crisis.withOpacity(0.6),
                size: 16,
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.1);
}

String _getNextTier(String currentTier) {
  const tierProgression = [
    'Newcomer',
    'Explorer',
    'Voyager',
    'Pioneer',
    'Warrior',
    'Legend',
  ];
  final currentIndex = tierProgression.indexOf(currentTier);
  if (currentIndex >= 0 && currentIndex < tierProgression.length - 1) {
    return tierProgression[currentIndex + 1];
  }
  return 'Legend';
}

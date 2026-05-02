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
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6B5FAF), AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
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
                        ? 'Jifunze kila siku ⭐'
                        : 'Level up every day ⭐',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                  // XP Progress
                  if (stats != null) ...[
                    const SizedBox(height: 20),
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
                              const Text('🔥',
                                  style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                  '${stats.tier} • Lv.${stats.level}',
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
                              const Text('🔥',
                                  style: TextStyle(fontSize: 14)),
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
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: stats.levelProgress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.primaryLight),
                        minHeight: 6,
                      ),
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
                // ── Daily check-in prompt ──────────────────────
                if (checkin == null) ...[
                  _DailyCheckinCard(lang: lang),
                  const SizedBox(height: 16),
                ],

                // ── Crisis support banner ──────────────────────
                _QuickCrisisSupportCard(lang: lang),
                const SizedBox(height: 20),

                // ── Stats row ─────────────────────────────────
                if (stats != null) ...[
                  _StatsRow(
                      stats: stats,
                      badgeCount: userBadges.length,
                      lang: lang),
                  const SizedBox(height: 24),
                ],

                // ── Quick actions grid ─────────────────────────
                Text(
                    lang == 'sw' ? 'Vitendo vya Haraka' : 'Quick Actions',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 12),
                _QuickActions(lang: lang),
                const SizedBox(height: 24),

                // ── This week ─────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lang == 'sw' ? 'HIVI KARIBUNI' : 'THIS WEEK',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary)),
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

                // ── Wellness resources ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        lang == 'sw'
                            ? 'RASILIMALI ZA AFYA'
                            : 'WELLNESS RESOURCES',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.resources),
                      child: Text(
                        lang == 'sw' ? 'Tazama Zote →' : 'See all →',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
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

// ── Sub-widgets ─────────────────────────────────────────────────

class _DailyCheckinCard extends StatelessWidget {
  final String lang;
  const _DailyCheckinCard({required this.lang});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.go(AppRoutes.dailyCheckin),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFFB347), Color(0xFFFFCC70)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'sw' ? "JUKUMU LA LEO" : "TODAY'S MISSION",
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF7A4A00)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      lang == 'sw' ? 'Check-in ya Leo ⭐' : 'Daily Check-in ⭐',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF3A2800)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                        lang == 'sw'
                            ? 'Unajisikiaje leo?'
                            : 'How are you feeling today?',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            color: Color(0xFF7A4A00))),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  children: [
                    Text('+30',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF3A2800))),
                    Text('XP',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF7A4A00))),
                  ],
                ),
              ),
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
                lang == 'sw' ? 'Msururu' : 'Streak',
                const Color(0xFFF0F0F0))),
        const SizedBox(width: 12),
        Expanded(
            child: _Stat('🏅', '$badgeCount',
                lang == 'sw' ? 'Tuzo' : 'Badges', const Color(0xFFF0F0F0))),
        const SizedBox(width: 12),
        Expanded(
            child: _Stat('💬', '${stats.totalSessions}',
                lang == 'sw' ? 'Vikao' : 'Sessions',
                const Color(0xFFF0F0F0))),
      ]);
}

class _Stat extends StatelessWidget {
  final String icon, value, label;
  final Color color;
  const _Stat(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
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
        color: const Color(0xFF7A8EAD), // slate blue
      ),
      (
        icon: '😊',
        label: lang == 'sw' ? 'Rekodi Hisia' : 'Log Mood',
        sublabel: '+20 XP reward',
        route: AppRoutes.mood,
        color: const Color(0xFF5B9B7A), // teal green
      ),
      (
        icon: '🎯',
        label: lang == 'sw' ? 'Dhamira' : 'My Quests',
        sublabel: 'Active',
        route: AppRoutes.quests,
        color: const Color(0xFF7A8EAD), // slate blue
      ),
      (
        icon: '📖',
        label: lang == 'sw' ? 'Rasilimali' : 'Resources',
        sublabel: 'Articles & tips',
        route: AppRoutes.resources,
        color: const Color(0xFF7A8060), // olive
      ),
    ];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
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
                Text(a.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(a.label,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
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

// ── Resource Teaser as LIST (matches screenshot) ────────────────
class _ResourceTeaser extends StatelessWidget {
  final String lang;
  const _ResourceTeaser({required this.lang});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        title: lang == 'sw' ? 'Mazoezi ya Kupumua' : 'Box Breathing for Anxiety',
        category: lang == 'sw' ? 'MAZOEZI' : 'EXERCISE',
        subtitle: lang == 'sw'
            ? 'Mbinu ya haraka ya kupunguza wasiwasi'
            : 'A quick technique to calm anxiety fast',
        icon: '🌬️',
        catColor: const Color(0xFF4A9176),
      ),
      (
        title:
            lang == 'sw' ? 'Fahamu Unyogovu' : 'Understanding Depression',
        category: lang == 'sw' ? 'MAKALA' : 'ARTICLE',
        subtitle: lang == 'sw'
            ? 'Dalili, sababu na njia za uponyaji'
            : 'Symptoms, causes and paths to healing',
        icon: '📊',
        catColor: const Color(0xFF4A9176),
      ),
    ];

    return Column(
      children: items
          .map((item) => GestureDetector(
                onTap: () => context.go(AppRoutes.resources),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: Colors.grey.shade200, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(item.icon,
                              style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: item.catColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category,
                                style: TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: item.catColor),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.title,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.subtitle,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          color: AppColors.textHint, size: 14),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ── Weekly Mood Chart ─────────────────────────────────────────
class _WeeklyMoodChart extends StatelessWidget {
  final List<MoodLog> moodHistory;
  const _WeeklyMoodChart({required this.moodHistory});

  @override
  Widget build(BuildContext context) {
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday - 1; // 0 = Monday

    final moodByDay = <int, MoodLog>{};
    for (var mood in moodHistory) {
      final dayOfWeek = mood.loggedAt.weekday - 1;
      if (dayOfWeek >= 0 && dayOfWeek < 7) {
        if (!moodByDay.containsKey(dayOfWeek) ||
            mood.loggedAt.isAfter(moodByDay[dayOfWeek]!.loggedAt)) {
          moodByDay[dayOfWeek] = mood;
        }
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final mood = moodByDay[i];
        final isToday = i == today;
        return Container(
          width: (MediaQuery.of(context).size.width - 40 - 48) / 7,
          height: 72,
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primary.withOpacity(0.08)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isToday
                  ? AppColors.primary.withOpacity(0.4)
                  : Colors.grey.shade200,
              width: isToday ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(mood?.emoji ?? '—',
                  style: TextStyle(
                      fontSize: mood != null ? 22 : 14,
                      color: mood != null ? null : Colors.grey.shade300)),
              const SizedBox(height: 4),
              Text(weekDays[i],
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary)),
            ],
          ),
        );
      }),
    );
  }
}

// ── Quick Crisis Support Card ───────────────────────────────────
class _QuickCrisisSupportCard extends StatelessWidget {
  final String lang;
  const _QuickCrisisSupportCard({required this.lang});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.go(AppRoutes.crisis),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4F0),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.crisis.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.crisis.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🆘', style: TextStyle(fontSize: 18)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == 'sw' ? 'Haja ya Msaada?' : 'Need Support?',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.crisis,
                      ),
                    ),
                    Text(
                      lang == 'sw'
                          ? 'Msaada wa dharura & Kenya'
                          : 'Crisis support & Kenya helplines',
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
                color: AppColors.crisis.withOpacity(0.5),
                size: 14,
              ),
            ],
          ),
        ),
      ).animate().fadeIn().slideY(begin: 0.1);
}


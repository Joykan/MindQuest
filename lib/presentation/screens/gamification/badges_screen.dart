// lib/presentation/screens/gamification/badges_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final allBadges = ref.watch(allBadgesProvider).valueOrNull ?? [];
    final userBadges = ref.watch(userBadgesProvider).valueOrNull ?? [];
    final earnedIds = userBadges.map((b) => b.id).toSet();

    return Scaffold(
      appBar: AppBar(title: Text(lang == 'sw' ? 'Tuzo Zangu' : 'My Badges')),
      body: Column(children: [
        // Progress header
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(children: [
                Text('${userBadges.length}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(lang == 'sw' ? 'Zilizopatikana' : 'Earned',
                    style: const TextStyle(
                        color: Colors.white70, fontFamily: 'Nunito')),
              ]),
              Container(width: 1, height: 40, color: Colors.white30),
              Column(children: [
                Text('${allBadges.length - userBadges.length}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(lang == 'sw' ? 'Zilizobaki' : 'Remaining',
                    style: const TextStyle(
                        color: Colors.white70, fontFamily: 'Nunito')),
              ]),
              Container(width: 1, height: 40, color: Colors.white30),
              Column(children: [
                Text(
                    '${allBadges.isEmpty ? 0 : (userBadges.length / allBadges.length * 100).round()}%',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text(lang == 'sw' ? 'Imekamilika' : 'Complete',
                    style: const TextStyle(
                        color: Colors.white70, fontFamily: 'Nunito')),
              ]),
            ],
          ),
        ).animate().fadeIn().slideY(begin: -0.1),

        // Badge grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: allBadges.length,
            itemBuilder: (_, i) {
              final badge = allBadges[i];
              final earned = earnedIds.contains(badge.id);
              final earnedB = userBadges.firstWhere(
                (b) => b.id == badge.id,
                orElse: () => badge,
              );
              return GestureDetector(
                onTap: () =>
                    _showDetail(context, badge, earned, earnedB.earnedAt, lang),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: earned
                        ? AppColors.primaryLight.withOpacity(0.25)
                        : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: earned ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: earned
                        ? [
                            BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 8)
                          ]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(earned ? '🏅' : '🔒',
                          style: TextStyle(fontSize: earned ? 36 : 28)),
                      const SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          lang == 'sw' && badge.nameSw != null
                              ? badge.nameSw!
                              : badge.name,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color:
                                earned ? AppColors.primary : AppColors.textHint,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (earned)
                        Text('+${badge.xpReward} XP',
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 10,
                                color: AppColors.success)),
                    ],
                  ),
                )
                    .animate(delay: Duration(milliseconds: i * 40))
                    .fadeIn()
                    .scale(),
              );
            },
          ),
        ),
      ]),
    );
  }

  void _showDetail(
      BuildContext ctx, badge, bool earned, DateTime? earnedAt, String lang) {
    showModalBottomSheet(
      context: ctx,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(earned ? '🏅' : '🔒', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(
            lang == 'sw' && badge.nameSw != null ? badge.nameSw! : badge.name,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            lang == 'sw' && badge.descriptionSw != null
                ? badge.descriptionSw!
                : badge.description ?? '',
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text('+${badge.xpReward} XP',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary)),
          ),
          if (earned && earnedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              '${lang == 'sw' ? 'Ilipatikana' : 'Earned'}: '
              '${earnedAt.day}/${earnedAt.month}/${earnedAt.year}',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  color: AppColors.textHint),
            ),
          ],
        ]),
      ),
    );
  }
}

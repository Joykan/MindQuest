// lib/presentation/widgets/gamification_tracker.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

/// Widget to display XP and level progress with animations
class XPProgressWidget extends StatelessWidget {
  final int currentXP;
  final int nextLevelXP;
  final int level;
  final String tier;
  final String lang;
  final bool showNotification;

  const XPProgressWidget({
    super.key,
    required this.currentXP,
    required this.nextLevelXP,
    required this.level,
    required this.tier,
    required this.lang,
    this.showNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentXP / nextLevelXP).clamp(0.0, 1.0);
    final xpToNextLevel = (nextLevelXP - currentXP).clamp(0, nextLevelXP);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with level and tier
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang == 'sw' ? 'Kiwango Chako' : 'Your Level',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.7),
                    letterSpacing: 0.5,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Level $level',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      tier,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF9F43),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // XP Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.4),
                ),
              ),
              child: Column(
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 16)),
                  Text(
                    '$currentXP',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'XP',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 9,
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$currentXP / $nextLevelXP',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '$xpToNextLevel ${lang == 'sw' ? 'XP zaidi' : 'XP to go'}',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF4FB3B3)),
                minHeight: 8,
              ),
            )
                .animate()
                .scaleX(
                  duration: 800.ms,
                  curve: Curves.easeOut,
                  begin: 0,
                  end: 1,
                )
                .fadeIn(),
          ],
        ),

        // Notification
        if (showNotification)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.4),
                ),
              ),
              child: Row(
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lang == 'sw'
                          ? 'Umepata XP! Endelea kuendelea!'
                          : 'You earned XP! Keep it up!',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .slideY(begin: -0.2, duration: 400.ms)
                .fadeIn(duration: 400.ms),
          ),
      ],
    );
  }
}

/// Badge display widget
class BadgeDisplayWidget extends StatelessWidget {
  final String badgeName;
  final String? badgeIcon;
  final String category;
  final String lang;
  final bool isNewBadge;

  const BadgeDisplayWidget({
    super.key,
    required this.badgeName,
    this.badgeIcon,
    required this.category,
    required this.lang,
    this.isNewBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.2),
            Colors.orange.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.4),
          width: isNewBadge ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          if (badgeIcon != null)
            Text(badgeIcon!, style: const TextStyle(fontSize: 32))
                .animate()
                .scale(curve: Curves.elasticOut)
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.star, color: Colors.amber)),
            ),
          const SizedBox(height: 8),
          Text(
            badgeName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          if (isNewBadge)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                lang == 'sw' ? '✨ MPYA!' : '✨ NEW!',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: Colors.amber,
                ),
              ),
            ),
        ],
      ),
    ).animate().scale(curve: Curves.elasticOut, delay: 100.ms).fadeIn();
  }
}

/// Stats card with animated counters
class StatCardWidget extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? subtitle;
  final Color? accentColor;
  final String lang;

  const StatCardWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
    this.accentColor,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              if (accentColor != null)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 9,
                color: accentColor ?? Colors.white.withOpacity(0.5),
              ),
            ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, duration: 300.ms);
  }
}

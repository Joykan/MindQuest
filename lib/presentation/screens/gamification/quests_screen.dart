// lib/presentation/screens/gamification/quests_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final quests = ref.watch(userQuestsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(lang == 'sw' ? 'Dhamira Zangu' : 'My Quests')),
      body: quests.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎯', style: TextStyle(fontSize: 64))
                    .animate()
                    .scale(curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text(lang == 'sw' ? 'Bado hakuna dhamira' : 'No quests yet',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  lang == 'sw'
                      ? 'Dhamira zitaonekana hapa ukianza kutumia app'
                      : 'Quests will appear as you use the app',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ));
          }

          final active = list.where((q) => q.status == 'in_progress').toList();
          final completed = list.where((q) => q.status == 'completed').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // XP summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QStat('🎯', '${active.length}',
                        lang == 'sw' ? 'Zinaendelea' : 'Active'),
                    _QStat('✅', '${completed.length}',
                        lang == 'sw' ? 'Zilizokamilika' : 'Completed'),
                    _QStat(
                        '⚡',
                        '${completed.fold(0, (s, q) => s + q.xpReward)}',
                        lang == 'sw' ? 'XP Zilizopata' : 'XP Earned'),
                  ],
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 20),

              if (active.isNotEmpty) ...[
                Text(lang == 'sw' ? '🎯 Zinaendelea' : '🎯 Active Quests',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                ...active.asMap().entries.map(
                    (e) => _QuestCard(quest: e.value, lang: lang, i: e.key)),
                const SizedBox(height: 20),
              ],

              if (completed.isNotEmpty) ...[
                Text(lang == 'sw' ? '✅ Zilizokamilika' : '✅ Completed',
                    style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                ...completed.asMap().entries.map(
                    (e) => _QuestCard(quest: e.value, lang: lang, i: e.key)),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _QStat extends StatelessWidget {
  final String icon, value, label;
  const _QStat(this.icon, this.value, this.label);

  @override
  Widget build(BuildContext context) => Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        Text(value,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        Text(label,
            style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 11, color: Colors.white70)),
      ]);
}

class _QuestCard extends StatelessWidget {
  final dynamic quest;
  final String lang;
  final int i;
  const _QuestCard({required this.quest, required this.lang, required this.i});

  @override
  Widget build(BuildContext context) {
    final done = quest.status == 'completed';
    final color = done ? AppColors.success : AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: done ? AppColors.success.withOpacity(0.08) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
        ],
      ),
      child: Row(children: [
        Text(done ? '✅' : '🎯', style: const TextStyle(fontSize: 32)),
        const SizedBox(width: 14),
        Expanded(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang == 'sw' && quest.titleSw != null
                  ? quest.titleSw
                  : quest.title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (quest.description != null)
              Text(
                lang == 'sw' && quest.descriptionSw != null
                    ? quest.descriptionSw
                    : quest.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 6),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('+${quest.xpReward} XP',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: color,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(quest.questType,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.textSecondary)),
              ),
            ]),
          ],
        )),
        const SizedBox(width: 12),
        if (!done)
          CircularPercentIndicator(
            radius: 26,
            lineWidth: 4,
            percent: (quest.progress / 100.0).clamp(0.0, 1.0),
            center: Text('${quest.progress}%',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
            progressColor: AppColors.primary,
            backgroundColor: AppColors.primaryLight.withOpacity(0.3),
          ),
      ]),
    )
        .animate(delay: Duration(milliseconds: i * 60))
        .fadeIn()
        .slideX(begin: -0.05);
  }
}

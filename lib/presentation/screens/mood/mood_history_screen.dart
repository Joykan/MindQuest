// lib/presentation/screens/mood/mood_history_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class MoodHistoryScreen extends ConsumerWidget {
  const MoodHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final history = ref.watch(moodHistoryProvider);
    final analytics = ref.watch(moodAnalyticsProvider);

    return Scaffold(
      appBar: AppBar(
          title: Text(lang == 'sw' ? 'Historia ya Hisia' : 'Mood History')),
      body: history.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('📊', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 16),
                Text(
                    lang == 'sw'
                        ? 'Bado hakuna hisia zilizorekodiwa'
                        : 'No moods logged yet',
                    style: Theme.of(context).textTheme.headlineSmall),
              ],
            ));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Chart card
              analytics.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (data) {
                  if (data['trend'] == null ||
                      (data['trend'] as List).isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final trend = data['trend'] as List;
                  final spots = trend
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(),
                          (e.value['value'] as int).toDouble()))
                      .toList();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10)
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            lang == 'sw'
                                ? 'Mwenendo wa Siku 30'
                                : '30-Day Mood Trend',
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          lang == 'sw'
                              ? 'Wastani: ${(data['average'] as double).toStringAsFixed(1)}/5'
                              : 'Average: ${(data['average'] as double).toStringAsFixed(1)}/5',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 140,
                          child: LineChart(LineChartData(
                            gridData: const FlGridData(show: false),
                            titlesData: const FlTitlesData(show: false),
                            borderData: FlBorderData(show: false),
                            minY: 1,
                            maxY: 5,
                            lineBarsData: [
                              LineChartBarData(
                                spots: spots,
                                isCurved: true,
                                color: AppColors.primary,
                                barWidth: 3,
                                dotData: FlDotData(
                                  getDotPainter: (_, __, ___, ____) =>
                                      FlDotCirclePainter(
                                          radius: 4,
                                          color: AppColors.primary,
                                          strokeColor: Colors.white,
                                          strokeWidth: 2),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppColors.primary.withOpacity(0.1),
                                ),
                              )
                            ],
                          )),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1);
                },
              ),

              // Log list
              Text(
                lang == 'sw' ? 'Rekodi Zote' : 'All Entries',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              ...logs.asMap().entries.map((e) {
                final log = e.value;
                final color = AppColors.moodColors[log.moodValue]!;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: color.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.03), blurRadius: 6)
                    ],
                  ),
                  child: Row(children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                          child: Text(log.emoji,
                              style: const TextStyle(fontSize: 26))),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang == 'sw'
                              ? AppConstants.moodLabelsSw[log.moodValue]!
                              : AppConstants.moodLabels[log.moodValue]!,
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w700,
                              color: color),
                        ),
                        if (log.note != null && log.note!.isNotEmpty)
                          Text(log.note!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        Text(
                          '${log.loggedAt.day}/${log.loggedAt.month}/${log.loggedAt.year}  '
                          '${log.loggedAt.hour.toString().padLeft(2, '0')}:'
                          '${log.loggedAt.minute.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    )),
                    if (log.tags?.isNotEmpty == true)
                      Column(
                        children: log.tags!
                            .take(2)
                            .map((t) => Container(
                                  margin: const EdgeInsets.only(bottom: 3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(t,
                                      style: const TextStyle(
                                          fontFamily: 'Nunito', fontSize: 10)),
                                ))
                            .toList(),
                      ),
                  ]),
                )
                    .animate(delay: Duration(milliseconds: e.key * 40))
                    .fadeIn()
                    .slideX(begin: -0.05);
              }),
            ],
          );
        },
      ),
    );
  }
}

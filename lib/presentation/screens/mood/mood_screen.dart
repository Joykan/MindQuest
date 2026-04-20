// lib/presentation/screens/mood/mood_screen.dart
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/mq_button.dart';
import '../../widgets/mq_snackbar.dart';

class MoodScreen extends ConsumerStatefulWidget {
  const MoodScreen({super.key});
  @override
  ConsumerState<MoodScreen> createState() => _MoodScreenState();
}

class _MoodScreenState extends ConsumerState<MoodScreen> {
  int? _mood;
  int _energy = 3;
  final _note = TextEditingController();
  final List<String> _tags = [];
  bool _loading = false;
  String? _moodAnalysis;

  static const _tagOptions = [
    'Stress',
    'Anxiety',
    'School',
    'Family',
    'Work',
    'Relationships',
    'Health',
    'Sleep',
  ];

  Future<void> _save() async {
    if (_mood == null) return;
    setState(() => _loading = true);
    try {
      final uid = ref.read(supabaseServiceProvider).currentUserId!;
      final lang = ref.read(languageProvider);

      // Save mood
      await ref.read(supabaseServiceProvider).logMood(
            userId: uid,
            moodValue: _mood!,
            moodLabel: AppConstants.moodLabels[_mood]!,
            note: _note.text.isEmpty ? null : _note.text,
            energyLevel: _energy,
            tags: _tags.isEmpty ? null : List.from(_tags),
          );

      // Award XP
      await ref
          .read(supabaseServiceProvider)
          .awardXp(userId: uid, xpAmount: AppConstants.xpPerMoodLog);

      ref.invalidate(moodHistoryProvider);
      ref.invalidate(userStatsProvider);

      // Get AI analysis
      try {
        final analysis = await ref.read(geminiServiceProvider).analyzeMood(
              moodValue: _mood!,
              note: _note.text,
              energyLevel: _energy,
              tags: _tags,
              language: lang,
            );
        setState(() => _moodAnalysis = analysis);
      } catch (_) {
        // Silently fail on analysis
      }

      if (mounted) {
        // Show analysis dialog
        if (_moodAnalysis != null) {
          _showAnalysisDialog(context, lang);
        } else {
          MQSnackbar.success(
              context,
              lang == 'sw'
                  ? '+${AppConstants.xpPerMoodLog} XP! Hisia zimehifadhiwa! 🌟'
                  : '+${AppConstants.xpPerMoodLog} XP! Mood logged! 🌟');
          Future.delayed(const Duration(seconds: 1), () => context.pop());
        }
      }
    } catch (_) {
      if (mounted) MQSnackbar.error(context, 'Failed to save mood. Try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showAnalysisDialog(BuildContext context, String lang) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🧠',
                style: TextStyle(fontSize: 40),
              ),
              const SizedBox(height: 12),
              Text(
                lang == 'sw' ? 'Uchambuzi wa Hisia' : 'Mood Insights',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _moodAnalysis ?? '',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        if (mounted) {
                          MQSnackbar.success(
                              context,
                              lang == 'sw'
                                  ? '+${AppConstants.xpPerMoodLog} XP! Hisia zimehifadhiwa! 🌟'
                                  : '+${AppConstants.xpPerMoodLog} XP! Mood logged! 🌟');
                          Future.delayed(
                            const Duration(seconds: 1),
                            () {
                              if (mounted) {
                                context.pop();
                              }
                            },
                          );
                        }
                      },
                      child: Text(lang == 'sw' ? 'Asante!' : 'Got it!'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    return Scaffold(
      appBar: AppBar(
          title: Text(lang == 'sw' ? 'Rekodi Hisia Zako' : 'Log Your Mood')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            lang == 'sw' ? 'Unajisikiaje sasa? 💭' : 'How are you feeling? 💭',
            style: Theme.of(context).textTheme.headlineMedium,
          ).animate().fadeIn(),
          const SizedBox(height: 32),

          // Mood picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (i) {
              final v = i + 1;
              final sel = _mood == v;
              final col = AppColors.moodColors[v]!;
              return GestureDetector(
                onTap: () => setState(() => _mood = v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: sel ? 68 : 56,
                  height: sel ? 82 : 68,
                  decoration: BoxDecoration(
                    color:
                        sel ? col.withOpacity(0.2) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                    border: sel ? Border.all(color: col, width: 2) : null,
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppConstants.moodEmojis[v]!,
                            style: TextStyle(fontSize: sel ? 34 : 28)),
                        if (sel)
                          Text(
                            lang == 'sw'
                                ? AppConstants.moodLabelsSw[v]!
                                : AppConstants.moodLabels[v]!,
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 9,
                                color: col,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                      ]),
                ),
              ).animate(delay: Duration(milliseconds: i * 60)).scale().fadeIn();
            }),
          ),
          const SizedBox(height: 28),

          // Energy slider
          Text(lang == 'sw' ? 'Nguvu Zako' : 'Energy Level',
              style: Theme.of(context).textTheme.titleLarge),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.secondary,
              thumbColor: AppColors.secondary,
              overlayColor: AppColors.secondary.withOpacity(0.2),
            ),
            child: Slider(
              value: _energy.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (v) => setState(() => _energy = v.round()),
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(lang == 'sw' ? 'Chini' : 'Low',
                style: Theme.of(context).textTheme.bodySmall),
            Text(lang == 'sw' ? 'Juu' : 'High',
                style: Theme.of(context).textTheme.bodySmall),
          ]),
          const SizedBox(height: 24),

          // Tags
          Text(
            lang == 'sw'
                ? 'Lebo (Chagua zinazofaa)'
                : 'Tags (Select all that apply)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _tagOptions.map((tag) {
              final sel = _tags.contains(tag);
              return GestureDetector(
                onTap: () =>
                    setState(() => sel ? _tags.remove(tag) : _tags.add(tag)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.primary : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(tag,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppColors.textSecondary,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Note
          TextField(
            controller: _note,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: lang == 'sw'
                  ? 'Andika kidogo zaidi... (si lazima)'
                  : 'Write a little more about how you feel... (optional)',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 28),

          MQButton(
            label: lang == 'sw' ? 'Hifadhi Hisia' : 'Save Mood',
            onPressed: _mood != null ? _save : null,
            isLoading: _loading,
            width: double.infinity,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.moodHistory),
            icon: const Icon(Icons.history_rounded),
            label: Text(lang == 'sw' ? 'Angalia Historia' : 'View History'),
            style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
          ),
        ]),
      ),
    );
  }
}

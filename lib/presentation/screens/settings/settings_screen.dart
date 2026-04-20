// lib/presentation/screens/settings/settings_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final theme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang == 'sw' ? 'Mipango' : 'Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Language Settings ──────────────────────────
            Text(
              lang == 'sw' ? 'Lugha' : 'Language',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            _SettingCard(
              title: lang == 'sw' ? 'Chagua Lugha' : 'Choose Language',
              children: [
                RadioListTile<String>(
                  title: const Text('🇬🇧 English'),
                  value: 'en',
                  groupValue: lang,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(languageProvider.notifier).state = val;
                    }
                  },
                  activeColor: AppColors.primary,
                ),
                RadioListTile<String>(
                  title: const Text('🇰🇪 Kiswahili'),
                  value: 'sw',
                  groupValue: lang,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(languageProvider.notifier).state = val;
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Appearance Settings ────────────────────────
            Text(
              lang == 'sw' ? 'Muonekano' : 'Appearance',
              style: Theme.of(context).textTheme.headlineSmall,
            ).animate().fadeIn(),
            const SizedBox(height: 12),
            _SettingCard(
              title: lang == 'sw' ? 'Mandhari' : 'Theme',
              children: [
                RadioListTile<String>(
                  title: Text(lang == 'sw' ? '☀️ Mwanga' : '☀️ Light'),
                  value: 'light',
                  groupValue: theme,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(themeProvider.notifier).state = val;
                    }
                  },
                  activeColor: AppColors.primary,
                ),
                RadioListTile<String>(
                  title: Text(lang == 'sw' ? '🌙 Giza' : '🌙 Dark'),
                  value: 'dark',
                  groupValue: theme,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(themeProvider.notifier).state = val;
                    }
                  },
                  activeColor: AppColors.primary,
                ),
                RadioListTile<String>(
                  title: Text(
                    lang == 'sw' ? '⚙️ Sistema' : '⚙️ System Default',
                  ),
                  value: 'system',
                  groupValue: theme,
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(themeProvider.notifier).state = val;
                    }
                  },
                  activeColor: AppColors.primary,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── Current Settings Summary ────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang == 'sw' ? '✓ Mipango Yako' : '✓ Your Settings',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(color: AppColors.primary),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('🗣️', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang == 'sw' ? 'Lugha:' : 'Language:',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            lang == 'sw' ? 'Kiswahili' : 'English',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            lang == 'sw' ? 'Mandhari:' : 'Theme:',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            theme == 'light'
                                ? (lang == 'sw' ? 'Mwanga' : 'Light')
                                : theme == 'dark'
                                    ? (lang == 'sw' ? 'Giza' : 'Dark')
                                    : (lang == 'sw' ? 'Sistema' : 'System'),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkCard.withOpacity(0.5)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

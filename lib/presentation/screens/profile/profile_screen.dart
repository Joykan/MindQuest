// lib/presentation/screens/profile/profile_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/mq_snackbar.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(languageProvider);
    final profile = ref.watch(profileProvider).valueOrNull;
    final stats = ref.watch(userStatsProvider).valueOrNull;
    final badges = ref.watch(userBadgesProvider).valueOrNull ?? [];

    final name = profile?.displayName ?? profile?.username ?? '...';
    final tierColor =
        AppColors.tierColors[stats?.tier ?? 'Newcomer'] ?? AppColors.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // ── App bar ───────────────────────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: Colors.white),
                        ),
                      ).animate().scale(curve: Curves.elasticOut),
                      const SizedBox(height: 12),
                      Text(name,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${stats?.tier ?? 'Newcomer'} • Level ${stats?.level ?? 1}',
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                onPressed: () => _showEditProfile(context, ref, profile, lang),
              ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // XP Progress bar
                if (stats != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 8)
                      ],
                    ),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(lang == 'sw' ? 'Maendeleo ya XP' : 'XP Progress',
                              style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text('${stats.xp} / ${stats.level * 500} XP',
                              style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: stats.levelProgress,
                          backgroundColor: AppColors.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation(tierColor),
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 6),
                       Text(
                        lang == 'sw'
                            ? '${stats.xpToNextLevel} XP hadi ngazi inayofuata'
                            : '${stats.xpToNextLevel} XP to next level',
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ]),
                  ).animate().fadeIn(),
                  const SizedBox(height: 16),
                ],

                // Stats grid
                if (stats != null) ...[
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.0,
                    children: [
                      _StatTile(
                          '🔥',
                          '${stats.streakDays}',
                          lang == 'sw' ? 'Msururu wa Leo' : 'Current Streak',
                          AppColors.warning),
                      _StatTile(
                          '🏆',
                          '${stats.longestStreak}',
                          lang == 'sw'
                              ? 'Msururu Mrefu Zaidi'
                              : 'Longest Streak',
                          AppColors.accent),
                      _StatTile(
                          '💬',
                          '${stats.totalSessions}',
                          lang == 'sw' ? 'Mazungumzo' : 'Chat Sessions',
                          AppColors.primary),
                      _StatTile(
                          '😊',
                          '${stats.totalMoodsLogged}',
                          lang == 'sw' ? 'Hisia Zilizoandikwa' : 'Moods Logged',
                          AppColors.secondary),
                    ],
                  ).animate(delay: 100.ms).fadeIn(),
                  const SizedBox(height: 20),
                ],

                // Recent badges
                if (badges.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       Text(
                          lang == 'sw'
                              ? '🏅 Tuzo za Hivi Karibuni'
                              : '🏅 Recent Badges',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.badges),
                        child: Text(lang == 'sw' ? 'Zote' : 'See All',
                            style: const TextStyle(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: badges.take(5).length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) {
                        final b = badges[i];
                        return Container(
                          width: 72,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🏅', style: TextStyle(fontSize: 28)),
                              Text(
                                lang == 'sw' && b.nameSw != null
                                    ? b.nameSw!
                                    : b.name,
                                style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 9,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Settings tiles
                Text(lang == 'sw' ? '⚙️ Mipangilio' : '⚙️ Settings',
                    style: const TextStyle(fontFamily: 'Nunito', fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 12),

                // Language
                _SettingsTile(
                  icon: '🌍',
                  title: lang == 'sw' ? 'Lugha' : 'Language',
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    _LangBtn('EN', lang == 'en',
                        () => ref.read(languageProvider.notifier).state = 'en'),
                    const SizedBox(width: 8),
                    _LangBtn('SW', lang == 'sw',
                        () => ref.read(languageProvider.notifier).state = 'sw'),
                  ]),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: '🏅',
                  title: lang == 'sw' ? 'Tuzo Zangu' : 'My Badges',
                  onTap: () => context.go(AppRoutes.badges),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: '🎯',
                  title: lang == 'sw' ? 'Dhamira Zangu' : 'My Quests',
                  onTap: () => context.go(AppRoutes.quests),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: '📊',
                  title: lang == 'sw' ? 'Historia ya Hisia' : 'Mood History',
                  onTap: () => context.go(AppRoutes.moodHistory),
                ),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: '🆘',
                  title: lang == 'sw' ? 'Msaada wa Dharura' : 'Crisis Support',
                  onTap: () => context.go(AppRoutes.crisis),
                ),
                const SizedBox(height: 24),

                // Sign out
                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(supabaseServiceProvider).signOut();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  icon:
                      const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: Text(lang == 'sw' ? 'Ondoka' : 'Sign Out',
                      style: const TextStyle(
                          color: AppColors.error, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfile(
      BuildContext ctx, WidgetRef ref, dynamic profile, String lang) {
    if (profile == null) return;
    final nameCtrl = TextEditingController(text: profile.displayName ?? '');
    final bioCtrl = TextEditingController(text: profile.bio ?? '');

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(lang == 'sw' ? 'Hariri Wasifu' : 'Edit Profile',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: lang == 'sw' ? 'Jina la Kuonyesha' : 'Display Name',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bioCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: lang == 'sw' ? 'Kuhusu Mimi' : 'Bio',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await ref.read(supabaseServiceProvider).updateProfile(
                    profile.copyWith(
                        displayName: nameCtrl.text.trim(),
                        bio: bioCtrl.text.trim()),
                  );
              ref.invalidate(profileProvider);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                MQSnackbar.success(ctx,
                    lang == 'sw' ? 'Wasifu umesasishwa!' : 'Profile updated!');
              }
            },
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50)),
            child: Text(lang == 'sw' ? 'Hifadhi' : 'Save'),
          ),
        ]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon, value, label;
  final Color color;
  const _StatTile(this.icon, this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(children: [
          Text(icon, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 10,
                    color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ]),
        ]),
      );
}

class _SettingsTile extends StatelessWidget {
  final String icon, title;
  final VoidCallback? onTap;
  final Widget? trailing;
  const _SettingsTile(
      {required this.icon, required this.title, this.onTap, this.trailing});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)
            ],
          ),
          child: Row(children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
              Expanded(
                  child: Text(title,
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
            trailing ??
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textHint),
          ]),
        ),
      );
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: selected ? AppColors.primary : AppColors.textHint),
          ),
          child: Text(label,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: selected ? Colors.white : AppColors.textHint)),
        ),
      );
}

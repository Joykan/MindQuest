// lib/presentation/screens/resources/resources_screen.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/providers.dart';

class ResourcesScreen extends ConsumerStatefulWidget {
  const ResourcesScreen({super.key});
  @override
  ConsumerState<ResourcesScreen> createState() => _ResourcesScreenState();
}

class _ResourcesScreenState extends ConsumerState<ResourcesScreen> {
  String? _filter;

  static const _categories = [
    'article',
    'exercise',
    'video',
    'helpline',
    'tip',
  ];
  static const _catIcons = {
    'article': '📖',
    'exercise': '🧘',
    'video': '🎥',
    'helpline': '📞',
    'tip': '💡',
  };
  static const _catLabels = {
    'article': 'Articles',
    'exercise': 'Exercises',
    'video': 'Videos',
    'helpline': 'Helplines',
    'tip': 'Tips',
  };
  static const _catLabelsSw = {
    'article': 'Makala',
    'exercise': 'Mazoezi',
    'video': 'Video',
    'helpline': 'Msaada',
    'tip': 'Vidokezo',
  };

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(languageProvider);
    final resources = ref.watch(resourcesProvider);

    return Scaffold(
      appBar: AppBar(
          title:
              Text(lang == 'sw' ? 'Rasilimali za Afya' : 'Wellness Resources')),
      body: Column(children: [
        // Category filter chips
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _FilterChip(
                label: lang == 'sw' ? 'Zote' : 'All',
                icon: '🌟',
                selected: _filter == null,
                onTap: () => setState(() => _filter = null),
              ),
              const SizedBox(width: 8),
              ..._categories.map((c) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: lang == 'sw' ? _catLabelsSw[c]! : _catLabels[c]!,
                      icon: _catIcons[c]!,
                      selected: _filter == c,
                      onTap: () => setState(() => _filter = c),
                    ),
                  )),
            ],
          ),
        ),

        // Resource list
        Expanded(
          child: resources.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (list) {
              final filtered = _filter == null
                  ? list
                  : list.where((r) => r.category == _filter).toList();

              if (filtered.isEmpty) {
                return Center(
                    child: Text(lang == 'sw'
                        ? 'Hakuna rasilimali'
                        : 'No resources found'));
              }

              // Featured first
              final featured = filtered.where((r) => r.isFeatured).toList();
              final regular = filtered.where((r) => !r.isFeatured).toList();

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (featured.isNotEmpty && _filter == null) ...[
                    Text(lang == 'sw' ? '⭐ Zilizoangaziwa' : '⭐ Featured',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    ...featured.asMap().entries.map((e) => _ResourceCard(
                        resource: e.value,
                        lang: lang,
                        i: e.key,
                        onTap: () => _showDetail(context, e.value, lang))),
                    const SizedBox(height: 20),
                    Text(lang == 'sw' ? '📚 Zote' : '📚 All Resources',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                  ],
                  ...regular.asMap().entries.map((e) => _ResourceCard(
                      resource: e.value,
                      lang: lang,
                      i: e.key,
                      onTap: () => _showDetail(context, e.value, lang))),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  void _showDetail(BuildContext ctx, resource, String lang) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.all(24),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.textHint,
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Row(children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                    child: Text(_catIcons[resource.category] ?? '📄',
                        style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 14),
              Expanded(
                  child: Text(
                lang == 'sw' && resource.titleSw != null
                    ? resource.titleSw
                    : resource.title,
                style: Theme.of(ctx).textTheme.headlineMedium,
              )),
            ]),
            const SizedBox(height: 20),
            if (resource.tags?.isNotEmpty == true)
              Wrap(
                  spacing: 8,
                  children: (resource.tags as List<String>)
                      .map((t) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text('#$t',
                                style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    color: AppColors.primary)),
                          ))
                      .toList()),
            const SizedBox(height: 16),
            Text(
              lang == 'sw' && resource.contentSw != null
                  ? resource.contentSw
                  : resource.content ?? '',
              style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(height: 1.7),
            ),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label, icon;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
      {required this.label,
      required this.icon,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textSecondary)),
          ]),
        ),
      );
}

class _ResourceCard extends StatelessWidget {
  final dynamic resource;
  final String lang;
  final int i;
  final VoidCallback onTap;
  const _ResourceCard(
      {required this.resource,
      required this.lang,
      required this.i,
      required this.onTap});

  static const _icons = {
    'article': '📖',
    'exercise': '🧘',
    'video': '🎥',
    'helpline': '📞',
    'tip': '💡',
  };

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8)
            ],
          ),
          child: Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                  child: Text(_icons[resource.category] ?? '📄',
                      style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (resource.isFeatured)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(lang == 'sw' ? 'Iliyoangaziwa' : 'Featured',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 10,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700)),
                  ),
                Text(
                  lang == 'sw' && resource.titleSw != null
                      ? resource.titleSw
                      : resource.title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (resource.tags?.isNotEmpty == true)
                  Text(
                    (resource.tags as List<String>)
                        .take(3)
                        .map((t) => '#$t')
                        .join(' '),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.primary),
                  ),
              ],
            )),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.textHint),
          ]),
        ).animate(delay: Duration(milliseconds: i * 50)).fadeIn(),
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/locale_providers.dart';
import '../habit_editor/editor_parts.dart';

/// Language picker: System, English or Tiếng Việt, each in its own language.
class ConfigLanguageCard extends ConsumerWidget {
  const ConfigLanguageCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appLanguageProvider);
    final labels = {
      AppLanguage.system: context.l10n.configLangSystem,
      AppLanguage.english: 'English',
      AppLanguage.vietnamese: 'Tiếng Việt',
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: AppGlow.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.language, color: AppColors.cyan),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.configLanguage,
                  style: AppTextStyles.headlineSm,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in labels.entries)
                EditorChip(
                  label: entry.value,
                  selected: entry.key == selected,
                  color: AppColors.cyan,
                  onTap: () =>
                      ref.read(appLanguageProvider.notifier).select(entry.key),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

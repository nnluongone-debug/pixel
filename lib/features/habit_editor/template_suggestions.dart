import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/l10n/l10n_labels.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/habit_icons.dart';
import '../../domain/templates/habit_template.dart';
import 'editor_parts.dart';

/// Preset matches for the typed title; tapping one fills the whole form.
class TemplateSuggestions extends StatelessWidget {
  const TemplateSuggestions({
    super.key,
    required this.templates,
    required this.onPicked,
  });

  final List<HabitTemplate> templates;
  final ValueChanged<HabitTemplate> onPicked;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final language = Localizations.localeOf(context).languageCode;
    return EditorPanel(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 2),
            child: Text(
              l10n.editorTemplatesLabel,
              style: AppTextStyles.labelSm.copyWith(color: AppColors.mint),
            ),
          ),
          for (final t in templates)
            _SuggestionRow(
              template: t,
              name: t.nameFor(language),
              detail:
                  '${l10n.cadenceLabel(t.schedule)} • '
                  '${l10n.goalLabel(t.type, t.unit, t.target)}',
              onTap: () => onPicked(t),
            ),
        ],
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({
    required this.template,
    required this.name,
    required this.detail,
    required this.onTap,
  });

  final HabitTemplate template;
  final String name;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.fromHex(template.colorHex);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.6)),
              ),
              child: Icon(
                HabitIcons.of(template.iconName),
                size: 18,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLg,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    detail,
                    style: AppTextStyles.labelSm.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_west, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }
}

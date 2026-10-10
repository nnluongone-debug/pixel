import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/habit_icons.dart';
import '../../data/repositories/habit_repository.dart';
import 'archetype.dart';
import 'editor_parts.dart';

/// Section 01: title input, archetype card and icon matrix.
class IdentitySection extends StatefulWidget {
  const IdentitySection({
    super.key,
    required this.name,
    required this.iconName,
    required this.color,
    required this.errorText,
    required this.onNameChanged,
    required this.onIconChanged,
  });

  final String name;
  final String iconName;
  final Color color;
  final String? errorText;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onIconChanged;

  @override
  State<IdentitySection> createState() => _IdentitySectionState();
}

class _IdentitySectionState extends State<IdentitySection> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.name,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _clear() {
    _controller.clear();
    widget.onNameChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final archetype = Archetype.of(widget.iconName, l10n);
    final hasError = widget.errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EditorSectionHeader(
          tag: l10n.editorIdentityTag,
          title: l10n.editorTitleLabel,
          trailing: l10n.editorMaxChars(HabitRepository.maxNameLength),
        ),
        const SizedBox(height: 10),
        EditorPanel(
          accent: hasError ? AppColors.error : null,
          padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
          child: Row(
            children: [
              Text(
                '>',
                style: AppTextStyles.labelLg.copyWith(color: widget.color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  onChanged: widget.onNameChanged,
                  textInputAction: TextInputAction.done,
                  cursorColor: widget.color,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                      HabitRepository.maxNameLength,
                    ),
                  ],
                  style: AppTextStyles.headlineSm,
                  decoration: InputDecoration(
                    hintText: l10n.editorTitleHint,
                    hintStyle: AppTextStyles.headlineSm.copyWith(
                      color: AppColors.textMuted,
                    ),
                    filled: false,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _controller,
                builder: (_, value, _) => value.text.isEmpty
                    ? const SizedBox(width: 48)
                    : IconButton(
                        tooltip: l10n.editorClearTitle,
                        onPressed: _clear,
                        icon: const Icon(Icons.close, size: 18),
                        color: AppColors.textSecondary,
                      ),
              ),
            ],
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.labelMd.copyWith(color: AppColors.error),
            ),
          ),
        const SizedBox(height: 10),
        _ArchetypeCard(archetype: archetype, color: widget.color),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.editorIconMatrix,
                style: AppTextStyles.labelSm,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${widget.iconName.toUpperCase()}_ACTIVE',
              style: AppTextStyles.labelSm.copyWith(color: widget.color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final entry in HabitIcons.all.entries)
              _IconTile(
                icon: entry.value,
                label: entry.key,
                color: widget.color,
                selected: entry.key == widget.iconName,
                onTap: () => widget.onIconChanged(entry.key),
              ),
          ],
        ),
      ],
    );
  }
}

class _ArchetypeCard extends StatelessWidget {
  const _ArchetypeCard({required this.archetype, required this.color});

  final Archetype archetype;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return EditorPanel(
      accent: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.editorArchetype(archetype.name),
            style: AppTextStyles.labelSm.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(archetype.flavor, style: AppTextStyles.bodyMd),
          const SizedBox(height: 4),
          Text(
            Archetype.mechanics(context.l10n),
            style: AppTextStyles.labelSm.copyWith(color: AppColors.cyan),
          ),
        ],
      ),
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.12)
                : AppColors.surfaceRaised,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? color : AppColors.borderSubtle,
              width: selected ? 2 : 1,
            ),
            boxShadow: selected ? AppGlow.soft(color) : null,
          ),
          child: Icon(icon, color: selected ? color : AppColors.textSecondary),
        ),
      ),
    );
  }
}

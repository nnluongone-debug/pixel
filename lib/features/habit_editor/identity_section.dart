import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/habit_repository.dart';
import '../../domain/templates/habit_template.dart';
import '../../domain/templates/habit_template_catalog.dart';
import 'editor_parts.dart';
import 'icon_picker_grid.dart';
import 'template_suggestions.dart';

/// Section 01: title input with template suggestions and the icon matrix.
class IdentitySection extends StatefulWidget {
  const IdentitySection({
    super.key,
    required this.name,
    required this.iconName,
    required this.color,
    required this.errorText,
    required this.onNameChanged,
    required this.onIconChanged,
    this.onTemplatePicked,
  });

  final String name;
  final String iconName;
  final Color color;
  final String? errorText;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onIconChanged;

  /// Null disables suggestions (e.g. while editing an existing habit).
  final ValueChanged<HabitTemplate>? onTemplatePicked;

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

  void _pick(HabitTemplate template) {
    final name = template.nameFor(Localizations.localeOf(context).languageCode);
    _controller.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
    widget.onTemplatePicked!(template);
    FocusScope.of(context).unfocus();
  }

  void _clear() {
    _controller.clear();
    widget.onNameChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
        if (widget.onTemplatePicked != null)
          ValueListenableBuilder(
            valueListenable: _controller,
            builder: (_, value, _) {
              final matches = HabitTemplateCatalog.suggest(value.text);
              if (matches.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TemplateSuggestions(templates: matches, onPicked: _pick),
              );
            },
          ),
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
        IconPickerGrid(
          selected: widget.iconName,
          color: widget.color,
          onChanged: widget.onIconChanged,
        ),
      ],
    );
  }
}

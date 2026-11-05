import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';
import '../../data/repositories/habit_repository.dart';
import '../../providers/habit_providers.dart';
import '../../providers/reminder_providers.dart';
import 'alerts_section.dart';
import 'cadence_section.dart';
import 'habit_draft.dart';
import 'habit_editor_header.dart';
import 'identity_section.dart';
import 'metaphor_section.dart';

/// New / edit habit modal. Passing [habit] edits it.
abstract final class HabitEditorSheet {
  static Future<void> show(BuildContext context, {Habit? habit}) =>
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _HabitEditorBody(habit: habit),
      );
}

class _HabitEditorBody extends ConsumerStatefulWidget {
  const _HabitEditorBody({this.habit});

  final Habit? habit;

  @override
  ConsumerState<_HabitEditorBody> createState() => _HabitEditorBodyState();
}

class _HabitEditorBodyState extends ConsumerState<_HabitEditorBody> {
  late HabitDraft _draft = widget.habit == null
      ? const HabitDraft()
      : HabitDraft.fromHabit(widget.habit!);
  String? _nameError;
  String? _formError;
  bool _saving = false;

  bool get _isEditing => widget.habit != null;

  static String _draftErrorText(AppLocalizations l10n, HabitDraftError e) =>
      switch (e) {
        HabitDraftError.titleEmpty => l10n.editorErrTitleEmpty,
        HabitDraftError.noDays => l10n.editorErrNoDays,
        HabitDraftError.quota => l10n.editorErrQuota,
        HabitDraftError.window => l10n.editorErrWindow,
      };
  Color get _color => AppColors.fromHex(_draft.colorHex);

  void _update(HabitDraft draft) => setState(() {
    final turnedOn = draft.remindersOn && !_draft.remindersOn;
    _draft = draft;
    _nameError = null;
    _formError = null;
    if (turnedOn) _requestNotificationPermission();
  });

  void _requestNotificationPermission() {
    final container = ProviderScope.containerOf(context);
    container
        .read(reminderServiceProvider)
        .requestPermission()
        .then((_) => container.invalidate(notificationsEnabledProvider));
  }

  Future<void> _submit() async {
    if (_saving) return;
    final l10n = context.l10n;
    final problem = _draft.error;
    if (problem != null) {
      setState(() {
        if (problem == HabitDraftError.titleEmpty) {
          _nameError = l10n.editorErrTitleEmpty;
        } else {
          _formError = _draftErrorText(l10n, problem);
        }
      });
      return;
    }
    setState(() => _saving = true);
    try {
      final controller = ref.read(habitsControllerProvider.notifier);
      final d = _draft;
      final habit = widget.habit;
      if (habit == null) {
        await controller.create(
          name: d.name,
          type: d.type,
          target: d.hasQuota ? d.target : 1,
          colorHex: d.colorHex,
          iconName: d.iconName,
          unit: d.type == HabitType.counter ? d.unit : '',
          schedule: d.schedule,
          reminderTimes: d.savedTimes,
          reminderEvery: d.savedEvery,
          reminderFrom: d.reminderFrom,
          reminderTo: d.reminderTo,
        );
      } else {
        await controller.edit(
          habit.copyWith(
            name: d.name.trim(),
            type: d.type,
            target: d.hasQuota ? d.target : 1,
            colorHex: d.colorHex,
            iconName: d.iconName,
            unit: d.type == HabitType.counter ? d.unit : '',
            schedule: d.schedule,
            reminderTimes: d.savedTimes,
            reminderEvery: d.savedEvery,
            reminderFrom: d.reminderFrom,
            reminderTo: d.reminderTo,
          ),
        );
      }
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.of(context).pop();
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() {
        switch (e.name) {
          case 'name':
            _nameError = l10n.editorErrTitleLength(
              HabitRepository.maxNameLength,
            );
          case 'schedule':
            _formError = l10n.editorErrNoDays;
          case 'target':
            _formError = l10n.editorErrQuota;
          default:
            _formError = l10n.editorSaveFailed('${e.message}');
        }
      });
    } catch (e) {
      if (mounted) setState(() => _formError = l10n.editorSaveFailed('$e'));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxHeight = (media.size.height - media.viewInsets.bottom) * 0.96;
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(color: AppColors.mint.withValues(alpha: 0.7)),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.mint.withValues(alpha: 0.35),
                blurRadius: 18,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              HabitEditorHeader(isEditing: _isEditing),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IdentitySection(
                        name: _draft.name,
                        iconName: _draft.iconName,
                        color: _color,
                        errorText: _nameError,
                        onNameChanged: (v) => _update(_draft.copyWith(name: v)),
                        onIconChanged: (v) =>
                            _update(_draft.copyWith(iconName: v)),
                        onTemplatePicked: _isEditing
                            ? null
                            : (t) => _update(
                                _draft.withTemplate(
                                  t,
                                  Localizations.localeOf(context).languageCode,
                                ),
                              ),
                      ),
                      const SizedBox(height: 24),
                      MetaphorSection(
                        color: _color,
                        onColorChanged: (c) => _update(
                          _draft.copyWith(colorHex: AppColors.toHex(c)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      CadenceSection(
                        draft: _draft,
                        color: _color,
                        onChanged: _update,
                      ),
                      const SizedBox(height: 24),
                      AlertsSection(
                        draft: _draft,
                        color: _color,
                        onChanged: _update,
                      ),
                    ],
                  ),
                ),
              ),
              _SaveBar(
                isEditing: _isEditing,
                saving: _saving,
                error: _formError,
                bottomInset: media.viewInsets.bottom > 0
                    ? 0
                    : media.padding.bottom,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Footer pinned below the scrolling form so the CTA is always reachable.
class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.isEditing,
    required this.saving,
    required this.error,
    required this.bottomInset,
    required this.onPressed,
  });

  final bool isEditing;
  final bool saving;
  final String? error;
  final double bottomInset;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottomInset),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: saving ? null : onPressed,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      isEditing
                          ? context.l10n.editorSaveChanges
                          : context.l10n.editorCreate,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.headlineSm.copyWith(
                        color: AppColors.textOnNeon,
                      ),
                    ),
                  ),
                  if (!isEditing) ...[
                    const SizedBox(width: 6),
                    const Icon(Icons.bolt_rounded, color: AppColors.textOnNeon),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ??
                (isEditing
                    ? context.l10n.editorEditHint
                    : context.l10n.editorCreateHint),
            textAlign: TextAlign.center,
            style: AppTextStyles.labelSm.copyWith(
              color: error == null ? AppColors.textMuted : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

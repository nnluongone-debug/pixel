import 'package:flutter/material.dart';

import '../../core/l10n/l10n.dart';
import '../../core/theme/app_theme.dart';
import '../locker/locker_entry_card.dart';
import 'config_language_card.dart';
import 'config_notifications_card.dart';
import 'config_sound_card.dart';
import 'love_demo_card.dart';

/// Config tab: language, sound, brick themes, notifications and reminders.
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      children: [
        Text(context.l10n.configTitle, style: AppTextStyles.headlineLg),
        const SizedBox(height: 16),
        const ConfigLanguageCard(),
        const SizedBox(height: 24),
        const ConfigSoundCard(),
        const SizedBox(height: 24),
        const LockerEntryCard(),
        const SizedBox(height: 24),
        const ConfigNotificationsCard(),
        const SizedBox(height: 24),
        const LoveDemoCard(),
      ],
    );
  }
}

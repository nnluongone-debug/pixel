import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/habit.dart';
import '../l10n/app_localizations.dart';
import 'reminder_plan.dart';

/// Initializes the reminder service; call once from `main` before `runApp`.
Future<void> initializeReminders() => ReminderService.instance.initialize();

/// Schedules one repeating local notification per due weekday of each habit
/// that has a reminder. Every public method is safe to call before (or
/// without) successful initialization and never throws: failures are logged
/// and surface as "not scheduled" / "not enabled".
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  static const _testId = 0x7FFFFF00;
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'habit_reminders',
      'Habit reminders',
      channelDescription: 'Daily prompts for habits with a reminder time',
      importance: Importance.defaultImportance,
    ),
    iOS: DarwinNotificationDetails(),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Future<void> _queue = Future.value();
  List<ReminderEntry>? _scheduled;

  bool get isReady => _ready;

  /// Device zone, or UTC when the platform reports an unknown/legacy id,
  /// so reminders still work (possibly offset) instead of all failing.
  Future<void> _setLocalZone() async {
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (e) {
      debugPrint('Unknown time zone, reminders use UTC: $e');
      tz.setLocalLocation(tz.UTC);
    }
  }

  Future<void> initialize() async {
    if (_ready) return;
    try {
      tz_data.initializeTimeZones();
      await _setLocalZone();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permission is requested when a reminder is first enabled.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (e, st) {
      debugPrint('Reminder init failed: $e\n$st');
    }
  }

  /// Asks the OS for notification permission; true when granted.
  Future<bool> requestPermission() async {
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, sound: true) ?? false;
      }
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    } catch (e) {
      debugPrint('Reminder permission request failed: $e');
      return false;
    }
  }

  /// Whether the OS currently allows this app to show notifications.
  Future<bool> areNotificationsEnabled() async {
    try {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        return (await ios.checkPermissions())?.isEnabled ?? false;
      }
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.areNotificationsEnabled() ?? false;
    } catch (e) {
      debugPrint('Reminder permission check failed: $e');
      return false;
    }
  }

  /// Replaces all scheduled reminders with the ones [habits] call for.
  /// Calls are serialized and a no-op when the plan has not changed.
  Future<void> reschedule(Iterable<Habit> habits, AppLocalizations l10n) {
    final plan = capReminderPlan(
      buildReminderPlan(habits, l10n),
      DateTime.now(),
    );
    return _queue = _queue.then((_) => _apply(plan));
  }

  Future<void> _apply(List<ReminderEntry> plan) async {
    if (!_ready || listEquals(plan, _scheduled)) return;
    try {
      // Pick up a zone change (travel) before computing fire times.
      await _setLocalZone();
      await _plugin.cancelAllPendingNotifications();
      final now = tz.TZDateTime.now(tz.local);
      for (final entry in plan) {
        final next = nextReminderTime(
          now,
          weekday: entry.weekday,
          minutes: entry.minutes,
        );
        await _plugin.zonedSchedule(
          id: entry.id,
          title: entry.title,
          body: entry.body,
          scheduledDate: tz.TZDateTime(
            tz.local,
            next.year,
            next.month,
            next.day,
            next.hour,
            next.minute,
          ),
          notificationDetails: _details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: entry.weekday == null
              ? DateTimeComponents.time
              : DateTimeComponents.dayOfWeekAndTime,
        );
      }
      _scheduled = plan;
    } catch (e, st) {
      _scheduled = null;
      debugPrint('Reminder scheduling failed: $e\n$st');
    }
  }

  /// Shows a notification immediately; false when it could not be posted.
  Future<bool> showTestPrompt(AppLocalizations l10n) async {
    if (!_ready) return false;
    try {
      await _plugin.show(
        id: _testId,
        title: reminderTitle,
        body: l10n.reminderTest,
        notificationDetails: _details,
      );
      return true;
    } catch (e) {
      debugPrint('Test prompt failed: $e');
      return false;
    }
  }
}

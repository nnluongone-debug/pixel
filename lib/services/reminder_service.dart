import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/habit.dart';
import '../l10n/app_localizations.dart';
import 'reminder_plan.dart';
import 'reminder_time_zone.dart';

/// Initializes the reminder service; call once from `main` before `runApp`.
Future<void> initializeReminders() => ReminderService.instance.initialize();

/// Schedules one repeating local notification per due weekday of each habit
/// that has a reminder. Every public method is safe to call before (or
/// without) successful initialization and never throws: failures are logged
/// and surface as "not scheduled" / "not enabled".
class ReminderService {
  ReminderService._();

  static final ReminderService instance = ReminderService._();

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'habit_reminders',
      'Habit reminders',
      channelDescription: 'Daily prompts for habits with a reminder time',
      importance: Importance.high,
      priority: Priority.high,
    ),
    // Explicit so prompts also show as banners while the app is open.
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBanner: true,
      presentList: true,
      presentSound: true,
    ),
  );

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;
  Future<void> _queue = Future.value();
  List<ReminderEntry>? _scheduled;
  bool _permissionAsked = false;
  final StreamController<String> _taps = StreamController.broadcast();

  bool get isReady => _ready;

  /// Habit ids of prompts the user tapped while the app was running.
  Stream<String> get tappedHabitIds => _taps.stream;

  /// Habit id of the prompt that cold-started the app, if any.
  Future<String?> launchHabitId() async {
    if (!_ready) return null;
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details?.didNotificationLaunchApp != true) return null;
      return _habitIdOf(details!.notificationResponse);
    } catch (e) {
      debugPrint('Reminder launch details failed: $e');
      return null;
    }
  }

  static String? _habitIdOf(NotificationResponse? response) {
    final id = response?.payload;
    return id == null || id.isEmpty ? null : id;
  }

  void _onTap(NotificationResponse response) {
    final id = _habitIdOf(response);
    if (id != null) _taps.add(id);
  }

  /// Device zone, or UTC when the platform reports an unknown/legacy id,
  /// so reminders still work (possibly offset) instead of all failing.
  Future<void> _setLocalZone() async {
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(
        resolveLocalLocation(zone.identifier, now: DateTime.now()),
      );
    } catch (e) {
      debugPrint('Time zone lookup failed, matching by UTC offset: $e');
      tz.setLocalLocation(resolveLocalLocation(null, now: DateTime.now()));
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
        onDidReceiveNotificationResponse: _onTap,
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
      // Prompts are silently dropped without permission, so ask once per
      // session as soon as there is something to schedule.
      if (plan.isNotEmpty && !_permissionAsked) {
        _permissionAsked = true;
        await requestPermission();
      }
      await _plugin.cancelAllPendingNotifications();
      final now = _wallClock(tz.TZDateTime.now(tz.local));
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
          // Tapping the prompt opens this habit's detail page.
          payload: entry.habitId,
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

  /// Wall-clock fields of [zoned] as a plain DateTime, so next-fire math is
  /// done in the scheduling zone rather than the device zone.
  static DateTime _wallClock(tz.TZDateTime zoned) => DateTime(
    zoned.year,
    zoned.month,
    zoned.day,
    zoned.hour,
    zoned.minute,
    zoned.second,
  );

  /// What the OS actually holds: pending count (real data from the plugin)
  /// and the soonest fire time among our scheduled entries.
  Future<ReminderSummary> summary() async {
    if (!_ready) return const ReminderSummary(0, null);
    try {
      await _queue; // let an in-flight reschedule finish first
      final pending = await _plugin.pendingNotificationRequests();
      final ids = {for (final p in pending) p.id};
      final now = _wallClock(tz.TZDateTime.now(tz.local));
      DateTime? next;
      for (final e in _scheduled ?? const <ReminderEntry>[]) {
        if (!ids.contains(e.id)) continue;
        final t = nextReminderTime(now, weekday: e.weekday, minutes: e.minutes);
        if (next == null || t.isBefore(next)) next = t;
      }
      return ReminderSummary(ids.length, next);
    } catch (e) {
      debugPrint('Reminder summary failed: $e');
      return const ReminderSummary(0, null);
    }
  }
}

/// Pending prompt count and the soonest scheduled wall-clock time.
class ReminderSummary {
  const ReminderSummary(this.pending, this.next);

  final int pending;
  final DateTime? next;
}

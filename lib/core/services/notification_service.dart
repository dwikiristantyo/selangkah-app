import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

abstract final class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (!_supportsLocalNotifications) return;

    timezone_data.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(localTimezone.identifier));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      'memorial_reminders',
      'Pengingat doa',
      description: 'Pengingat jadwal doa dan peringatan keluarga.',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    _isInitialized = true;
  }

  static Future<ReminderSetupResult> scheduleReminders({
    required List<LocalReminder> reminders,
  }) async {
    if (!_supportsLocalNotifications) {
      return const ReminderSetupResult(
        isSupported: false,
        permissionGranted: false,
        scheduledCount: 0,
      );
    }
    if (!_isInitialized) {
      throw StateError('NotificationService belum diinisialisasi.');
    }

    final permissionGranted = await _requestPermission();
    if (!permissionGranted) {
      return const ReminderSetupResult(
        isSupported: true,
        permissionGranted: false,
        scheduledCount: 0,
      );
    }

    final now = timezone.TZDateTime.now(timezone.local);
    var scheduledCount = 0;
    for (final reminder in reminders) {
      final date = reminder.date;
      final scheduledDate = timezone.TZDateTime(
        timezone.local,
        date.year,
        date.month,
        date.day,
        9,
      );
      if (!scheduledDate.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        _notificationId(reminder.id),
        reminder.title,
        reminder.body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'memorial_reminders',
            'Pengingat doa',
            channelDescription: 'Pengingat jadwal doa dan peringatan keluarga.',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: reminder.id,
      );
      scheduledCount++;
    }

    return ReminderSetupResult(
      isSupported: true,
      permissionGranted: true,
      scheduledCount: scheduledCount,
    );
  }

  static Future<bool> _requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }

    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return false;
  }

  static int _notificationId(String value) {
    var hash = 0;
    for (final unit in value.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }

  static bool get _supportsLocalNotifications =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}

class LocalReminder {
  const LocalReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.date,
  });

  final String id;
  final String title;
  final String body;
  final DateTime date;
}

class ReminderSetupResult {
  const ReminderSetupResult({
    required this.isSupported,
    required this.permissionGranted,
    required this.scheduledCount,
  });

  final bool isSupported;
  final bool permissionGranted;
  final int scheduledCount;
}

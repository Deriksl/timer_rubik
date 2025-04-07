import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timer_rubik/providers/times_providers.dart';

class NotificationService {
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Notificaciones básicas',
          channelDescription: 'Canal para notificaciones generales',
          defaultColor: Colors.blue,
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          soundSource: 'resource://raw/notification_sound',
          criticalAlerts: true,
        ),
        NotificationChannel(
          channelGroupKey: 'records_channel_group',
          channelKey: 'records_channel',
          channelName: 'Notificaciones de récords',
          channelDescription: 'Notificaciones para nuevos récords personales',
          defaultColor: Colors.green,
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          soundSource: 'resource://raw/record_sound',
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Grupo básico'
        ),
        NotificationChannelGroup(
          channelGroupKey: 'records_channel_group',
          channelGroupName: 'Grupo de récords'
        )
      ],
      debug: true
    );

    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default, // Corregido aquí
      ),
    );
  }

  static Future<void> scheduleDailyReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: '¡Hora de practicar!',
        body: 'No olvides practicar con tu cubo Rubik hoy',
        notificationLayout: NotificationLayout.Default, // Corregido aquí
      ),
      schedule: NotificationCalendar(
        hour: 19,
        minute: 0,
        second: 0,
        repeats: true,
        allowWhileIdle: true,
      ),
    );
  }

  static Future<void> checkAndNotifyNewRecord(
      TimesProvider timesProvider) async {
    if (timesProvider.times.isEmpty) return;

    final currentTime = double.parse(timesProvider.times.last['time']);
    final times = timesProvider.times.map((t) => double.parse(t['time'])).toList();
    final pb = times.reduce((a, b) => a < b ? a : b);

    if (currentTime == pb) {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          channelKey: 'records_channel',
          title: '¡Nuevo récord personal! 🎉',
          body: 'Has establecido un nuevo PB: ${currentTime.toStringAsFixed(2)} segundos',
          notificationLayout: NotificationLayout.BigText, // Corregido aquí
          payload: {'type': 'new_record'},
        ),
      );
    }
  }

  static Future<void> showNotificationWithCustomSound({
    required String title,
    required String body,
    required String soundFile,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        channelKey: 'records_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default, // Corregido aquí
      ),
    );
  }
}
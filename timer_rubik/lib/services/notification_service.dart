import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timer_rubik/providers/times_providers.dart';

/// Servicio para gestionar todas las notificaciones de la app.
class NotificationService {
  
  /// Inicializa los canales de notificación y solicita permiso si es necesario.
  static Future<void> initializeNotifications() async {
    await AwesomeNotifications().initialize(
      null,
      [
        // Canal para notificaciones generales
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
        // Canal para notificaciones relacionadas con récords personales
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

    // Solicita permiso para enviar notificaciones si no está permitido
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  /// Muestra una notificación simple con título y cuerpo.
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
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  /// Programa un recordatorio diario a las 7:00 PM para motivar al usuario.
  static Future<void> scheduleDailyReminder() async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'basic_channel',
        title: '¡Hora de practicar!',
        body: 'No olvides practicar con tu cubo Rubik hoy',
        notificationLayout: NotificationLayout.Default,
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

  /// Verifica si el último tiempo registrado es un nuevo PB (Personal Best)
  /// y si lo es, lanza una notificación celebrando el nuevo récord.
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
          notificationLayout: NotificationLayout.BigText,
          payload: {'type': 'new_record'},
        ),
      );
    }
  }

  /// Muestra una notificación con sonido personalizado.
  /// Aunque recibe un archivo de sonido como parámetro, actualmente no lo utiliza.
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
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }
}

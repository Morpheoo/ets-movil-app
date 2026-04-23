import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../features/ets/domain/entities/ets_entity.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // We use a generic app icon (mipmap/ic_launcher) for Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
        
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    // Request permissions for Android 13+
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> scheduleEtsReminder(EtsEntity ets) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'ets_reminder_channel',
        'Recordatorios de ETS',
        channelDescription: 'Canal para recordatorios de exámenes ETS',
        importance: Importance.high,
        priority: Priority.high,
      );
      const iosDetails = DarwinNotificationDetails();
      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
      
      final id = ets.id.hashCode;
      
      // We want to schedule 1 day before the exam.
      final scheduledDate = ets.date.subtract(const Duration(days: 1));
      
      // If the scheduledDate is in the past, don't schedule
      if (scheduledDate.isBefore(DateTime.now())) {
        return;
      }
      
      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
      
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Recordatorio de ETS: ${ets.subject}',
        'Mañana es tu examen ETS de ${ets.subject} en el salón ${ets.classroom}.',
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      // Ignored intentionally, or use a proper logger instead of print
    }
  }

  Future<void> cancelReminder(String id) async {
    await _flutterLocalNotificationsPlugin.cancel(id.hashCode);
  }
}

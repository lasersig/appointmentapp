import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('app_icon');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);
  }

  static Future<void> showAppointmentNotification({
    required String appointmentId,
    required String doctorName,
    required DateTime dateTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointment Notifications',
      channelDescription: 'Notifications for appointment updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notifications.show(
      appointmentId.hashCode,
      'New Appointment Booked',
      'Appointment with $doctorName on ${dateTime.toString().substring(0, 16)}',
      notificationDetails,
    );
  }

  static Future<void> showAppointmentStatusNotification({
    required String appointmentId,
    required String doctorName,
    required String status,
    required DateTime dateTime,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointment Notifications',
      channelDescription: 'Notifications for appointment updates',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _notifications.show(
      appointmentId.hashCode,
      'Appointment $status',
      'Your appointment with $doctorName on ${dateTime.toString().substring(0, 16)} has been $status.',
      notificationDetails,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import 'app.dart';
import 'models/doctor.dart';
import 'models/work_day.dart';
import 'models/appointment.dart';
import 'models/user_session.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(DoctorAdapter());
  Hive.registerAdapter(WorkDayAdapter());
  Hive.registerAdapter(AppointmentAdapter());
  Hive.registerAdapter(UserSessionAdapter());

  await Hive.openBox<Doctor>('doctors');
  await Hive.openBox<Appointment>('appointments');
  await Hive.openBox<UserSession>('session');
  await Hive.openBox('reminders');

  // Initialize timezone
  tz.initializeTimeZones();
  final location = tz.getLocation('Europe/Bucharest'); // EEST
  tz.setLocalLocation(location);
  debugPrint('Device timezone: ${DateTime.now().timeZoneName}, offset: ${DateTime.now().timeZoneOffset}');

  // Initialize notifications
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  const androidInitSettings = AndroidInitializationSettings('app_icon');
  const initializationSettings = InitializationSettings(
    android: androidInitSettings,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Request notification and exact alarm permissions for Android 13+
  final androidPlugin = flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  final notificationsGranted = await androidPlugin?.requestNotificationsPermission();
  final alarmsGranted = await androidPlugin?.requestExactAlarmsPermission();
  debugPrint('Notifications permission: $notificationsGranted, Alarms permission: $alarmsGranted');

  // Clear Hive data (optional, comment out if not needed for testing)
  await clearHiveData();

  runApp(const App());
}

Future<void> clearHiveData() async {
  await Hive.box<Doctor>('doctors').clear();
  await Hive.box<Appointment>('appointments').clear();
  await Hive.box<UserSession>('session').clear();
  await Hive.box('reminders').clear();
  debugPrint('Cleared all Hive data');
}
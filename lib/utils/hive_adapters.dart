import 'package:hive_flutter/hive_flutter.dart';
import '../models/doctor.dart';
import '../models/work_day.dart';
import '../models/appointment.dart';
import '../models/user_session.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(DoctorAdapter());
  Hive.registerAdapter(WorkDayAdapter());
  Hive.registerAdapter(AppointmentAdapter());
  Hive.registerAdapter(UserSessionAdapter());
}
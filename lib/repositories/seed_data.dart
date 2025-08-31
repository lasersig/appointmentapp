import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/doctor.dart';
import '../models/work_day.dart';

class SeedData {
  static Future<void> initializeDoctors() async {
    final box = Hive.box<Doctor>('doctors');
    if (box.isNotEmpty) {
      print('Doctors box already seeded: ${box.values.map((d) => "${d.name} (${d.specialty})").toList()}');
      return;
    }
    try {
      print('Loading seed_doctors.json');
      final String jsonString = await rootBundle.loadString('assets/seed/seed_doctors.json');
      print('Raw JSON: $jsonString');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final List<dynamic> doctorsJson = jsonData['doctors'];
      print('Parsed ${doctorsJson.length} doctors from JSON');
      final List<Doctor> doctors = doctorsJson.map((json) {
        return Doctor(
          id: json['id'] as String,
          name: json['name'] as String,
          specialty: json['specialty'] as String,
          avatarUrl: json['avatarUrl'] as String,
          workDays: (json['workDays'] as List<dynamic>).map((workDayJson) {
            return WorkDay(
              weekday: workDayJson['weekday'] as int,
              slots: List<String>.from(workDayJson['slots']),
            );
          }).toList(),
        );
      }).toList();
      for (final doctor in doctors) {
        await box.put(doctor.id, doctor);
        print('Seeded doctor: ${doctor.name} (${doctor.specialty})');
      }
      print('Seeding complete. Doctors box now has: ${box.values.map((d) => "${d.name} (${d.specialty})").toList()}');
    } catch (e, stackTrace) {
      print('Error seeding doctors: $e');
      print('Stack trace: $stackTrace');
    }
  }
}
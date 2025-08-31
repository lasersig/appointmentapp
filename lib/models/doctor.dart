import 'package:hive/hive.dart';
import 'work_day.dart';

part 'doctor.g.dart';

@HiveType(typeId: 0)
class Doctor {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String specialty;

  @HiveField(3)
  final String avatarUrl;

  @HiveField(4)
  final List<WorkDay> workDays;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.workDays,
  });
}
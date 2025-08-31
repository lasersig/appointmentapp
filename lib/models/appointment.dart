import 'package:hive/hive.dart';

part 'appointment.g.dart';

@HiveType(typeId: 2)
class Appointment {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String doctorId;

  @HiveField(2)
  final String userId; // From session, for simplicity

  @HiveField(3)
  final DateTime dateTime;

  @HiveField(4)
  final String status; // pending, approved, declined, completed, canceled

  @HiveField(5)
  final DateTime createdAt;

  Appointment({
    required this.id,
    required this.doctorId,
    required this.userId,
    required this.dateTime,
    required this.status,
    required this.createdAt,
  });
}
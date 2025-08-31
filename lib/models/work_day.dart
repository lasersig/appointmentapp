import 'package:hive/hive.dart';
part 'work_day.g.dart';

@HiveType(typeId: 1)
class WorkDay {
  @HiveField(0)
  final int weekday;
  @HiveField(1)
  final List<String> slots;

  WorkDay({required this.weekday, required this.slots});

  String get weekdayName {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday];
  }
}
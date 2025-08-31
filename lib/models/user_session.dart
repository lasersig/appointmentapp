import 'package:hive/hive.dart';

part 'user_session.g.dart';

@HiveType(typeId: 3)
class UserSession {
  @HiveField(0)
  final String phone;

  @HiveField(1)
  final bool loggedIn;

  @HiveField(2)
  final String? name;

  @HiveField(3)
  final String? email;

  UserSession({
    required this.phone,
    required this.loggedIn,
    this.name,
    this.email,
  });
}
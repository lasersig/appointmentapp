import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../models/user_session.dart';
import '../../constants/routes.dart';
import '../../providers/appointment_provider.dart';
import 'package:uuid/uuid.dart';

class ConfirmBookingScreen extends ConsumerWidget {
  const ConfirmBookingScreen({super.key});

  Future<bool> _checkIfSlotBooked(
    WidgetRef ref,
    String doctorId,
    DateTime dateTime,
  ) async {
    final appointments = ref.read(appointmentProvider);
    return appointments.any(
      (appointment) =>
          appointment.doctorId == doctorId &&
          appointment.dateTime.year == dateTime.year &&
          appointment.dateTime.month == dateTime.month &&
          appointment.dateTime.day == dateTime.day &&
          appointment.dateTime.hour == dateTime.hour &&
          appointment.dateTime.minute == dateTime.minute &&
          ['pending', 'approved'].contains(appointment.status),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    final Doctor doctor = args['doctor'] as Doctor;
    final DateTime dateTime = args['dateTime'] as DateTime;
    final String day = DateFormat('EEEE').format(dateTime);
    final String time = DateFormat('h:mm a').format(dateTime);
    final userSession = Hive.box<UserSession>('session').get('user');
    final userId = userSession?.phone ?? 'unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Doctor: ${doctor.name}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: const Color(0xFF1976D2),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Day: $day',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Time: $time',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final isSlotBooked = await _checkIfSlotBooked(
                        ref,
                        doctor.id,
                        dateTime,
                      );
                      if (isSlotBooked) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'This time slot is already booked. Please choose another.',
                            ),
                          ),
                        );
                        return;
                      }
                      final appointment = Appointment(
                        id: const Uuid().v4(),
                        doctorId: doctor.id,
                        userId: userId,
                        dateTime: dateTime,
                        status: 'pending',
                        createdAt: DateTime.now(),
                      );
                      debugPrint('Booking appointment: $appointment');
                      await ref
                          .read(appointmentProvider.notifier)
                          .addAppointment(appointment);
                      debugPrint('Appointment saved to Hive');
                      final notificationsPlugin =
                          FlutterLocalNotificationsPlugin();
                      await notificationsPlugin.show(
                        0,
                        'Appointment Confirmed',
                        'Your appointment with ${doctor.name} on $day at $time is booked.',
                        const NotificationDetails(
                          android: AndroidNotificationDetails(
                            'appointment_channel',
                            'Appointments',
                            importance: Importance.high,
                          ),
                        ),
                      );
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.homeTabs,
                      );
                    } catch (e) {
                      debugPrint('Booking error: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to book appointment: $e'),
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

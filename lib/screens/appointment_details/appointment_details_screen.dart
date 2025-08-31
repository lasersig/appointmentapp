import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/user_session.dart';
import '../../providers/appointment_provider.dart';
import '../../constants/routes.dart';

class AppointmentDetailsScreen extends ConsumerWidget {
  const AppointmentDetailsScreen({super.key});

  Future<bool?> _showConfirmationDialog(BuildContext context, String action) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm $action',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontFamily: 'Inter',
            color: const Color(0xFF1976D2),
          ),
        ),
        content: Text(
          'Are you sure you want to $action this appointment?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'No',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.grey[600],
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Color(0xFF1976D2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _rescheduleAppointment(BuildContext context, WidgetRef ref, Appointment appointment, Doctor doctor) async {
    final confirmed = await _showConfirmationDialog(context, 'reschedule');
    if (confirmed != true) return;

    final newDateTime = await Navigator.pushNamed(
      context,
      AppRoutes.selectDateTime,
      arguments: doctor,
    ) as Map?;

    if (newDateTime != null) {
      final updated = Appointment(
        id: appointment.id,
        doctorId: appointment.doctorId,
        userId: appointment.userId,
        dateTime: DateTime(
          newDateTime['selectedDate'].year,
          newDateTime['selectedDate'].month,
          newDateTime['selectedDate'].day,
          DateFormat('h:mm a').parse(newDateTime['time']).hour,
          DateFormat('h:mm a').parse(newDateTime['time']).minute,
        ),
        status: 'pending',
        createdAt: appointment.createdAt,
      );
      await ref.read(appointmentProvider.notifier).updateAppointment(updated);
      final notificationsPlugin = FlutterLocalNotificationsPlugin();
      await notificationsPlugin.show(
        0,
        'Appointment Rescheduled',
        'Your appointment with ${doctor.name} has been rescheduled to ${DateFormat('MMM d, yyyy h:mm a').format(updated.dateTime)}.',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_channel',
            'Appointments',
            importance: Importance.high,
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentId = ModalRoute.of(context)!.settings.arguments as String?;
    if (appointmentId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Appointment Details'),
          automaticallyImplyLeading: true,
        ),
        body: const Center(
          child: Text(
            'No appointment selected',
            style: TextStyle(fontFamily: 'Inter', fontSize: 16),
          ),
        ),
      );
    }

    return ValueListenableBuilder(
      valueListenable: Hive.box<UserSession>('session').listenable(),
      builder: (context, Box<UserSession> sessionBox, _) {
        final userSession = sessionBox.get('user');
        final userId = userSession?.phone ?? 'unknown';
        debugPrint('AppointmentDetailsScreen: userId = $userId, appointmentId = $appointmentId');

        return ValueListenableBuilder(
          valueListenable: Hive.box<Appointment>('appointments').listenable(),
          builder: (context, Box<Appointment> appointmentsBox, _) {
            final appointment = appointmentsBox.get(appointmentId);
            if (appointment == null || appointment.userId != userId) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Appointment Details'),
                  automaticallyImplyLeading: true,
                ),
                body: const Center(
                  child: Text(
                    'Appointment not found or unauthorized',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16),
                  ),
                ),
              );
            }

            return ValueListenableBuilder(
              valueListenable: Hive.box<Doctor>('doctors').listenable(),
              builder: (context, Box<Doctor> doctorsBox, _) {
                final doctor = doctorsBox.get(appointment.doctorId);
                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Appointment Details'),
                    automaticallyImplyLeading: true,
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
                              'Doctor: ${doctor?.name ?? 'Unknown'}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                color: const Color(0xFF1976D2),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Date: ${DateFormat('MMM d, yyyy').format(appointment.dateTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Time: ${DateFormat('h:mm a').format(appointment.dateTime)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Status: ${appointment.status}',
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            if (appointment.status == 'pending' || appointment.status == 'approved') ...[
                              ElevatedButton(
                                onPressed: () async {
                                  await _rescheduleAppointment(context, ref, appointment, doctor!);
                                },
                                child: const Text('Reschedule'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final confirmed = await _showConfirmationDialog(context, 'cancel');
                                  if (confirmed != true) return;

                                  final updated = Appointment(
                                    id: appointment.id,
                                    doctorId: appointment.doctorId,
                                    userId: appointment.userId,
                                    dateTime: appointment.dateTime,
                                    status: 'cancelled',
                                    createdAt: appointment.createdAt,
                                  );
                                  await ref.read(appointmentProvider.notifier).updateAppointment(updated);
                                  final notificationsPlugin = FlutterLocalNotificationsPlugin();
                                  await notificationsPlugin.show(
                                    0,
                                    'Appointment Canceled',
                                    'Your appointment with ${doctor?.name ?? 'Unknown'} on ${DateFormat('MMM d, yyyy h:mm a').format(appointment.dateTime)} was canceled.',
                                    const NotificationDetails(
                                      android: AndroidNotificationDetails(
                                        'appointment_channel',
                                        'Appointments',
                                        importance: Importance.high,
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text('Cancel Appointment'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  final confirmed = await _showConfirmationDialog(context, 'mark as completed');
                                  if (confirmed != true) return;

                                  final updated = Appointment(
                                    id: appointment.id,
                                    doctorId: appointment.doctorId,
                                    userId: appointment.userId,
                                    dateTime: appointment.dateTime,
                                    status: 'completed',
                                    createdAt: appointment.createdAt,
                                  );
                                  await ref.read(appointmentProvider.notifier).updateAppointment(updated);
                                  final notificationsPlugin = FlutterLocalNotificationsPlugin();
                                  await notificationsPlugin.show(
                                    0,
                                    'Appointment Completed',
                                    'Your appointment with ${doctor?.name ?? 'Unknown'} on ${DateFormat('MMM d, yyyy h:mm a').format(appointment.dateTime)} is completed.',
                                    const NotificationDetails(
                                      android: AndroidNotificationDetails(
                                        'appointment_channel',
                                        'Appointments',
                                        importance: Importance.high,
                                      ),
                                    ),
                                  );
                                  Navigator.pop(context);
                                },
                                child: const Text('Mark as Completed'),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
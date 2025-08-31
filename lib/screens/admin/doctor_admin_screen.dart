import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../models/appointment.dart';
import '../../models/user_session.dart';
import '../../models/doctor.dart';
import '../../providers/appointment_provider.dart';

class DoctorAdminScreen extends ConsumerStatefulWidget {
  const DoctorAdminScreen({super.key});

  @override
  _DoctorAdminScreenState createState() => _DoctorAdminScreenState();
}

class _DoctorAdminScreenState extends ConsumerState<DoctorAdminScreen> {
  bool _showAllAppointments = false;

  Future<void> _scheduleReminder(Appointment appointment, FlutterLocalNotificationsPlugin notificationsPlugin) async {
    final doctorsBox = Hive.box<Doctor>('doctors');
    final remindersBox = Hive.box('reminders');
    final doctor = doctorsBox.get(appointment.doctorId);
    final reminderId = appointment.id.hashCode;
    final reminderTime = appointment.dateTime.subtract(const Duration(hours: 1));

    if (!remindersBox.containsKey(reminderId)) {
      await notificationsPlugin.zonedSchedule(
        reminderId,
        'Appointment Reminder',
        'Your appointment with ${doctor?.name ?? 'Unknown'} is at ${DateFormat('MMM d, yyyy h:mm a').format(appointment.dateTime)}.',
        tz.TZDateTime.from(reminderTime, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            'appointment_reminder_channel',
            'Appointment Reminders',
            channelDescription: 'Reminders for upcoming appointments',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      await remindersBox.put(reminderId, appointment.id);
      debugPrint('Scheduled reminder for appointment ${appointment.id} at $reminderTime for patient ${appointment.userId}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserSession>('session').listenable(),
      builder: (context, Box<UserSession> sessionBox, _) {
        final userSession = sessionBox.get('user');
        final doctorId = userSession?.phone ?? 'unknown';
        debugPrint('DoctorAdminScreen: doctorId = $doctorId');

        return ValueListenableBuilder(
          valueListenable: Hive.box<Appointment>('appointments').listenable(),
          builder: (context, Box<Appointment> appointmentsBox, _) {
            final today = DateTime.now().toLocal();
            final weekStart = today.subtract(Duration(days: today.weekday % 7)); // Sunday
            final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
            final todayAppointments = appointmentsBox.values
                .where((appt) =>
            appt.doctorId == doctorId &&
                appt.dateTime.year == today.year &&
                appt.dateTime.month == today.month &&
                appt.dateTime.day == today.day)
                .length;
            final weekAppointments = appointmentsBox.values
                .where((appt) =>
            appt.doctorId == doctorId &&
                appt.dateTime.isAfter(weekStart) &&
                appt.dateTime.isBefore(weekEnd))
                .length;
            final appointments = appointmentsBox.values.where((appointment) {
              debugPrint('Checking appointment: id=${appointment.id}, doctorId=${appointment.doctorId}, dateTime=${appointment.dateTime}');
              if (_showAllAppointments) {
                return appointment.doctorId == doctorId;
              }
              return appointment.doctorId == doctorId &&
                  appointment.dateTime.year == today.year &&
                  appointment.dateTime.month == today.month &&
                  appointment.dateTime.day == today.day;
            }).toList();
            debugPrint('Filtered appointments count: ${appointments.length}');

            return Scaffold(
              appBar: AppBar(
                title: Text(_showAllAppointments ? 'Doctor Admin - All Appointments' : 'Doctor Admin - Today\'s Schedule'),
                automaticallyImplyLeading: false,
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor Dashboard',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Today\'s Appointments: $todayAppointments',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        ),
                        Text(
                          'This Week\'s Appointments: $weekAppointments',
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _showAllAppointments
                              ? 'All Appointments'
                              : 'Today\'s Appointments (${DateFormat('MMM d, yyyy').format(today)})',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: appointments.isEmpty
                              ? Center(
                            child: Text(
                              doctorId == 'unknown'
                                  ? 'No user logged in'
                                  : 'No appointments found',
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 16),
                            ),
                          )
                              : ListView.builder(
                            itemCount: appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = appointments[index];
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    'Patient: ${appointment.userId}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    'Time: ${DateFormat('MMM d, yyyy h:mm a').format(appointment.dateTime.toLocal())}'
                                        '\nStatus: ${appointment.status}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  trailing: appointment.status == 'pending'
                                      ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            final updated = Appointment(
                                              id: appointment.id,
                                              doctorId: appointment.doctorId,
                                              userId: appointment.userId,
                                              dateTime: appointment.dateTime,
                                              status: 'approved',
                                              createdAt: appointment.createdAt,
                                            );
                                            await ref
                                                .read(appointmentProvider.notifier)
                                                .updateAppointment(updated);
                                            final notificationsPlugin = FlutterLocalNotificationsPlugin();
                                            await notificationsPlugin.show(
                                              0,
                                              'Appointment Approved',
                                              'Your appointment at ${DateFormat('h:mm a').format(appointment.dateTime.toLocal())} is approved.',
                                              const NotificationDetails(
                                                android: AndroidNotificationDetails(
                                                  'appointment_channel',
                                                  'Appointments',
                                                  channelDescription: 'Notifications for appointment status changes',
                                                  importance: Importance.high,
                                                  priority: Priority.high,
                                                ),
                                              ),
                                            );
                                            await _scheduleReminder(updated, notificationsPlugin);
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to approve: $e')),
                                            );
                                          }
                                        },
                                        child: const Text('Approve'),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton(
                                        onPressed: () async {
                                          try {
                                            final updated = Appointment(
                                              id: appointment.id,
                                              doctorId: appointment.doctorId,
                                              userId: appointment.userId,
                                              dateTime: appointment.dateTime,
                                              status: 'declined',
                                              createdAt: appointment.createdAt,
                                            );
                                            await ref
                                                .read(appointmentProvider.notifier)
                                                .updateAppointment(updated);
                                            final notificationsPlugin = FlutterLocalNotificationsPlugin();
                                            await notificationsPlugin.show(
                                              0,
                                              'Appointment Declined',
                                              'Your appointment at ${DateFormat('h:mm a').format(appointment.dateTime.toLocal())} was declined.',
                                              const NotificationDetails(
                                                android: AndroidNotificationDetails(
                                                  'appointment_channel',
                                                  'Appointments',
                                                  channelDescription: 'Notifications for appointment status changes',
                                                  importance: Importance.high,
                                                  priority: Priority.high,
                                                ),
                                              ),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Failed to decline: $e')),
                                            );
                                          }
                                        },
                                        child: const Text('Decline'),
                                      ),
                                    ],
                                  )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showAllAppointments = !_showAllAppointments;
                              debugPrint('Toggled showAllAppointments to: $_showAllAppointments');
                            });
                          },
                          child: Text(_showAllAppointments ? 'Show Today\'s Schedule' : 'Show All Appointments'),
                        ),
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
  }
}
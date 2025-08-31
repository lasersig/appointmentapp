import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../../models/appointment.dart';
import '../../models/user_session.dart';
import '../../models/doctor.dart';

class UpcomingAppointmentsScreen extends StatelessWidget {
  const UpcomingAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<UserSession>('session').listenable(),
      builder: (context, Box<UserSession> sessionBox, _) {
        final userSession = sessionBox.get('user');
        final userId = userSession?.phone ?? 'unknown';
        debugPrint('UpcomingAppointmentsScreen: userId = $userId');

        return ValueListenableBuilder(
          valueListenable: Hive.box<Appointment>('appointments').listenable(),
          builder: (context, Box<Appointment> appointmentsBox, _) {
            final doctorsBox = Hive.box<Doctor>('doctors');
            final now = DateTime.now().toLocal();
            final appointments = appointmentsBox.values
                .where((appointment) =>
            appointment.userId == userId &&
                (appointment.status == 'pending' || appointment.status == 'approved') &&
                appointment.dateTime.isAfter(now))
                .toList();
            debugPrint('Filtered upcoming appointments count: ${appointments.length}');

            return Scaffold(
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Upcoming Appointments',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: appointments.isEmpty
                              ? const Center(
                            child: Text(
                              'No upcoming appointments',
                              style: TextStyle(fontFamily: 'Inter', fontSize: 16),
                            ),
                          )
                              : ListView.builder(
                            itemCount: appointments.length,
                            itemBuilder: (context, index) {
                              final appointment = appointments[index];
                              final doctor = doctorsBox.get(appointment.doctorId);
                              return Card(
                                child: ListTile(
                                  title: Text(
                                    '${doctor?.name ?? 'Unknown'}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  subtitle: Text(
                                    'Time: ${DateFormat('MMM d, yyyy h:mm a').format(appointment.dateTime.toLocal())}'
                                        '\nStatus: ${appointment.status}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/appointment_details',
                                      arguments: appointment.id,
                                    );
                                    debugPrint('Navigating to appointment details for id: ${appointment.id}');
                                  },
                                ),
                              );
                            },
                          ),
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
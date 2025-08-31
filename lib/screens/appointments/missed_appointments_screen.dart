import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../constants/routes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

class MissedAppointmentsScreen extends ConsumerWidget {
  const MissedAppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider.notifier).getMissedAppointments();

    return Scaffold(
      body: appointments.isEmpty
          ? const Center(
        child: Text(
          'No missed appointments',
          style: TextStyle(fontFamily: 'Inter', fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return ValueListenableBuilder(
            valueListenable: Hive.box<Doctor>('doctors').listenable(),
            builder: (context, Box<Doctor> doctorsBox, _) {
              final doctor = doctorsBox.get(appointment.doctorId);
              return Card(
                child: ListTile(
                  title: Text(
                    doctor?.name ?? 'Unknown Doctor',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: Text(
                    '${DateFormat('EEEE, MMMM d, yyyy').format(appointment.dateTime)} at ${DateFormat('h:mm a').format(appointment.dateTime)} (${appointment.status})',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.appointmentDetails,
                      arguments: appointment,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/appointment.dart';

final appointmentProvider = StateNotifierProvider<AppointmentNotifier, List<Appointment>>((ref) {
  return AppointmentNotifier();
});

class AppointmentNotifier extends StateNotifier<List<Appointment>> {
  AppointmentNotifier() : super([]) {
    _loadAppointments();
  }

  final Box<Appointment> _appointmentsBox = Hive.box<Appointment>('appointments');

  void _loadAppointments() {
    state = _appointmentsBox.values.toList();
  }

  List<Appointment> getUpcomingAppointments() {
    return _appointmentsBox.values
        .where((appointment) => ['pending', 'approved'].contains(appointment.status))
        .toList();
  }

  List<Appointment> getMissedAppointments() {
    return _appointmentsBox.values
        .where((appointment) => ['declined', 'canceled'].contains(appointment.status))
        .toList();
  }

  List<Appointment> getCompletedAppointments() {
    return _appointmentsBox.values
        .where((appointment) => appointment.status == 'completed')
        .toList();
  }

  Future<void> addAppointment(Appointment appointment) async {
    await _appointmentsBox.put(appointment.id, appointment);
    state = _appointmentsBox.values.toList();
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await _appointmentsBox.put(appointment.id, appointment);
    state = _appointmentsBox.values.toList();
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final appointment = _appointmentsBox.get(appointmentId);
    if (appointment != null && appointment.status != 'canceled') {
      final updated = Appointment(
        id: appointment.id,
        doctorId: appointment.doctorId,
        userId: appointment.userId,
        dateTime: appointment.dateTime,
        status: 'canceled',
        createdAt: appointment.createdAt,
      );
      await _appointmentsBox.put(appointmentId, updated);
      state = _appointmentsBox.values.toList();
    }
  }

  Future<void> completeAppointment(String appointmentId) async {
    final appointment = _appointmentsBox.get(appointmentId);
    if (appointment != null && appointment.status != 'completed') {
      final updated = Appointment(
        id: appointment.id,
        doctorId: appointment.doctorId,
        userId: appointment.userId,
        dateTime: appointment.dateTime,
        status: 'completed',
        createdAt: appointment.createdAt,
      );
      await _appointmentsBox.put(appointmentId, updated);
      state = _appointmentsBox.values.toList();
    }
  }
}
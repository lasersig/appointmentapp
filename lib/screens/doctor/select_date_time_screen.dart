import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/routes.dart';
import '../../models/doctor.dart';
import '../../models/work_day.dart';
import '../../models/appointment.dart';

class SelectDateTimeScreen extends StatefulWidget {
  const SelectDateTimeScreen({super.key});

  @override
  State<SelectDateTimeScreen> createState() => _SelectDateTimeScreenState();
}

class _SelectDateTimeScreenState extends State<SelectDateTimeScreen> {
  DateTime? _selectedDate;
  String? _selectedSlot;
  WorkDay? _selectedWorkDay;

  List<String> _getFreeSlots(WorkDay workDay, DateTime date, String doctorId) {
    final appointmentsBox = Hive.box<Appointment>('appointments');
    final bookedSlots = appointmentsBox.values
        .where(
          (appointment) =>
      appointment.doctorId == doctorId &&
          appointment.dateTime.year == date.year &&
          appointment.dateTime.month == date.month &&
          appointment.dateTime.day == date.day &&
          ['pending', 'approved'].contains(appointment.status),
    )
        .map((appointment) => DateFormat('h:mm a').format(appointment.dateTime))
        .toSet();

    return workDay.slots.where((slot) => !bookedSlots.contains(slot)).toList();
  }

  DateTime _combineDateAndTime(DateTime date, String time) {
    try {
      // Parse the time string (e.g., "9:00 AM" or "09:00")
      final timeFormat = time.contains(' ') ? 'h:mm a' : 'HH:mm';
      final dateFormat = DateFormat('yyyy-MM-dd');
      final dateStr = dateFormat.format(date);
      final timeParser = DateFormat(timeFormat);
      final parsedTime = timeParser.parse(time);
      final combinedStr = '$dateStr ${timeParser.format(parsedTime)}';
      final fullFormat = DateFormat('yyyy-MM-dd $timeFormat');
      return fullFormat.parse(combinedStr);
    } catch (e) {
      debugPrint('DateTime parse error: $e, time: $time, date: $date');
      // Fallback to a safe DateTime
      return date;
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ModalRoute.of(context)!.settings.arguments as Doctor?;
    if (doctor == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Select Date & Time'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text(
            'Error: Doctor not provided',
            style: TextStyle(fontFamily: 'Inter', fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Date & Time'),
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
                  'Select Date:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    color: const Color(0xFF1976D2),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        _selectedDate = pickedDate;
                        _selectedSlot = null;
                        _selectedWorkDay = doctor.workDays.firstWhere(
                              (workDay) => workDay.weekday == pickedDate.weekday,
                          orElse: () =>
                              WorkDay(weekday: pickedDate.weekday, slots: []),
                        );
                      });
                    }
                  },
                  child: Text(
                    _selectedDate == null
                        ? 'Choose Date'
                        : DateFormat('MMM d, yyyy').format(_selectedDate!),
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedDate != null &&
                    _selectedWorkDay!.slots.isNotEmpty) ...[
                  Text(
                    'Select Time Slot:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      color: const Color(0xFF1976D2),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _getFreeSlots(
                      _selectedWorkDay!,
                      _selectedDate!,
                      doctor.id,
                    ).map((slot) {
                      return ChoiceChip(
                        label: Text(slot),
                        selected: _selectedSlot == slot,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedSlot = slot;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
                if (_selectedDate != null && _selectedWorkDay!.slots.isEmpty)
                  const Text(
                    'No slots available for this date',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _selectedDate != null && _selectedSlot != null
                      ? () {
                    final appointmentTime =
                    _combineDateAndTime(_selectedDate!, _selectedSlot!);
                    debugPrint('Selected appointment time: $appointmentTime');
                    Navigator.pushNamed(
                      context,
                      AppRoutes.confirmBooking,
                      arguments: {
                        'doctor': doctor,
                        'dateTime': appointmentTime,
                      },
                    );
                  }
                      : null,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
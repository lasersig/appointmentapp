import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:intl/intl.dart';
import '../appointments/upcoming_appointments_screen.dart';
import '../appointments/missed_appointments_screen.dart';
import '../appointments/completed_appointments_screen.dart';
import '../search/search_doctors_screen.dart';
import '../account/account_screen.dart';
import '../admin/doctor_admin_screen.dart';
import '../../models/doctor.dart';
import '../../models/appointment.dart';
import '../../models/user_session.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  _HomeTabsState createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _selectedIndex = 0;

  List<Widget> _screens(BuildContext context, String userId) {
    final doctorsBox = Hive.box<Doctor>('doctors');
    final isDoctor = doctorsBox.values.any((doctor) => doctor.id == userId);
    return [
      isDoctor ? const DoctorAdminScreen() : const UpcomingAppointmentsScreen(),
      const MissedAppointmentsScreen(),
      const CompletedAppointmentsScreen(),
      const SearchDoctorsScreen(),
      const AccountScreen(),
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
    WidgetsBinding.instance.addObserver(this);
    _scheduleAppointmentReminders();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      debugPrint('App resumed, rescheduling reminders');
      _scheduleAppointmentReminders();
    }
  }

  Future<void> _scheduleAppointmentReminders() async {
    final notificationsPlugin = FlutterLocalNotificationsPlugin();
    final appointmentsBox = Hive.box<Appointment>('appointments');
    final doctorsBox = Hive.box<Doctor>('doctors');
    final remindersBox = Hive.box('reminders');
    final userSession = Hive.box<UserSession>('session').get('user');
    final userId = userSession?.phone ?? 'unknown';
    final now = DateTime.now().toLocal();
    final maxDate = now.add(const Duration(days: 30));

    debugPrint('Scheduling reminders for user: $userId, now: $now, maxDate: $maxDate');
    debugPrint('Appointments in box: ${appointmentsBox.values.length}');

    // Clear existing reminders to prevent duplicates
    await remindersBox.clear();
    await notificationsPlugin.cancelAll();
    debugPrint('Cleared reminders box and cancelled all notifications');

    for (var appointment in appointmentsBox.values) {
      debugPrint('Checking appointment: ${appointment.id}, status: ${appointment.status}, userId: ${appointment.userId}, dateTime: ${appointment.dateTime}');
      if (appointment.status == 'approved' &&
          appointment.userId == userId &&
          appointment.dateTime.isAfter(now) &&
          appointment.dateTime.isBefore(maxDate)) {
        final reminderId = appointment.id.hashCode;
        final reminderTime = appointment.dateTime.subtract(const Duration(hours: 1));
        debugPrint('Reminder eligible for ${appointment.id}, reminderTime: $reminderTime, reminderId: $reminderId');

        final doctor = doctorsBox.get(appointment.doctorId);
        try {
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
          debugPrint('Scheduled reminder for appointment ${appointment.id} at $reminderTime for patient $userId');
        } catch (e) {
          debugPrint('Error scheduling reminder for ${appointment.id}: $e');
        }
      } else {
        debugPrint('Appointment ${appointment.id} not eligible: status=${appointment.status}, userId=${appointment.userId}, dateTime=${appointment.dateTime}');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onBottomNavTapped(int index) {
    setState(() {
      _selectedIndex = index == 0 ? _tabController.index : index + 2;
      if (index == 0) {
        _tabController.animateTo(_selectedIndex < 3 ? _selectedIndex : 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userSession = Hive.box<UserSession>('session').get('user');
    final userId = userSession?.phone ?? 'unknown';
    final screens = _screens(context, userId);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        bottom: _selectedIndex < 3
            ? PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: const Color(0xFFFFFFFF),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF1eb6b9),
              unselectedLabelColor: const Color(0xFF888888),
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 3.0,
                  color: Color(0xFF1DB5B8),
                ),
                insets: EdgeInsets.zero,
              ),
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Missed'),
                Tab(text: 'Completed'),
              ],
            ),
          ),
        )
            : null,
      ),
      body: _selectedIndex < 3
          ? TabBarView(
        controller: _tabController,
        children: screens.sublist(0, 3),
      )
          : screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex < 3 ? 0 : _selectedIndex - 2,
        selectedItemColor: const Color(0xFF1976D2),
        onTap: _onBottomNavTapped,
      ),
    );
  }
}
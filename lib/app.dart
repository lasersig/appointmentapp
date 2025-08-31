import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'models/doctor.dart';
import 'models/work_day.dart';
import 'constants/routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/sign_in_phone_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/user_details_screen.dart';
import 'screens/home/home_tabs.dart';
import 'screens/appointment_details/appointment_details_screen.dart';
import 'screens/appointments/upcoming_appointments_screen.dart';
import 'screens/appointments/missed_appointments_screen.dart';
import 'screens/appointments/completed_appointments_screen.dart';
import 'screens/search/search_doctors_screen.dart';
import 'screens/doctor/doctor_profile_screen.dart';
import 'screens/doctor/select_date_time_screen.dart';
import 'screens/doctor/confirm_booking_dialog.dart';
import 'screens/search/filters_sheet.dart';
import 'screens/account/account_screen.dart';
import 'screens/admin/doctor_admin_screen.dart';
import 'constants/app_themes.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _populateDoctorsFromJson);
  }

  Future<void> _populateDoctorsFromJson() async {
    final doctorsBox = Hive.box<Doctor>('doctors');
    if (doctorsBox.isEmpty) {
      try {
        // Load JSON from assets
        final jsonString = await DefaultAssetBundle.of(context).loadString('assets/seed/seed_doctors.json');
        final jsonData = jsonDecode(jsonString);

        // Handle both list and object formats
        final List<dynamic> doctorsList = jsonData is List
            ? jsonData
            : jsonData['doctors'] as List<dynamic>? ?? [];

        if (doctorsList.isEmpty) {
          debugPrint('No doctors found in seed_doctors.json');
          return;
        }

        // Parse and save doctors
        for (var json in doctorsList) {
          final workDays = (json['workDays'] as List)
              .map((wd) => WorkDay(
            weekday: wd['weekday'],
            slots: List<String>.from(wd['slots']),
          ))
              .toList();
          final doctor = Doctor(
            id: json['id'],
            name: json['name'],
            specialty: json['specialty'],
            workDays: workDays,
            avatarUrl: json['avatarUrl'] ?? '',
          );
          await doctorsBox.put(doctor.id, doctor);
        }
        debugPrint('Populated ${doctorsList.length} doctors from seed_doctors.json');
      } catch (e) {
        debugPrint('Error populating doctors from JSON: $e');
      }
    } else {
      debugPrint('Doctors box already contains ${doctorsBox.length} doctors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: '',
        theme: appTheme(),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (context) => const SplashScreen(),
          AppRoutes.onboarding: (context) => const OnboardingScreen(),
          AppRoutes.signInPhone: (context) => const SignInPhoneScreen(),
          AppRoutes.otp: (context) => const OtpScreen(),
          AppRoutes.userDetails: (context) => const UserDetailsScreen(),
          AppRoutes.homeTabs: (context) => const HomeTabs(),
          AppRoutes.appointmentDetails: (context) => const AppointmentDetailsScreen(),
          AppRoutes.upcomingAppointments: (context) => const UpcomingAppointmentsScreen(),
          AppRoutes.missedAppointments: (context) => const MissedAppointmentsScreen(),
          AppRoutes.completedAppointments: (context) => const CompletedAppointmentsScreen(),
          AppRoutes.searchDoctors: (context) => const SearchDoctorsScreen(),
          AppRoutes.filtersSheet: (context) => const FiltersSheet(),
          AppRoutes.doctorProfile: (context) => const DoctorProfileScreen(),
          AppRoutes.selectDateTime: (context) => const SelectDateTimeScreen(),
          AppRoutes.confirmBooking: (context) => const ConfirmBookingScreen(),
          AppRoutes.account: (context) => const AccountScreen(),
          AppRoutes.doctorAdmin: (context) => const DoctorAdminScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
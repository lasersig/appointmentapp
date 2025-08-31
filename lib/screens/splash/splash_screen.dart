import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/routes.dart';
import '../../models/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Simulate splash screen delay (e.g., 2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    final sessionBox = Hive.box<UserSession>('session');
    final userSession = sessionBox.get('user');

    if (!mounted) return;

    if (userSession == null) {
      // First launch: go to onboarding
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    } else if (!userSession.loggedIn) {
      // Not logged in: go to sign-in
      Navigator.pushReplacementNamed(context, AppRoutes.signInPhone);
    } else {
      // Logged in: go to home tabs
      Navigator.pushReplacementNamed(context, AppRoutes.homeTabs);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for logo or splash image (update with Figma assets)
            Icon(Icons.local_hospital, size: 100, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Patient Diary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
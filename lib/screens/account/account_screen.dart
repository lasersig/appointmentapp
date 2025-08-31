import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_session.dart';
import '../../constants/routes.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<UserSession>('session').listenable(),
        builder: (context, Box<UserSession> box, _) {
          final user = box.get('user');
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Phone: ${user?.phone ?? 'Not logged in'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Name: ${user?.name ?? 'Not set'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Email: ${user?.email ?? 'Not set'}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        box.delete('user');
                        Navigator.pushReplacementNamed(context, AppRoutes.signInPhone);
                      },
                      child: const Text('Log Out'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.doctorAdmin);
                      },
                      child: const Text('Manage Schedule (Admin)'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
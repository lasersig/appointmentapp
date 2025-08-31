import 'package:flutter/material.dart';
import '../../constants/routes.dart';
import '../../models/doctor.dart';

class DoctorProfileScreen extends StatelessWidget {
  const DoctorProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final doctor = ModalRoute.of(context)!.settings.arguments as Doctor;
    return Scaffold(
      appBar: AppBar(title: Text(doctor.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            doctor.avatarUrl.isNotEmpty
                ? Center(child: Image.asset(doctor.avatarUrl, width: 100, height: 100, fit: BoxFit.cover))
                : const Center(child: Icon(Icons.person, size: 100)),
            const SizedBox(height: 16),
            Text('Name: ${doctor.name}', style: const TextStyle(fontSize: 20)),
            Text('Specialty: ${doctor.specialty}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.selectDateTime,
                  arguments: doctor,
                );
              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }
}
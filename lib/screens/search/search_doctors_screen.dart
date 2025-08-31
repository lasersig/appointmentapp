import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../constants/routes.dart';
import '../../models/doctor.dart';
import '../search/filters_sheet.dart';

final filterProvider = StateProvider<Map<String, dynamic>>((ref) => {
  'specialty': null,
  'availableDay': null,
});

class SearchDoctorsScreen extends ConsumerWidget {
  const SearchDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);
    print('Current filters: $filters');
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Search Doctors',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600, // SemiBold
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1EB6B9), // Figma blue
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) => const FiltersSheet(),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Doctor>('doctors').listenable(),
        builder: (context, Box<Doctor> box, _) {
          final doctors = box.values.toList();
          print('Doctors in box: ${doctors.map((d) => "${d.name} (${d.specialty}, ${d.workDays.map((w) => w.weekdayName).join(", ")})").toList()}');
          if (doctors.isEmpty) {
            return const Center(
              child: Text(
                'No doctors available',
                style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.grey),
              ),
            );
          }
          var filteredDoctors = doctors;
          if (filters['specialty'] != null) {
            filteredDoctors = filteredDoctors.where((doctor) {
              final matches = doctor.specialty.toLowerCase() == (filters['specialty'] as String).toLowerCase();
              print('Specialty filter: ${doctor.name} matches ${filters['specialty']} = $matches');
              return matches;
            }).toList();
          }
          if (filters['availableDay'] != null) {
            filteredDoctors = filteredDoctors.where((doctor) {
              final matches = doctor.workDays.any((workDay) => workDay.weekdayName == filters['availableDay']);
              print('Day filter: ${doctor.name} matches ${filters['availableDay']} = $matches');
              return matches;
            }).toList();
          }
          if (filteredDoctors.isEmpty) {
            print('No doctors match filters: $filters');
            return const Center(
              child: Text(
                'No doctors match the selected filters',
                style: TextStyle(fontFamily: 'Inter', fontSize: 16, color: Colors.grey),
              ),
            );
          }
          print('Filtered doctors: ${filteredDoctors.map((d) => "${d.name} (${d.specialty})").toList()}');
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDoctors.length,
            itemBuilder: (context, index) {
              final doctor = filteredDoctors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: doctor.avatarUrl.isNotEmpty
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      doctor.avatarUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF1EB6B9),
                      ),
                    ),
                  )
                      : const Icon(Icons.person, size: 50, color: Color(
                      0xFF1EB6B9)),
                  title: Text(
                    doctor.name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500, // Medium
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    doctor.specialty,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.doctorProfile,
                      arguments: doctor,
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
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../models/doctor.dart';
import '../../utils/hive_adapters.dart';
import '../search/search_doctors_screen.dart';

class FiltersSheet extends ConsumerWidget {
  const FiltersSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(filterProvider);
    final box = Hive.box<Doctor>('doctors');
    final specialties = ['All'] + box.values.map((doctor) => doctor.specialty).toSet().toList();
    const days = ['All', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    print('Available specialties: $specialties');
    print('Available days: $days');
    print('Current filters in FiltersSheet: $filters');

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Test font weights
          const SizedBox(height: 16),
          const Text(
            'Filter Doctors',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w600, // SemiBold
              color: Color(0xFF1EB6B9),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Specialty',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500, // Medium
            ),
          ),
          DropdownButton<String>(
            value: filters['specialty'] ?? 'All',
            isExpanded: true,
            items: specialties.map((specialty) {
              return DropdownMenuItem(
                value: specialty,
                child: Text(
                  specialty,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              print('Selected specialty: $value');
              ref.read(filterProvider.notifier).update((state) => {
                ...state,
                'specialty': value == 'All' ? null : value,
              });
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Available Day',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500, // Medium
            ),
          ),
          DropdownButton<String>(
            value: filters['availableDay'] ?? 'All',
            isExpanded: true,
            items: days.map((day) {
              return DropdownMenuItem(
                value: day,
                child: Text(
                  day,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                ),
              );
            }).toList(),
            onChanged: (value) {
              print('Selected day: $value');
              ref.read(filterProvider.notifier).update((state) => {
                ...state,
                'availableDay': value == 'All' ? null : value,
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1EB6B9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Apply Filters',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
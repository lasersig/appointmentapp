import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../constants/routes.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  final List<Map<String, String>> slides = const [
    {
      'title': 'Find Doctors',
      'description': 'Search for doctors by specialty and availability.',
      'image': 'assets/images/onboarding1.png',
    },
    {
      'title': 'Book Appointments',
      'description': 'Schedule appointments easily with available slots.',
      'image': 'assets/images/onboarding2.png',
    },
    {
      'title': 'Manage Profile',
      'description': 'View and update your profile and appointments.',
      'image': 'assets/images/onboarding3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: slides.map((slide) {
                return Builder(
                  builder: (BuildContext context) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          slide['image']!,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image,
                            size: 200,
                            color: Color(0xFF1EB6B9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide['title']!,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          slide['description']!,
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.signInPhone);
              },
              child: const Text('Get Started'),
            ),
          ),
        ],
      ),
    );
  }
}
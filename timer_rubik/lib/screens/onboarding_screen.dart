import 'package:flutter/material.dart';
import 'package:timer_rubik/views/rubik_timer.dart';
import 'package:timer_rubik/screens/list_views.dart';
import 'package:timer_rubik/screens/camera_screen.dart';
import 'package:timer_rubik/screens/location_screen.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  int selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        children: const [RubikTimer(), ListViews(), CameraScreen(), LocationScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.timer),
            activeIcon: const Icon(Icons.timer_sharp),
            label: 'Temporizador',
            backgroundColor: colors.primary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.list),
            activeIcon: const Icon(Icons.list_alt),
            label: 'Tiempos',
            backgroundColor: colors.tertiary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.camera_alt),
            activeIcon: const Icon(Icons.camera_alt_outlined),
            label: 'Cámara',
            backgroundColor: colors.secondary,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.location_on),
            activeIcon: const Icon(Icons.location_on_outlined),
            label: 'Ubicación',
            backgroundColor: colors.primaryContainer,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
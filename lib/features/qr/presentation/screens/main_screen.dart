import 'package:fasto_qr/features/qr/presentation/screens/create_screen.dart';
import 'package:fasto_qr/features/qr/presentation/screens/qr_list_sscreen.dart';
import 'package:fasto_qr/shared/widgets/app_bottom_navbar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    const QrListScreen(),
    CreateScreen(onCreated: () => _goToTab(0)),
  ];

  void _goToTab(int index) {
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: false,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: AppBottomNavbar(
        currentIndex: _currentIndex,
        onTap: _goToTab,
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/nutech_background.dart';
import 'pages/dashboard_page.dart';
import 'pages/site_page.dart';
import 'pages/logs_page.dart';
import 'pages/profile_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static const route = '/home';

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  // NEW: State variables to track shift status globally within the shell
  bool _isActive = false;
  String _selectedSite = '';

  void _onNavigateToTab(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }

  // NEW: Function to handle when a user completes a clock-in from the Site Page
  void _onClockIn(String siteName) {
    setState(() {
      _isActive = true;
      _selectedSite = siteName;
      _index = 0; // Automatically navigate back to Dashboard
    });
  }

  // NEW: Function to handle clocking out from the Dashboard
  void _onClockOut() {
    setState(() {
      _isActive = false;
      _selectedSite = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        onStartShift: () => _onNavigateToTab(1),
        isActive: _isActive,
        selectedSite: _selectedSite,
        onClockOut: _onClockOut,
      ),
      SitePage(
        onSiteSelected: _onClockIn,
      ),
      const LogsPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: NutechBackground(
        showTopAccents: _index != 3,
        child: SafeArea(
          child: pages[_index],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.onTap});

  final int index;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/ui/bottombackground2.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppTheme.tealSoft,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_outlined, color: AppTheme.teal),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Image.asset('assets/icons/building.png', width: 26, height: 26),
              selectedIcon: ColorFiltered(
                colorFilter: const ColorFilter.mode(AppTheme.teal, BlendMode.srcIn),
                child: Image.asset('assets/icons/building.png', width: 26, height: 26),
              ),
              label: 'Site',
            ),
            NavigationDestination(
              icon: Image.asset('assets/icons/logs.png', width: 26, height: 26),
              selectedIcon: ColorFiltered(
                colorFilter: const ColorFilter.mode(AppTheme.teal, BlendMode.srcIn),
                child: Image.asset('assets/icons/logs.png', width: 26, height: 26),
              ),
              label: 'Logs',
            ),
            NavigationDestination(
              icon: Image.asset('assets/icons/user.png', width: 26, height: 26),
              selectedIcon: ColorFiltered(
                colorFilter: const ColorFilter.mode(AppTheme.teal, BlendMode.srcIn),
                child: Image.asset('assets/icons/user.png', width: 26, height: 26),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ],
    );
  }
}
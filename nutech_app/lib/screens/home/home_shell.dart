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

  @override
  Widget build(BuildContext context) {
    final pages = const [
      DashboardPage(),
      SitePage(),
      LogsPage(),
      ProfilePage(),
    ];

    return Scaffold(
      body: NutechBackground(
        showTopAccents: _index != 3, // profile has a big teal header anyway
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
        // Decorative bottom background
        Positioned.fill(
          child: IgnorePointer(
            child: Image.asset(
              'assets/images/ui/bottombackground2.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        // NavigationBar on top
        NavigationBar(
          selectedIndex: index,
          onDestinationSelected: onTap,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppTheme.tealSoft,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
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

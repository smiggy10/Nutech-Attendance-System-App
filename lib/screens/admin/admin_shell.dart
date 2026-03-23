import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/nutech_background.dart';
import 'pages/admin_monitor_page.dart';
import 'pages/admin_overview_shell.dart';
import 'pages/admin_reports_page.dart';

class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  static const route = '/admin';

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  Widget _navIcon(String asset, Color color) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      child: Image.asset(asset, width: 26, height: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = const [
      AdminOverviewShell(),
      AdminMonitorPage(),
      AdminReportsPage(),
    ];

    return Scaffold(
      body: NutechBackground(
        // Match employee home shell: header accents + default bottom illustration.
        showTopAccents: true,
        child: SafeArea(
          child: IndexedStack(
            index: _index,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: AppTheme.tealSoft,
        destinations: [
          NavigationDestination(
            icon: _navIcon('assets/admin/Overview_Icon.png', AppTheme.muted),
            selectedIcon: _navIcon(
              'assets/admin/Overview_Icon.png',
              AppTheme.teal,
            ),
            label: 'Overview',
          ),
          NavigationDestination(
            icon: _navIcon('assets/admin/Monitor.png', AppTheme.muted),
            selectedIcon: _navIcon('assets/admin/Monitor.png', AppTheme.teal),
            label: 'Monitor',
          ),
          NavigationDestination(
            icon: _navIcon('assets/admin/Results.png', AppTheme.muted),
            selectedIcon: _navIcon('assets/admin/Results.png', AppTheme.teal),
            label: 'Reports',
          ),
        ],
      ),
    );
  }
}

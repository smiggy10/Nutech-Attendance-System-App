import 'package:flutter/material.dart';

import 'admin_overview_page.dart';
import 'employee_list_page.dart';

/// Routes under the Overview tab so the admin bottom bar stays visible.
class AdminOverviewShell extends StatelessWidget {
  const AdminOverviewShell({super.key});

  static const String employeesRoute = '/employees';

  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case employeesRoute:
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (context) => const EmployeeListPage(),
            );
          case '/':
          default:
            return MaterialPageRoute<void>(
              settings: const RouteSettings(name: '/'),
              builder: (context) => const AdminOverviewPage(),
            );
        }
      },
    );
  }
}

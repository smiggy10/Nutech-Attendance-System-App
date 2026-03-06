import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../auth/login_screen.dart';

import '../reports/admin_daily_attendance_screen.dart';
import '../reports/admin_weekly_summary_screen.dart';
import '../reports/admin_late_absences_screen.dart';

class AdminReportsPage extends StatelessWidget {
  const AdminReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return SingleChildScrollView(
          // ✅ Removed horizontal padding to allow lines to hit the edges
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight - 20),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // ✅ Section 1: Logo (Re-applied 20px horizontal padding)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 100), 
                        child: Image.asset(
                          'assets/images/branding/nutechlogo1.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ✅ FIXED: Continuous edge-to-edge lines (No box)
                  Column(
                    children: [
                      Divider(
                        color: Colors.black.withOpacity(0.15), 
                        thickness: 1, 
                        height: 1,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: const Center(
                          child: Text(
                            'Reports',
                            style: TextStyle(
                              fontSize: 26, 
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black.withOpacity(0.15), 
                        thickness: 1, 
                        height: 1,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ✅ Section 2: Buttons (Re-applied 20px horizontal padding)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _ReportButton(
                          label: 'Daily Attendance',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AdminDailyAttendanceScreen.route,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ReportButton(
                          label: 'Weekly Summary',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AdminWeeklySummaryScreen.route,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ReportButton(
                          label: 'Late & Absences',
                          onTap: () => Navigator.pushNamed(
                            context,
                            AdminLateAbsencesScreen.route,
                          ),
                        ),
                        
                        // Your original spacing
                        const SizedBox(height: 180),

                        // ✅ Logout button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE24B33),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                LoginScreen.route,
                                (route) => false,
                              );
                            },
                            child: const Text(
                              'Logout',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ReportButton extends StatelessWidget {
  const _ReportButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 10, 139, 144),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
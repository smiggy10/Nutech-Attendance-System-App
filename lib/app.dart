import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/register_password_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/forgot_password_otp_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_shell.dart';
import 'screens/admin/admin_shell.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/admin/reports/admin_daily_attendance_screen.dart';
import 'screens/admin/reports/admin_weekly_summary_screen.dart';
import 'screens/admin/reports/admin_late_absences_screen.dart';
import 'theme/app_theme.dart';

class NutechApp extends StatelessWidget {
  const NutechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutech',
      // Ensure AppTheme.light is defined to handle our new Dialogs and Snackbars
      theme: AppTheme.light,
      initialRoute: SplashScreen.route,
      routes: {
        SplashScreen.route: (_) => const SplashScreen(),
        LoginScreen.route: (_) => const LoginScreen(),
        SignupScreen.route: (_) => const SignupScreen(),
        RegisterPasswordScreen.route: (_) => const RegisterPasswordScreen(),
        ForgotPasswordScreen.route: (_) => const ForgotPasswordScreen(),
        ForgotPasswordOtpScreen.route: (_) => const ForgotPasswordOtpScreen(),
        ResetPasswordScreen.route: (_) => const ResetPasswordScreen(),
        VerifyEmailScreen.route: (_) => const VerifyEmailScreen(),
        HomeShell.route: (_) => const HomeShell(),
        AdminShell.route: (_) => const AdminShell(),
        AdminDailyAttendanceScreen.route: (_) =>
            const AdminDailyAttendanceScreen(),
        AdminWeeklySummaryScreen.route: (_) => const AdminWeeklySummaryScreen(),
        AdminLateAbsencesScreen.route: (_) => const AdminLateAbsencesScreen(),
      },
    );
  }
}

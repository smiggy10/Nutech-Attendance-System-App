import 'package:flutter/material.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/register_password_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/home/home_shell.dart';
import 'theme/app_theme.dart';

class NutechApp extends StatelessWidget {
  const NutechApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nutech',
      theme: AppTheme.light,
      initialRoute: LoginScreen.route,
      routes: {
        LoginScreen.route: (_) => const LoginScreen(),
        SignupScreen.route: (_) => const SignupScreen(),
        RegisterPasswordScreen.route: (_) => const RegisterPasswordScreen(),
        ForgotPasswordScreen.route: (_) => const ForgotPasswordScreen(),
        VerifyEmailScreen.route: (_) => const VerifyEmailScreen(),
        HomeShell.route: (_) => const HomeShell(),
      },
    );
  }
}
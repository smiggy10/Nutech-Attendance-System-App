import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/nutech_background.dart';
import '../../widgets/nutech_text_field.dart';
import '../../widgets/primary_button.dart';
import '../home/home_shell.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  static const route = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            // ✅ Increased top padding so everything sits lower
            padding: const EdgeInsets.fromLTRB(24, 85, 24, 24),
            child: Column(
              children: [
                // ✅ Reduced extra top spacer (since padding is doing the work now)
                const SizedBox(height: 10),

                // ✅ Logo with NO background shape
                Image.asset(
                  'assets/images/branding/nutechlogo1.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 30),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'User ID',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                const NutechTextField(hint: 'Enter user id'),
                const SizedBox(height: 18),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Password',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Enter password',
                  obscureText: _obscure,
                  suffix: IconButton(
                    icon: Image.asset(
                      'assets/icons/visibility.png',
                      width: 22,
                      height: 22,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),

                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      ForgotPasswordScreen.route,
                    ),
                    child: const Text('Forgot password?'),
                  ),
                ),

                const SizedBox(height: 14),
                PrimaryButton(
                  label: 'Login',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(context, HomeShell.route),
                ),

                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Colors.black.withOpacity(0.25)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'Or Sign in with',
                        style: TextStyle(color: AppTheme.muted),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Colors.black.withOpacity(0.25)),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                SizedBox(
                  width: 240,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.g_mobiledata, size: 28),
                    label: const Text(
                      'Google',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.black.withOpacity(0.10)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

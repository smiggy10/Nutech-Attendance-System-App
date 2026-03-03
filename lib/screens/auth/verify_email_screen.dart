import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/nutech_logo.dart'; // ✅ Added
import '../home/home_shell.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  static const route = '/verify-email';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 85, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                const SizedBox(height: 12),

                // ✅ Reusable Logo
                const NutechLogo(),

                const SizedBox(height: 24),

                const Text(
                  'Verification',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 34),

                const Text(
                  'Enter Verification Code',
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 18),

                const CodeInput(length: 4),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("If you didn’t receive a code. "),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Resend',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                PrimaryButton(
                  label: 'Confirm',
                  onPressed: () =>
                      Navigator.pushReplacementNamed(
                          context, HomeShell.route),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/nutech_logo.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  static const route = '/verify-email';

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String _enteredCode = "";

  void _handleVerify() {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    if (_enteredCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 4-digit code')),
      );
      return;
    }

    // Logic for n8n/Backend integration will go here.
    debugPrint('Final Registration Submission:');
    debugPrint('User Data: $args');
    debugPrint('OTP Code: $_enteredCode');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account Verified! Please login to continue.'),
        backgroundColor: Colors.green,
      ),
    );

    // Redirect to login and clear stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', 
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Removed 'Scaffold' so NutechBackground locks the background elements
    return NutechBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          // Ensures background doesn't jump when the numerical keyboard opens
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 85, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
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
                style: TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 18),

              // Custom CodeInput widget
              CodeInput(
                length: 4,
                onChanged: (value) {
                  setState(() {
                    _enteredCode = value;
                  });
                  debugPrint('Typing OTP: $_enteredCode'); 
                },
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("If you didn’t receive a code. "),
                  GestureDetector(
                    onTap: () {
                      // TODO: Trigger n8n Resend OTP
                      debugPrint('Resend OTP clicked');
                    },
                    child: const Text(
                      'Resend',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              PrimaryButton(
                label: 'Confirm',
                onPressed: _handleVerify,
              ),
              
              // Bottom spacing to prevent elements from being cut off on high-res screens
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
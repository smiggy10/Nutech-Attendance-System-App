import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/nutech_logo.dart';
// import '../home/home_shell.dart'; // No longer needed for this flow

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  static const route = '/verify-email';

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // ✅ 1. Variable to store the 4-digit code entered by the user
  String _enteredCode = "";

  void _handleVerify() {
    // ✅ 2. Retrieve all registration data passed from the previous screens
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    if (_enteredCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 4-digit code')),
      );
      return;
    }

    // ✅ 3. LOGIC PREVIEW: Logic for n8n will go here.
    print('Final Registration Submission:');
    print('User Data: $args');
    print('OTP Code: $_enteredCode');

    // ✅ 4. Show Success Message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account Verified! Please login to continue.'),
        backgroundColor: Colors.green,
      ),
    );

    // ✅ 5. REDIRECT TO LOGIN
    // This clears the navigation stack so the user can't "go back" to registration
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // Ensure this matches your Login Screen route in main.dart
      (route) => false,
    );
  }

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

                // ✅ 4. Capture the input from your custom CodeInput widget
                CodeInput(
                  length: 4,
                  onChanged: (value) {
                    setState(() {
                      _enteredCode = value;
                    });
                    // Helpful for testing to see the code build up in console
                    print('Typing OTP: $_enteredCode'); 
                  },
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("If you didn’t receive a code. "),
                    GestureDetector(
                      onTap: () {
                        // TODO: Trigger n8n Resend OTP webhook
                        print('Resend OTP clicked');
                      },
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
                  onPressed: _handleVerify, // ✅ Now redirects to Login
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
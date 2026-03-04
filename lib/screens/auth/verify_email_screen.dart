import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/nutech_logo.dart';
// import '../home/home_shell.dart'; // No longer needed for this flow
import '../../services/n8n_api.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  static const route = '/verify-email';

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  // ✅ 1. Variable to store the 4-digit code entered by the user
  String _enteredCode = "";
  bool _isVerifying = false;

  Future<void> _handleVerify() async {
    // ✅ 2. Retrieve all registration data passed from the previous screens
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    if (_enteredCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full 4-digit code')),
      );
      return;
    }

    final email = (args['email'] ?? '').toString();

    setState(() {
      _isVerifying = true;
    });

    try {
      final response = await N8nApi.verifyOtp(
        email: email,
        otp: _enteredCode,
      );

      final success = response['success'] == true || response.isEmpty;
      final message = response['message']?.toString() ??
          'Account Verified! Please login to continue.';

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green : Colors.redAccent,
        ),
      );

      if (!success) {
        return;
      }

      // ✅ REDIRECT TO LOGIN (clear stack)
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to verify OTP: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
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
                  onPressed: _isVerifying ? null : _handleVerify,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
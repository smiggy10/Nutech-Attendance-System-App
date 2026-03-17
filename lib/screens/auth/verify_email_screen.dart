import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/nutech_logo.dart';
import '../../services/n8n_api.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  static const route = '/verify-email';

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String _enteredCode = "";
  bool _isVerifying = false;
  bool _isResending = false;
  int _secondsRemaining = 0;
  Timer? _countdownTimer;
  bool _isResendPressed = false;

  @override
  void initState() {
    super.initState();
    _startCountdown(60);
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() {
      _secondsRemaining = seconds;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        setState(() {
          _secondsRemaining = 0;
        });
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining -= 1;
        });
      }
    });
  }

  Future<void> _handleVerify() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

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
      final response = await N8nApi.verifyOtp(email: email, otp: _enteredCode);

      final success = response['success'] == true || response.isEmpty;
      final message =
          response['message']?.toString() ??
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

      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

  Future<void> _handleResend() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = (args['email'] ?? '').toString();

    if (_secondsRemaining > 0 || _isResending) return;

    setState(() {
      _isResending = true;
    });

    try {
      final response = await N8nApi.resendOtp(email: email);
      final success = response['success'] == true || response.isEmpty;
      final message =
          response['message']?.toString() ??
          'A new code has been sent to your email.';

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

      _startCountdown(60);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to resend code: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  Future<void> _onResendTap() async {
    final isEnabled = _secondsRemaining == 0 && !_isResending;
    if (!isEnabled) return;

    setState(() => _isResendPressed = true);
    await Future.delayed(const Duration(milliseconds: 110));
    if (mounted) setState(() => _isResendPressed = false);

    await _handleResend();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
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
                    onTap: (_secondsRemaining > 0 || _isResending)
                        ? null
                        : _onResendTap,
                    child: AnimatedScale(
                      scale: _isResendPressed ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 110),
                      curve: Curves.easeOut,
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (_secondsRemaining > 0) ...[
                const SizedBox(height: 8),
                Text(
                  'You can resend a new code in $_secondsRemaining s',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
              ],

              const SizedBox(height: 26),

              PrimaryButton(
                label: 'Confirm',
                onPressed: _isVerifying ? null : _handleVerify,
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

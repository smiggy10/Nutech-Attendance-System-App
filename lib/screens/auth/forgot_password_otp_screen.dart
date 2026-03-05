import 'dart:async';

import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/nutech_logo.dart';
import '../../services/n8n_api.dart';
import 'reset_password_screen.dart';

class ForgotPasswordOtpScreen extends StatefulWidget {
  const ForgotPasswordOtpScreen({super.key});

  static const route = '/forgot-password-otp';

  @override
  State<ForgotPasswordOtpScreen> createState() =>
      _ForgotPasswordOtpScreenState();
}

class _ForgotPasswordOtpScreenState extends State<ForgotPasswordOtpScreen> {
  String _enteredCode = '';
  bool _isVerifying = false;
  bool _isResending = false;
  int _secondsRemaining = 0;
  String? _errorText;

  Future<void> _handleVerify() async {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = (args['email'] ?? '').toString();

    if (_enteredCode.length < 4) {
      setState(() {
        _errorText = 'Please enter the full 4-digit code';
      });
      return;
    }

    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    try {
      final response = await N8nApi.forgotPasswordVerify(
        email: email,
        otp: _enteredCode,
      );

      final success = response['success'] == true || response.isEmpty;
      final message =
          response['message']?.toString() ?? 'Code verified successfully.';

      if (!mounted) return;

      if (!success) {
        setState(() {
          _errorText = message;
        });
        return;
      }

      final token = response['token']?.toString() ?? '';

      if (token.isEmpty) {
        setState(() {
          _errorText = 'Missing reset token from server.';
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(
        context,
        ResetPasswordScreen.route,
        arguments: {
          'email': email,
          'token': token,
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to verify code: $e';
      });
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
      _errorText = null;
    });

    try {
      final response = await N8nApi.forgotPasswordResend(email: email);

      final success = response['success'] == true || response.isEmpty;
      final message = response['message']?.toString() ??
          'A new reset code has been sent to your email.';

      if (!mounted) return;

      if (!success) {
        setState(() {
          _errorText = message;
        });
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _secondsRemaining = 60;
      });

      Timer.periodic(const Duration(seconds: 1), (timer) {
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
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorText = 'Failed to resend code: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final email = (args['email'] ?? '').toString();

    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(24, 85, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const SizedBox(height: 6),
                const NutechLogo(),
                const SizedBox(height: 24),
                const Text(
                  'Reset Password',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a 4-digit code to $email',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Enter Verification Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 18),
                CodeInput(
                  length: 4,
                  onChanged: (value) {
                    setState(() {
                      _enteredCode = value;
                    });
                  },
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("If you didn’t receive a code. "),
                    GestureDetector(
                      onTap: (_secondsRemaining > 0 || _isResending)
                          ? null
                          : _handleResend,
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
                if (_secondsRemaining > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    'You can resend in $_secondsRemaining s',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
                const SizedBox(height: 26),
                PrimaryButton(
                  label: 'Verify Code',
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


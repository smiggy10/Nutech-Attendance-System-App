import 'package:flutter/material.dart';

import '../../models/registration_data.dart';
import '../../services/n8n_api.dart';
import '../../widgets/nutech_background.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/code_input.dart';
import '../../widgets/nutech_logo.dart';
import '../home/home_shell.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  static const route = '/verify-email';

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  String _otp = '';
  bool _loading = false;
  RegistrationData? _registrationData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _registrationData ??= ModalRoute.of(context)?.settings.arguments
        as RegistrationData?;
  }

  Future<void> _onConfirm() async {
    final data = _registrationData;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Please register again.')),
      );
      return;
    }
    if (_otp.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 4-digit code from your email')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await N8nApi.verifyOtp(email: data.email, otp: _otp);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, HomeShell.route);
    } on N8nApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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
                CodeInput(
                  length: 4,
                  onChanged: (value) => setState(() => _otp = value),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("If you didn't receive a code. "),
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
                  label: _loading ? 'Verifying…' : 'Confirm',
                  onPressed: _loading ? null : _onConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

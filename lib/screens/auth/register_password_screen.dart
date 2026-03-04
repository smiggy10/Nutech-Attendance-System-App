import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/nutech_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/nutech_logo.dart'; 
import 'verify_email_screen.dart';
import '../../services/n8n_api.dart';

class RegisterPasswordScreen extends StatefulWidget {
  const RegisterPasswordScreen({super.key});

  static const route = '/register-password';

  @override
  State<RegisterPasswordScreen> createState() =>
      _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState
    extends State<RegisterPasswordScreen> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    if (_passController.text.isEmpty || _confirmPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    final fullRegistrationData = {
      ...args,
      'password': _passController.text,
    };

    setState(() {
      _isSubmitting = true;
    });

    try {
      final n8nPayload = <String, dynamic>{
        'fullName': fullRegistrationData['full_name'],
        'email': fullRegistrationData['email'],
        'address': fullRegistrationData['address'],
        'contactNumber': fullRegistrationData['contact_number'],
        'birthdate': fullRegistrationData['birthdate'],
        'password': fullRegistrationData['password'],
      };

      final response = await N8nApi.registerUser(n8nPayload);

      final success = response['success'] == true || response.isEmpty;
      final message = response['message']?.toString() ??
          'Registration submitted. Please check your email for the OTP.';

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

      Navigator.pushReplacementNamed(
        context, 
        VerifyEmailScreen.route,
        arguments: fullRegistrationData,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit registration: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Removed 'Scaffold' to allow NutechBackground to lock the background
    return NutechBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          // ✅ Keyboard hides when scrolling
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 🔙 Reusable back button
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
                'Create a Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 28),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter Password',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 10),

              NutechTextField(
                hint: 'Enter password',
                controller: _passController,
                obscureText: _obscure1,
                suffix: IconButton(
                  icon: Image.asset(
                    'assets/icons/visibility.png',
                    width: 22,
                    height: 22,
                  ),
                  onPressed: () =>
                      setState(() => _obscure1 = !_obscure1),
                ),
              ),

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirm Password',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 10),

              NutechTextField(
                hint: 'Re-enter password',
                controller: _confirmPassController,
                obscureText: _obscure2,
                suffix: IconButton(
                  icon: Image.asset(
                    'assets/icons/visibility.png',
                    width: 22,
                    height: 22,
                  ),
                  onPressed: () =>
                      setState(() => _obscure2 = !_obscure2),
                ),
              ),

              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Submit',
                onPressed: _isSubmitting ? null : _handleSubmit,
              ),

              // Extra space for large phone screens
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
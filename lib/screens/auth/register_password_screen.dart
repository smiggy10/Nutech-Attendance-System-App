import 'dart:io'; // ✅ 1. IMPORT dart:io to support the File type

import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/nutech_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/nutech_logo.dart'; 
import 'verify_email_screen.dart';

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

  // ✅ 2. Initialize controllers to capture the passwords
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  @override
  void dispose() {
    // ✅ Always dispose controllers to prevent memory leaks
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    // ✅ 3. Correctly receive the arguments Map passed from SignupScreen
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // ✅ 4. CORRECT THE VALIDATOR: Ensure passwords match before proceeding
    if (_passController.text.isEmpty || _confirmPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all password fields')),
      );
      return;
    }

    if (_passController.text != _confirmPassController.text) {
      // ✅ 5. Match the UI/flow requirements
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match!')),
      );
      return;
    }

    // ✅ 6. CREATE THE COMPLETE DATA OBJECT FOR THE NEXT STEP
    // The previous screen's data Map already includes 'profile_image'
    // This spread operator (...args) will preserve it.
    final fullRegistrationData = {
      ...args,
      'password': _passController.text,
    };

    // This print will verify that all data is now safe and consolidated.
    print('User details are complete and validated for OTP: $fullRegistrationData');

    // ✅ 7. PASS ALL COLLECTED DATA to the verification screen
    Navigator.pushReplacementNamed(
      context, 
      VerifyEmailScreen.route,
      arguments: fullRegistrationData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // 🔙 Reusable back button to Signup Screen
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),

                NutechTextField(
                  hint: 'Enter password',
                  controller: _passController, // ✅ Added controller
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 10),

                NutechTextField(
                  hint: 'Re-enter password',
                  controller: _confirmPassController, // ✅ Added controller
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

                const SizedBox(height: 22),

                PrimaryButton(
                  label: 'Submit',
                  onPressed: _handleSubmit, // ✅ Use the validation function
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/nutech_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/nutech_logo.dart'; // ✅ added
import 'register_password_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  static const route = '/signup';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 95, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                // ✅ Reusable Logo
                const NutechLogo(),

                // User ID
                const Text(
                  'User ID',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const NutechTextField(hint: 'Enter user id'),
                const SizedBox(height: 16),

                // Name
                const Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const NutechTextField(hint: 'Enter name'),
                const SizedBox(height: 16),

                // Email Address
                const Text(
                  'Email Address',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const NutechTextField(
                  hint: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Address
                const Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const NutechTextField(hint: 'Enter address'),
                const SizedBox(height: 16),

                // Contact Number
                const Text(
                  'Contact Number',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const NutechTextField(
                  hint: 'Enter contact number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Birthdate
                const Text(
                  'Birthdate',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const NutechTextField(
                  hint: 'Enter birthdate',
                  readOnly: true,
                ),

                const SizedBox(height: 22),

                PrimaryButton(
                  label: 'Continue',
                  onPressed: () =>
                      Navigator.pushNamed(context, RegisterPasswordScreen.route),
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
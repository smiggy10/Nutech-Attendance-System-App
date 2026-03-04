import 'package:flutter/material.dart';

import '../../models/registration_data.dart';
import '../../services/n8n_api.dart';
import '../../widgets/nutech_background.dart';
import '../../widgets/nutech_text_field.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/nutech_logo.dart';
import 'register_password_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  static const route = '/signup';

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _addressController = TextEditingController();
  final _birthdateController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final fullName = _nameController.text.trim();
    final email = _emailController.text.trim();
    final contactNumber = _contactController.text.trim();
    final address = _addressController.text.trim();
    final birthdate = _birthdateController.text.trim();

    if (fullName.isEmpty || email.isEmpty || contactNumber.isEmpty ||
        address.isEmpty || birthdate.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')),
        );
      }
      return;
    }

    setState(() => _loading = true);
    try {
      await N8nApi.registerUser(
        fullName: fullName,
        email: email,
        contactNumber: contactNumber,
        address: address,
        birthdate: birthdate,
      );
      if (!mounted) return;
      final data = RegistrationData(
        fullName: fullName,
        email: email,
        contactNumber: contactNumber,
        address: address,
        birthdate: birthdate,
      );
      Navigator.pushNamed(
        context,
        RegisterPasswordScreen.route,
        arguments: data,
      );
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
            padding: const EdgeInsets.fromLTRB(24, 95, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const NutechLogo(),

                const Text(
                  'Full Name',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Enter full name',
                  controller: _nameController,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Email Address',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Enter email',
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Address',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Enter address',
                  controller: _addressController,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Contact Number',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Enter contact number',
                  keyboardType: TextInputType.phone,
                  controller: _contactController,
                ),
                const SizedBox(height: 16),

                const Text(
                  'Birthdate',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Enter birthdate (e.g. 1990-01-15)',
                  controller: _birthdateController,
                ),
                const SizedBox(height: 22),

                PrimaryButton(
                  label: _loading ? 'Sending…' : 'Continue',
                  onPressed: _loading ? null : _onContinue,
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

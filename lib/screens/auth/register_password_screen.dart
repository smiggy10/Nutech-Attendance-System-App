import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

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
  State<RegisterPasswordScreen> createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isSubmitting = false;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      if (_passController.text.isEmpty) {
        _passwordError = null;
      } else if (_passController.text.length < 8) {
        _passwordError = 'Password must be at least 8 characters long.';
      } else {
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      if (_confirmPassController.text.isEmpty) {
        _confirmPasswordError = null;
      } else if (_passController.text != _confirmPassController.text) {
        _confirmPasswordError = 'Passwords do not match.';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool _isFormValid() {
    return _passController.text.length >= 8 &&
        _passController.text == _confirmPassController.text &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  Future<void> _handleSubmit() async {
    // Run validation first
    _validatePassword();
    _validateConfirmPassword();

    // Check if form is valid
    if (!_isFormValid()) {
      return;
    }

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final fullRegistrationData = {...args, 'password': _passController.text};

    // Prepare base64-encoded profile image for n8n (if available).
    String profileImageBase64 = '';
    final dynamic image = fullRegistrationData['profile_image'];
    if (image != null) {
      try {
        // Handle web image URLs
        if (kIsWeb && image is String) {
          // For web, download the image from URL and convert to base64
          final response = await http.get(Uri.parse(image));
          if (response.statusCode == 200) {
            profileImageBase64 = base64Encode(response.bodyBytes);
          }
        } else if (image is File) {
          // For mobile, read file directly
          final bytes = await image.readAsBytes();
          profileImageBase64 = base64Encode(bytes);
        } else {
          // Try to read bytes directly for other cases
          final bytes = await image.readAsBytes();
          profileImageBase64 = base64Encode(bytes);
        }
      } catch (e) {
        // If image reading fails, continue without image
        print('Warning: Could not read profile image: $e');
      }
    }

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
        // n8n workflow expects this exact key.
        'profileImageBase64': profileImageBase64,
      };

      final response = await N8nApi.registerUser(n8nPayload);

      final success = response['success'] == true || response.isEmpty;
      final message =
          response['message']?.toString() ??
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 28),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Enter Password',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              NutechTextField(
                hint: 'Enter password',
                controller: _passController,
                obscureText: _obscure1,
                onChanged: (value) => _validatePassword(),
                suffix: IconButton(
                  icon: Image.asset(
                    'assets/icons/visibility.png',
                    width: 22,
                    height: 22,
                  ),
                  onPressed: () => setState(() => _obscure1 = !_obscure1),
                ),
              ),
              if (_passwordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _passwordError!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 18),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Confirm Password',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              NutechTextField(
                hint: 'Re-enter password',
                controller: _confirmPassController,
                obscureText: _obscure2,
                onChanged: (value) => _validateConfirmPassword(),
                suffix: IconButton(
                  icon: Image.asset(
                    'assets/icons/visibility.png',
                    width: 22,
                    height: 22,
                  ),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ),
              if (_confirmPasswordError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _confirmPasswordError!,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              PrimaryButton(
                label: 'Submit',
                onPressed: (_isSubmitting || !_isFormValid())
                    ? null
                    : _handleSubmit,
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

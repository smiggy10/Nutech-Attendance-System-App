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

  // ✅ 2. Initialize controllers to capture the passwords
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    // ✅ Always dispose controllers to prevent memory leaks
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
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

    // ✅ 6. CREATE THE COMPLETE DATA OBJECT FOR n8n + NEXT STEP
    final fullRegistrationData = {
      ...args,
      'password': _passController.text,
    };

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Map Flutter field names to a clean JSON payload for n8n.
      final n8nPayload = <String, dynamic>{
        'fullName': fullRegistrationData['full_name'],
        'email': fullRegistrationData['email'],
        'address': fullRegistrationData['address'],
        'contactNumber': fullRegistrationData['contact_number'],
        'birthdate': fullRegistrationData['birthdate'],
        'password': fullRegistrationData['password'],
        // profileImage can be wired later (e.g. upload URL / base64)
      };

      final response = await N8nApi.registerUser(n8nPayload);

      // You can shape your workflow to return { success: true, message: '...' }
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

      // ✅ PASS ALL COLLECTED DATA (including email) to the OTP screen
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
                  onPressed: _isSubmitting ? null : _handleSubmit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
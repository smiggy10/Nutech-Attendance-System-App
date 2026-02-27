import 'package:flutter/material.dart';

import '../../widgets/nutech_background.dart';
import '../../widgets/nutech_text_field.dart';
import '../../widgets/primary_button.dart';
import 'verify_email_screen.dart';

class RegisterPasswordScreen extends StatefulWidget {
  const RegisterPasswordScreen({super.key});

  static const route = '/register-password';

  @override
  State<RegisterPasswordScreen> createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
  bool _obscure1 = true;
  bool _obscure2 = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NutechBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const SizedBox(height: 6),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black.withOpacity(0.15)),
                  ),
                  child: const Text(
                    'NUTECH\nHARDWARE & SOFTWARE SOLUTIONS',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),

                const SizedBox(height: 28),
                const Text('Create a Password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 28),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Enter Password', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Enter password',
                  obscureText: _obscure1,
                  suffix: IconButton(
                    icon: Image.asset('assets/icons/visibility.png', width: 22, height: 22),
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                  ),
                ),

                const SizedBox(height: 18),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Confirm Password', style: Theme.of(context).textTheme.titleMedium),
                ),
                const SizedBox(height: 10),
                NutechTextField(
                  hint: 'Re-enter password',
                  obscureText: _obscure2,
                  suffix: IconButton(
                    icon: Image.asset('assets/icons/visibility.png', width: 22, height: 22),
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                  ),
                ),

                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Submit',
                  onPressed: () => Navigator.pushReplacementNamed(context, VerifyEmailScreen.route),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/primary_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Teal header
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 240,
          child: Container(color: AppTheme.teal.withOpacity(0.55)),
        ),

        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 42,
                    backgroundImage: AssetImage('assets/images/avatar.png'),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.tealSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    const Text('Information Details', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    const _InfoRow(icon: Icons.badge_outlined, label: 'user id', value: 'EMP26N001'),
                    const _InfoRow(icon: Icons.person_outline, label: 'name', value: 'Juan Reynolds'),
                    const _InfoRow(icon: Icons.email_outlined, label: 'email', value: 'juan.reynolds@gmail.com'),
                    const _InfoRow(icon: Icons.home_outlined, label: 'address', value: 'Marauoy, Lipa City, Batangas'),
                    const _InfoRow(icon: Icons.call_outlined, label: 'contact no.', value: '0912 345 6789'),
                    const _InfoRow(icon: Icons.calendar_month_outlined, label: 'birthdate', value: '01/01/1999'),
                    const SizedBox(height: 16),

                    const Text('System Access', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    const _CheckRow(text: 'IC Card Access Linked'),
                    const SizedBox(height: 8),
                    const _CheckRow(text: 'Face ID Registered'),

                    const SizedBox(height: 18),
                    PrimaryButton(label: 'Logout', isDanger: true, onPressed: () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Icon(icon, color: AppTheme.teal, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(color: Color(0xFFB5BCC1))),
          ),
          Expanded(
            flex: 2,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: AppTheme.teal),
        const SizedBox(width: 10),
        Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

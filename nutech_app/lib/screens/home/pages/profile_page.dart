import 'package:flutter/material.dart';

import '../edit_profile_screen.dart';
import '../../auth/login_screen.dart';

import '../../../theme/app_theme.dart';
import '../../../widgets/primary_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background teal header (match the look)
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 300,
          child: Container(
            color: AppTheme.teal.withOpacity(0.55),
          ),
        ),

        // Main content
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 70, 18, 26),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Card pushed down a bit so avatar can overlap
              Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Information Details',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 16),

                      const _InfoRow(
                        icon: Icons.badge_outlined,
                        label: 'user id',
                        value: 'EMP26N001',
                      ),
                      const _InfoRow(
                        icon: Icons.person_outline,
                        label: 'name',
                        value: 'Juan Reynolds',
                      ),
                      const _InfoRow(
                        icon: Icons.email_outlined,
                        label: 'email',
                        value: 'juan.reynolds@gmail.com',
                      ),
                      const _InfoRow(
                        icon: Icons.home_outlined,
                        label: 'address',
                        value: 'Marauoy, Lipa City, Batangas',
                      ),
                      const _InfoRow(
                        icon: Icons.call_outlined,
                        label: 'contact no.',
                        value: '0912 345 6789',
                      ),
                      const _InfoRow(
                        icon: Icons.calendar_month_outlined,
                        label: 'birthdate',
                        value: '01/01/1999',
                      ),

                      const SizedBox(height: 18),

                      const Text(
                        'System Access',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 12),

                      const _CheckRow(text: 'IC Card Access Linked'),
                      const SizedBox(height: 10),
                      const _CheckRow(text: 'Face ID Registered'),

                      const SizedBox(height: 22),

                      // Logout button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: PrimaryButton(
                          label: 'Logout',
                          isDanger: true,
                          onPressed: () => _confirmLogout(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top row: Avatar + Edit button (overlapping card like your target)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar (bigger + overlaps)
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const CircleAvatar(
                        radius: 42,

                        // ✅ IMPORTANT:
                        // Use the avatar asset you actually have.
                        // If your avatar is in assets/images/ui/avatar.png, change this path.
                        backgroundImage: AssetImage('assets/images/avatar.png'),
                      ),
                    ),

                    const Spacer(),

                    // Clickable "Edit Profile" pill button
                    InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.pushNamed(context, EditProfileScreen.route);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.tealSoft,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Text(
                          'Edit Profile',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true) return;

    // Go back to login and clear stack
    Navigator.pushNamedAndRemoveUntil(
      context,
      LoginScreen.route,
      (route) => false,
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Icon(icon, color: AppTheme.teal, size: 20),
          ),
          const SizedBox(width: 10),

          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFFB5BCC1)),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
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
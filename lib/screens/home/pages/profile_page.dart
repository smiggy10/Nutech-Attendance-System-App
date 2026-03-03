import 'package:flutter/material.dart';
import '../../auth/login_screen.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/primary_button.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace this with your actual registration logic/state management
    // For now, change this to 'true' to see the credentials
    bool isRegistered = false; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. STATIC BACKGROUND HEADER
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 300,
            child: Container(
              color: AppTheme.teal.withOpacity(0.55),
            ),
          ),

          // 2. FIXED BOTTOM BACKGROUND (Visible in both states for UI consistency)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/ui/bottombackground2.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),

          // 3. MAIN CONTENT
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!isRegistered)
                    // EMPTY STATE: Displays when no registration exists
                    _buildEmptyState()
                  else
                    // REGISTERED STATE: Displays credentials when registered
                    _buildProfileCard(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for the empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            'No Registration Found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Register your account to see your details here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Widget for the profile card with credentials
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage('assets/images/avatar.png'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Juan Reynolds',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const Text(
            'Field Technician',
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 30),
          
          // Section Divider
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'INFORMATION DETAILS',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black26, letterSpacing: 1.2),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),

          // Credentials
          const _InfoRow(icon: Icons.badge_outlined, label: 'user id', value: 'EMP26N001'),
          const _InfoRow(icon: Icons.person_outline, label: 'name', value: 'Juan Reynolds'),
          const _InfoRow(icon: Icons.email_outlined, label: 'email', value: 'juan.reynolds@gmail.com'),
          const _InfoRow(icon: Icons.home_outlined, label: 'address', value: 'Marauoy, Lipa City, Batangas'),
          const _InfoRow(icon: Icons.call_outlined, label: 'contact no.', value: '0912 345 6789'),
          const _InfoRow(icon: Icons.calendar_month_outlined, label: 'birthdate', value: '01/01/1999'),

          const SizedBox(height: 40),

          // Logout button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: PrimaryButton(
              label: 'Logout Account',
              isDanger: true,
              onPressed: () => _confirmLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('Are you sure you want to end your session?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Logout')),
        ],
      ),
    );
    if (shouldLogout == true) {
      Navigator.pushNamedAndRemoveUntil(context, LoginScreen.route, (route) => false);
    }
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.teal.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.teal, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label.toUpperCase(), style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
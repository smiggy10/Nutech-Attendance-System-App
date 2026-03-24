import 'package:flutter/material.dart';

import '../../auth/login_screen.dart';
import '../../../services/n8n_api.dart'; // Ensure N8nApi is imported
import '../../../services/user_profile_service.dart';
import '../../../services/user_session.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/employee_profile_card.dart';

class ProfilePage extends StatefulWidget {
  // ADDED: targetUserId allows this page to be reused by the Admin side
  final String? targetUserId;

  const ProfilePage({super.key, this.targetUserId});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchEverything();
  }

  // UPDATED: Now uses targetUserId if provided, otherwise defaults to current session
  Future<Map<String, dynamic>> _fetchEverything() async {
    final String? effectiveId =
        widget.targetUserId ?? UserSession.loginIdentifier;

    if (effectiveId == null || effectiveId.isEmpty) {
      return {
        'profile': null,
        'stats': const UserStats(totalHours: 0, lates: 0, absences: 0),
      };
    }

    final results = await Future.wait([
      _fetchProfileById(effectiveId),
      UserProfileService.fetchUserStats(effectiveId),
    ]);

    return {
      'profile': results[0] as UserProfile?,
      'stats': results[1] as UserStats,
    };
  }

  // NEW: Helper to fetch any profile by a specific ID (Standardizing the API call)
  Future<UserProfile?> _fetchProfileById(String userId) async {
    try {
      final response = await N8nApi.getUserProfile(identifier: userId);
      if (response['success'] == true && response['data'] != null) {
        return UserProfile.fromJson(
          Map<String, dynamic>.from(response['data']),
        );
      }
    } catch (e) {
      debugPrint('Error fetching profile by ID: $e');
    }
    return null;
  }

  Future<void> _reload() async {
    setState(() {
      _future = _fetchEverything();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final data = snapshot.data;
        final profile = data?['profile'] as UserProfile?;
        final stats = data?['stats'] as UserStats?;

        if (profile == null) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _reload,
          color: AppTheme.teal,
          child: Column(
            children: [
              // Back button for admin navigation - matching employee list design
              if (widget.targetUserId != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppTheme.teal,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const Expanded(
                        child: Text(
                          'Employee Details',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: EmployeeProfileCard(
                    profile: profile,
                    stats: stats,
                    // UPDATED: Hide logout button if an Admin is viewing this (targetUserId is not null)
                    showLogoutButton: widget.targetUserId == null,
                    onLogout: widget.targetUserId == null
                        ? () => _confirmLogout(context)
                        : null,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
            Icon(
              Icons.account_circle_outlined,
              size: 80,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Profile Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No employee profile was returned from Airtable.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: _reload, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
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
            const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Failed to Load Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: _reload, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirm Logout',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: const Text('Are you sure you want to end your session?'),
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

    if (shouldLogout == true && mounted) {
      UserSession.clear();
      Navigator.pushNamedAndRemoveUntil(
        context,
        LoginScreen.route,
        (route) => false,
      );
    }
  }
}

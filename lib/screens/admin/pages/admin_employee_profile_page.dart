import 'package:flutter/material.dart';

import '../../../services/n8n_api.dart';
import '../../../services/user_profile_service.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/employee_profile_card.dart';

/// Admin view of an employee profile — same card design as employee [ProfilePage].
class AdminEmployeeProfilePage extends StatefulWidget {
  const AdminEmployeeProfilePage({
    super.key,
    required this.userId,
  });

  final String userId;

  @override
  State<AdminEmployeeProfilePage> createState() =>
      _AdminEmployeeProfilePageState();
}

class _AdminEmployeeProfilePageState extends State<AdminEmployeeProfilePage> {
  late Future<UserProfile?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<UserProfile?> _fetch() async {
    final uid = widget.userId.trim();
    if (uid.isEmpty) {
      throw Exception('Missing user id.');
    }

    final response = await N8nApi.getUserProfile(identifier: uid);
    final success = response['success'] == true;
    final message = (response['message'] ?? '').toString();
    final data = response['data'];

    if (!success) {
      throw Exception(
        message.isEmpty ? 'Failed to load profile.' : message,
      );
    }

    if (data is! Map) {
      return null;
    }

    return UserProfile.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> _reload() async {
    setState(() {
      _future = _fetch();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFFF7FBFB)],
        ),
      ),
      child: FutureBuilder<UserProfile?>(
        future: _future,
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppTheme.teal,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final profile = snapshot.data;
        if (profile == null) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: _reload,
          color: AppTheme.teal,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppTheme.teal,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 8),
                EmployeeProfileCard(profile: profile),
              ],
            ),
          ),
        );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.teal,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: 24),
        Center(
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
                  'No employee profile was returned for this user.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                OutlinedButton(onPressed: _reload, child: const Text('Retry')),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppTheme.teal,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        const SizedBox(height: 24),
        Center(
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
        ),
      ],
    );
  }
}

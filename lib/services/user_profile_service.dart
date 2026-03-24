import 'n8n_api.dart';
import 'user_session.dart';

// 1. The new model to hold the calculated stats
class UserStats {
  final double totalHours;
  final int lates;
  final int absences;

  const UserStats({
    required this.totalHours,
    required this.lates,
    required this.absences,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalHours: (json['totalHours'] ?? 0).toDouble(),
      lates: (json['lates'] ?? 0).toInt(),
      absences: (json['absences'] ?? 0).toInt(),
    );
  }
}

// Your existing profile model
class UserProfile {
  final String userId;
  final String fullName;
  final String email;
  final String address;
  final String contactNumber;
  final String birthdate;
  final String position;
  final String profileImageUrl;

  const UserProfile({
    required this.userId,
    required this.fullName,
    required this.email,
    required this.address,
    required this.contactNumber,
    required this.birthdate,
    required this.position,
    required this.profileImageUrl,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: (json['userId'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      address: (json['address'] ?? '').toString(),
      contactNumber: (json['contactNumber'] ?? '').toString(),
      birthdate: (json['birthdate'] ?? '').toString(),
      position: (json['position'] ?? '').toString(),
      profileImageUrl: (json['profileImageUrl'] ?? '').toString(),
    );
  }
}

class UserProfileService {
  UserProfileService._();

  // Your existing profile fetcher
  static Future<UserProfile?> fetchCurrentUserProfile() async {
    final identifier = UserSession.loginIdentifier;

    if (identifier == null || identifier.isEmpty) {
      return null;
    }

    final response = await N8nApi.getUserProfile(identifier: identifier);

    final success = response['success'] == true;
    final message = (response['message'] ?? '').toString();
    final data = response['data'];

    if (!success) {
      if (message.toLowerCase().contains('not found')) {
        return null;
      }

      throw Exception(
        message.isEmpty ? 'Failed to fetch profile.' : message,
      );
    }

    if (data is! Map) {
      return null;
    }

    return UserProfile.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // 2. The missing method that your ProfilePage is looking for!
  static Future<UserStats> fetchCurrentUserStats() async {
    final identifier = UserSession.loginIdentifier;

    if (identifier == null || identifier.isEmpty) {
      return const UserStats(totalHours: 0.0, lates: 0, absences: 0);
    }

    try {
      // Calls your existing N8nApi.getUserLogs method
      final response = await N8nApi.getUserLogs(identifier: identifier);

      final success = response['success'] == true;
      final data = response['data'];

      if (success && data != null && data['summary'] != null) {
        return UserStats.fromJson(Map<String, dynamic>.from(data['summary']));
      }
    } catch (e) {
      print('Error fetching user stats: $e');
    }

    // Return empty stats if the request fails so the UI doesn't crash
    return const UserStats(totalHours: 0.0, lates: 0, absences: 0);
  }
  static Future<UserStats> fetchUserStats(String userId) async {
    if (userId.isEmpty) {
      return const UserStats(totalHours: 0.0, lates: 0, absences: 0);
    }

    try {
      // Passes the specific employee's ID to n8n instead of the logged-in user
      final response = await N8nApi.getUserStats(identifier: userId);

      final success = response['success'] == true;
      final data = response['data'];

      if (success && data != null && data['summary'] != null) {
        return UserStats.fromJson(Map<String, dynamic>.from(data['summary']));
      }
    } catch (e) {
      print('Error fetching user stats: $e');
    }

    return const UserStats(totalHours: 0.0, lates: 0, absences: 0);
  }
}
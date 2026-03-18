import 'n8n_api.dart';
import 'user_session.dart';

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
}
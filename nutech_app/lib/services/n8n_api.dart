import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL of your n8n instance.
///
/// You can override this at build time with:
/// `--dart-define=N8N_BASE_URL=https://your-n8n.com`
const String n8nBaseUrl =
    String.fromEnvironment('N8N_BASE_URL', defaultValue: 'http://localhost:5678');

/// Basic check so that obviously placeholder URLs can be detected.
bool get isN8nConfigured =>
    !RegExp(r'YOUR-N8N|placeholder|example\.com', caseSensitive: false)
        .hasMatch(n8nBaseUrl);

class N8nWebhooks {
  const N8nWebhooks._();

  static const String userRegister = '/webhook/register/user';
  static const String verifyOtp = '/webhook/verify/otp';
  static const String userLogin = '/webhook/login/user';
}

class N8nApiException implements Exception {
  N8nApiException(this.message);
  final String message;

  @override
  String toString() => 'N8nApiException: $message';
}

class N8nApi {
  const N8nApi._();

  static Uri _uri(String path) => Uri.parse('$n8nBaseUrl$path');

  /// User registration → sends basic profile data to n8n.
  static Future<void> registerUser({
    required String fullName,
    required String email,
    required String contactNumber,
    required String address,
    required String birthdate,
  }) async {
    if (!isN8nConfigured) return;

    final response = await http.post(
      _uri(N8nWebhooks.userRegister),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'contactNumber': contactNumber,
        'address': address,
        'birthdate': birthdate,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw N8nApiException(
        'Registration failed (${response.statusCode})',
      );
    }
  }

  /// Verify OTP after registration.
  static Future<void> verifyOtp({
    required String email,
    required String otp,
  }) async {
    if (!isN8nConfigured) return;

    final response = await http.post(
      _uri(N8nWebhooks.verifyOtp),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'otp': otp,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw N8nApiException(
        'OTP verification failed (${response.statusCode})',
      );
    }
  }

  /// User login via n8n.
  ///
  /// By default this expects n8n to validate:
  /// - userId exists in Airtable / your sheet
  /// - password matches n8n-side rule (e.g. static `test123` or stored hash)
  static Future<void> login({
    required String userId,
    required String password,
  }) async {
    if (!isN8nConfigured) return;

    final response = await http.post(
      _uri(N8nWebhooks.userLogin),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'password': password,
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw N8nApiException(
        'Login failed (${response.statusCode})',
      );
    }
  }
}


import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL of your n8n instance.
///
/// You are using **n8n Cloud**, so this should be your cloud domain,
/// e.g. https://bernard100.app.n8n.cloud
///
/// You can still override this via the N8N_BASE_URL Dart define when needed.
const String kN8nBaseUrl = String.fromEnvironment(
  'N8N_BASE_URL',
  defaultValue: 'https://bernard100.app.n8n.cloud',
);

/// Simple flag so we can skip calls if the URL is obviously not configured.
bool get isN8nConfigured {
  return !RegExp(r'YOUR-N8N|placeholder|example\.com', caseSensitive: false)
      .hasMatch(kN8nBaseUrl);
}

/// n8n webhook paths (will be joined with [kN8nBaseUrl]).
class N8nWebhooks {
  static const String userRegister = '/webhook/register/user';
  static const String verifyOtp = '/webhook/verify/otp';
  static const String userLogin = '/webhook/login/user';
}

class N8nApi {
  const N8nApi._();

  static Uri _buildUri(String path) {
    return Uri.parse(kN8nBaseUrl + path);
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    if (!isN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL or update kN8nBaseUrl.',
      );
    }

    final uri = _buildUri(path);
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'n8n request failed (${response.statusCode}): ${response.body}',
      );
    }

    if (response.body.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return <String, dynamic>{'data': decoded};
  }

  /// Send registration data to n8n so it can:
  /// - validate
  /// - generate & send OTP
  /// - prepare data for Airtable
  ///
  /// Expected body (you can adjust the workflow to match):
  /// {
  ///   "fullName": "...",
  ///   "email": "...",
  ///   "address": "...",
  ///   "contactNumber": "...",
  ///   "birthdate": "...", // string, e.g. MM/dd/yyyy
  ///   "password": "...",
  ///   "profileImage": "<base64 or URL if you wire uploads later>"
  /// }
  static Future<Map<String, dynamic>> registerUser(
    Map<String, dynamic> payload,
  ) {
    return _postJson(N8nWebhooks.userRegister, payload);
  }

  /// Verify OTP after registration.
  ///
  /// Suggested payload:
  /// {
  ///   "email": "...",
  ///   "otp": "1234"
  /// }
  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _postJson(N8nWebhooks.verifyOtp, {
      'email': email,
      'otp': otp,
    });
  }

  /// User login via n8n.
  ///
  /// Suggested payload:
  /// {
  ///   "userId": "...",
  ///   "password": "test123" // or whatever you decide in the workflow
  /// }
  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) {
    return _postJson(N8nWebhooks.userLogin, {
      'userId': userId,
      'password': password,
    });
  }
}


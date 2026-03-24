import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base URL of your n8n instance.
const String kN8nBaseUrl = String.fromEnvironment(
  'N8N_BASE_URL',
  defaultValue: 'https://smiggyn8n.app.n8n.cloud',
);

bool get isN8nConfigured {
  return !RegExp(
    r'YOUR-N8N|placeholder|example\.com',
    caseSensitive: false,
  ).hasMatch(kN8nBaseUrl);
}

class N8nWebhooks {
  static const String userRegister = '/webhook/register/user';
  static const String verifyOtp = '/webhook/verify/otp';
  static const String userLogin = '/webhook/login/user';
  static const String resendOtp = '/webhook/resend/otp';

  static const String forgotRequest = '/webhook/forgot-password/request';
  static const String forgotResend = '/webhook/forgot-password/resend';
  static const String forgotVerify = '/webhook/forgot-password/verify';
  static const String forgotReset = '/webhook/forgot-password/reset';

  static const String adminPending = '/webhook/admin/pending';
  static const String adminAction = '/webhook/admin/action';
  static const String adminEmployees = '/webhook/admin/employees';

  static const String userProfile = '/webhook/user/profile';
  static const String userLogs = '/webhook/user/logs';
  // --- NEW: Added the User Stats Webhook ---
  static const String userStats = '/webhook/user/stats'; 
}

class N8nApi {
  const N8nApi._();

  static Uri _buildUri(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    final uri = Uri.parse(kN8nBaseUrl + path);

    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    return uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        ...queryParameters,
      },
    );
  }

  static Future<Map<String, dynamic>> _postJson(
    String path,
    Map<String, dynamic> body, {
    bool throwOnNon2xx = true,
  }) async {
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
      if (throwOnNon2xx) {
        throw Exception(
          'n8n request failed (${response.statusCode}): ${response.body}',
        );
      }
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

  static Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? queryParameters,
    bool throwOnNon2xx = true,
  }) async {
    if (!isN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL or update kN8nBaseUrl.',
      );
    }

    final uri = _buildUri(
      path,
      queryParameters: queryParameters,
    );

    final response = await http.get(uri);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      if (throwOnNon2xx) {
        throw Exception(
          'n8n request failed (${response.statusCode}): ${response.body}',
        );
      }
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

  static Future<Map<String, dynamic>> registerUser(
    Map<String, dynamic> payload,
  ) {
    return _postJson(N8nWebhooks.userRegister, payload);
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) {
    return _postJson(
      N8nWebhooks.verifyOtp,
      {
        'email': email,
        'otp': otp,
      },
    );
  }

  static Future<Map<String, dynamic>> login({
    required String userId,
    required String password,
  }) {
    return _postJson(
      N8nWebhooks.userLogin,
      {
        'userId': userId,
        'password': password,
      },
    );
  }

  static Future<Map<String, dynamic>> getUserProfile({
    required String identifier,
  }) {
    return _getJson(
      N8nWebhooks.userProfile,
      queryParameters: {
        'identifier': identifier,
      },
      throwOnNon2xx: false,
    );
  }

  static Future<Map<String, dynamic>> getUserLogs({
    required String identifier,
  }) {
    return _getJson(
      N8nWebhooks.userLogs,
      queryParameters: {
        'identifier': identifier,
      },
      throwOnNon2xx: false,
    );
  }

  // --- NEW: Added the getUserStats method ---
  static Future<Map<String, dynamic>> getUserStats({
    required String identifier,
  }) {
    return _postJson(
      N8nWebhooks.userStats,
      {
        'userId': identifier,
      },
      throwOnNon2xx: false,
    );
  }

  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) {
    return _postJson(
      N8nWebhooks.resendOtp,
      {
        'email': email,
      },
    );
  }

  static Future<Map<String, dynamic>> forgotPasswordRequest({
    required String email,
  }) {
    return _postJson(
      N8nWebhooks.forgotRequest,
      {
        'email': email,
      },
      throwOnNon2xx: false,
    );
  }

  static Future<Map<String, dynamic>> forgotPasswordResend({
    required String email,
  }) {
    return _postJson(
      N8nWebhooks.forgotResend,
      {
        'email': email,
      },
      throwOnNon2xx: false,
    );
  }

  static Future<Map<String, dynamic>> forgotPasswordVerify({
    required String email,
    required String otp,
  }) {
    return _postJson(
      N8nWebhooks.forgotVerify,
      {
        'email': email,
        'otp': otp,
      },
    );
  }

  static Future<Map<String, dynamic>> forgotPasswordReset({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _postJson(
      N8nWebhooks.forgotReset,
      {
        'email': email,
        'token': token,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
  }

  static Future<Map<String, dynamic>> getAdminPending() {
    return _getJson(
      N8nWebhooks.adminPending,
      throwOnNon2xx: false,
    );
  }

  static Future<Map<String, dynamic>> adminAction({
    required String airtableId,
    required String email,
    required String fullName,
    required String action,
  }) {
    return _postJson(
      N8nWebhooks.adminAction,
      {
        'airtableId': airtableId,
        'email': email,
        'fullName': fullName,
        'action': action,
      },
      throwOnNon2xx: false,
    );
  }

  /// Admin: list all employees (empty JSON body).
  static Future<Map<String, dynamic>> postAdminEmployees() {
    return _postJson(
      N8nWebhooks.adminEmployees,
      <String, dynamic>{},
      throwOnNon2xx: false,
    );
  }
}
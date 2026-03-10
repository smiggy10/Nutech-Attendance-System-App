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
  static const String resendOtp = '/webhook/resend/otp';
  static const String forgotRequest = '/webhook/forgot-password/request';
  static const String forgotResend = '/webhook/forgot-password/resend';
  static const String forgotVerify = '/webhook/forgot-password/verify';
  static const String forgotReset = '/webhook/forgot-password/reset';
  static const String adminPending = '/webhook/admin/pending';
  static const String adminAction = '/webhook/admin/action';
}

class N8nApi {
  const N8nApi._();

  static Uri _buildUri(String path) {
    return Uri.parse(kN8nBaseUrl + path);
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
      // When throwOnNon2xx is false (e.g. forgot-password flow),
      // we continue and let the caller inspect the JSON body's
      // success / message fields.
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
    bool throwOnNon2xx = true,
  }) async {
    if (!isN8nConfigured) {
      throw Exception(
        'n8n base URL is not configured. Please set N8N_BASE_URL or update kN8nBaseUrl.',
      );
    }

    final uri = _buildUri(path);
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

  /// Resend registration OTP.
  static Future<Map<String, dynamic>> resendOtp({
    required String email,
  }) {
    return _postJson(N8nWebhooks.resendOtp, {
      'email': email,
    });
  }

  /// Forgot password: request reset code.
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

  /// Forgot password: resend reset code.
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

  /// Forgot password: verify OTP and receive token.
  static Future<Map<String, dynamic>> forgotPasswordVerify({
    required String email,
    required String otp,
  }) {
    return _postJson(N8nWebhooks.forgotVerify, {
      'email': email,
      'otp': otp,
    });
  }

  /// Forgot password: reset password using token.
  static Future<Map<String, dynamic>> forgotPasswordReset({
    required String email,
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _postJson(N8nWebhooks.forgotReset, {
      'email': email,
      'token': token,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    });
  }

  /// Admin: get pending registrations. Returns { success, count, pending }.
  /// Caller should check success and use pending list; errors return success: false, message.
  static Future<Map<String, dynamic>> getAdminPending() {
    return _getJson(N8nWebhooks.adminPending, throwOnNon2xx: false);
  }

  /// Admin: accept or reject a registration. Returns { success, message }.
  /// Caller should check success; errors return success: false, message.
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
}


import 'package:nutech_app/services/n8n_api.dart';
import 'package:nutech_app/services/user_profile_service.dart';

/// Fallback loader for profile photos when a webhook row has no `profileImageUrl`.
///
/// Prefer passing a non-empty URL from the attendance/summary payload (Airtable)
/// so this is never called for those rows.
///
/// Uses `GET /webhook/user/profile?identifier=<userId>` — same as
/// [AdminEmployeeProfilePage]. Results are cached in memory for the session.
class AdminProfilePhotoResolver {
  AdminProfilePhotoResolver._();

  static final Map<String, String> _cache = {};
  static final Map<String, Future<String>> _pending = {};

  /// Fetches `data.profileImageUrl` from the profile webhook (or `''` on failure).
  static Future<String> fetchFromProfileApi(String userId) async {
    final id = userId.trim();
    if (id.isEmpty) return '';

    if (_cache.containsKey(id)) return _cache[id]!;

    return _pending.putIfAbsent(
      id,
      () => _fetch(id).whenComplete(() => _pending.remove(id)),
    );
  }

  static Future<String> _fetch(String id) async {
    try {
      final response = await N8nApi.getUserProfile(identifier: id);
      final success = response['success'] == true;
      final data = response['data'];
      var url = '';
      if (success && data is Map) {
        url = UserProfile.fromJson(
          Map<String, dynamic>.from(data),
        ).profileImageUrl.trim();
      }
      _cache[id] = url;
      return url;
    } catch (_) {
      _cache[id] = '';
      return '';
    }
  }
}

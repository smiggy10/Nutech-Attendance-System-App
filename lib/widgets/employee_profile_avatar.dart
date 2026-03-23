import 'package:flutter/material.dart';
import 'package:nutech_app/services/admin_profile_photo_resolver.dart';
import 'package:nutech_app/widgets/employee_list_avatar.dart';

/// Avatar for admin report rows.
///
/// When [preferredImageUrl] is non-empty (e.g. from webhook `profileImageUrl`),
/// uses it directly — **no profile API call**.
///
/// When empty or missing, falls back to [AdminProfilePhotoResolver] (same
/// `GET /webhook/user/profile` as the employee profile screen), then the
/// placeholder asset.
class EmployeeProfileAvatar extends StatelessWidget {
  const EmployeeProfileAvatar({
    super.key,
    required this.userId,
    this.preferredImageUrl = '',
    this.size = 52,
  });

  final String userId;
  final String preferredImageUrl;
  final double size;

  static bool _isHttpUrl(String value) {
    final u = Uri.tryParse(value);
    if (u == null || !u.hasScheme) return false;
    return u.scheme == 'http' || u.scheme == 'https';
  }

  @override
  Widget build(BuildContext context) {
    final direct = preferredImageUrl.trim();
    if (_isHttpUrl(direct)) {
      return EmployeeListAvatar(imageUrl: direct, size: size);
    }
    return _EmployeeProfileAvatarFallback(
      userId: userId,
      size: size,
    );
  }
}

class _EmployeeProfileAvatarFallback extends StatefulWidget {
  const _EmployeeProfileAvatarFallback({
    required this.userId,
    required this.size,
  });

  final String userId;
  final double size;

  @override
  State<_EmployeeProfileAvatarFallback> createState() =>
      _EmployeeProfileAvatarFallbackState();
}

class _EmployeeProfileAvatarFallbackState
    extends State<_EmployeeProfileAvatarFallback> {
  String _url = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _EmployeeProfileAvatarFallback oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _url = '';
      _load();
    }
  }

  Future<void> _load() async {
    final url = await AdminProfilePhotoResolver.fetchFromProfileApi(
      widget.userId,
    );
    if (!mounted) return;
    setState(() => _url = url);
  }

  @override
  Widget build(BuildContext context) {
    return EmployeeListAvatar(imageUrl: _url, size: widget.size);
  }
}

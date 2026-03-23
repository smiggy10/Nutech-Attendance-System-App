import 'package:flutter/material.dart';

/// Circular avatar for employee rows in admin lists (network URL or placeholder).
class EmployeeListAvatar extends StatelessWidget {
  const EmployeeListAvatar({
    super.key,
    required this.imageUrl,
    this.size = 52,
  });

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl.trim();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isNotEmpty
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return Image.asset(
      'assets/images/avatar.png',
      fit: BoxFit.cover,
    );
  }
}

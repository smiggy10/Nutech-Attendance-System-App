import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutechTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  // ✅ add these
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;

  const NutechTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.controller,
    this.keyboardType = TextInputType.text,

    // ✅ new params with defaults
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled ? Colors.white : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,

        // ✅ pass through
        readOnly: readOnly,
        onTap: onTap,
        enabled: enabled,

        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffix == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: suffix,
                ),
          suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ),
    );
  }
}
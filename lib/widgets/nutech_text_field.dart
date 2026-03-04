import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NutechTextField extends StatelessWidget {
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextEditingController? controller;
  final TextInputType keyboardType;

  // ✅ Keep these existing ones
  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;

  // ✅ Add this to specifically handle icons if needed, 
  // though your code currently uses 'suffix' for this purpose.
  final Widget? suffixIcon; 

  const NutechTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.controller,
    this.keyboardType = TextInputType.text,

    // ✅ New params with defaults
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
    this.suffixIcon,
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

        // ✅ Pass through
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
          
          // logic to use either suffixIcon or suffix
          suffixIcon: (suffixIcon ?? suffix) == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: suffixIcon ?? suffix,
                ),
          suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        ),
      ),
    );
  }
}
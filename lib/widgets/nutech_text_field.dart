import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ Required for TextInputFormatter
import '../theme/app_theme.dart';

class NutechTextField extends StatefulWidget {
  final String hint;
  final bool obscureText;
  final Widget? suffix;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  final bool readOnly;
  final VoidCallback? onTap;
  final bool enabled;
  final Widget? suffixIcon;
  final FocusNode? focusNode;

  // ✅ Added this to accept the formatters from SignupScreen
  final List<TextInputFormatter>? inputFormatters;

  // Validation UI (non-layout shifting)
  final String? errorText;

  const NutechTextField({
    super.key,
    required this.hint,
    this.obscureText = false,
    this.suffix,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
    this.enabled = true,
    this.suffixIcon,
    this.focusNode,
    this.inputFormatters, // ✅ Add to constructor
    this.errorText,
  });

  @override
  State<NutechTextField> createState() => _NutechTextFieldState();
}

class _NutechTextFieldState extends State<NutechTextField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void didUpdateWidget(covariant NutechTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.errorText != widget.errorText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (widget.errorText == null || widget.errorText!.isEmpty) {
          _removeOverlay();
        } else {
          _showOrUpdateOverlay();
        }
      });
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showOrUpdateOverlay() {
    _removeOverlay();

    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final text = widget.errorText;
        if (text == null || text.isEmpty) return const SizedBox.shrink();

        return Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 64),
              child: Material(
                color: Colors.transparent,
                child: _FieldTooltip(message: text),
              ),
            ),
          ),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_overlayEntry == null) return;
      overlay.insert(_overlayEntry!);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: widget.enabled ? Colors.white : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasError ? Colors.redAccent : AppTheme.border,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          onTap: widget.onTap,
          enabled: widget.enabled,
          onChanged: widget.onChanged,

          // Pass the formatters into the internal TextField
          inputFormatters: widget.inputFormatters,

          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),

            suffixIcon: (widget.suffixIcon ?? widget.suffix) == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: widget.suffixIcon ?? widget.suffix,
                  ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldTooltip extends StatelessWidget {
  const _FieldTooltip({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black.withOpacity(0.18)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.14),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 18,
                  color: Colors.deepOrange,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: -6,
            left: 26,
            child: CustomPaint(
              size: const Size(14, 8),
              painter: _TooltipArrowPainter(
                fillColor: Colors.white,
                borderColor: Colors.black.withOpacity(0.18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TooltipArrowPainter extends CustomPainter {
  _TooltipArrowPainter({required this.fillColor, required this.borderColor});

  final Color fillColor;
  final Color borderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()..color = fillColor;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _TooltipArrowPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor;
  }
}

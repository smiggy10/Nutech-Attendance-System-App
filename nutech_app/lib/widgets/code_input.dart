import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A 4-digit OTP input. Reports the current value via [onChanged].
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    this.length = 4,
    this.onChanged,
  });

  final int length;
  final ValueChanged<String>? onChanged;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < widget.length; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _onChanged() {
    final value = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        return Container(
          width: 56,
          height: 56,
          margin: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFB9C2C7)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: _controllers[i],
            focusNode: _focusNodes[i],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              _onChanged();
              if (_controllers[i].text.isNotEmpty && i < widget.length - 1) {
                FocusScope.of(context).requestFocus(_focusNodes[i + 1]);
              }
            },
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        );
      }),
    );
  }
}

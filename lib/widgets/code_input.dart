import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    required this.length,
    this.onChanged, // ✅ Added to capture the code
  });

  final int length;
  final ValueChanged<String>? onChanged; // ✅ Callback function

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  // ✅ Controllers to manage text in each box
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _updateCode() {
    String code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
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
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: '', // Hides the character counter
            ),
            onChanged: (value) {
              _updateCode();
              if (value.isNotEmpty && i < widget.length - 1) {
                // Move focus forward
                _focusNodes[i + 1].requestFocus();
              } else if (value.isEmpty && i > 0) {
                // Move focus backward
                _focusNodes[i - 1].requestFocus();
              }
            },
          ),
        );
      }),
    );
  }
}
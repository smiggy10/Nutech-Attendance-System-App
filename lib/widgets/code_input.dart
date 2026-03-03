import 'package:flutter/material.dart';

class CodeInput extends StatelessWidget {
  const CodeInput({super.key, required this.length});

  final int length;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (i) {
        return Container(
          width: 56,
          height: 56,
          margin: EdgeInsets.only(right: i == length - 1 ? 0 : 14),
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
        );
      }),
    );
  }
}

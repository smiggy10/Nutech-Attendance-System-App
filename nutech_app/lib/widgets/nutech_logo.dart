import 'package:flutter/material.dart';

class NutechLogo extends StatelessWidget {
  final double topSpacing;

  const NutechLogo({
    super.key,
    this.topSpacing = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: topSpacing),
        Center(
          child: Image.asset(
            'assets/images/branding/nutechlogo2.png',
            height: 80,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
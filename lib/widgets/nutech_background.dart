import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// A lightweight background that approximates the look of your mockups:
/// - teal geometric accents at the top
/// - soft teal wave/gradient at the bottom
class NutechBackground extends StatelessWidget {
  const NutechBackground({
    super.key,
    required this.child,
    this.showTopAccents = true,
    this.useBrandImages = true,
  });

  final Widget child;
  final bool showTopAccents;
  final bool useBrandImages;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Color(0xFFF7FBFB)],
              ),
            ),
          ),
        ),

        // Bottom background (from your provided mock assets)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            child: Opacity(
              opacity: useBrandImages ? 1.0 : 0.0,
              child: Image.asset(
                'assets/images/ui/bottombackground1.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        // Fallback bottom tint if images are disabled
        if (!useBrandImages)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x000A8B90), Color(0x660A8B90)],
                ),
              ),
            ),
          ),

        // Top header design (from your provided mock assets)
        if (showTopAccents && useBrandImages)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/ui/headerdesign.png',
                fit: BoxFit.cover,
              ),
            ),
          ),

        // Fallback top accents (simple shapes)
        if (showTopAccents && !useBrandImages) ...[
          Positioned(
            top: -40,
            left: -40,
            child: Transform.rotate(
              angle: -0.25,
              child: Container(
                width: 220,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.20),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
          Positioned(
            top: -10,
            left: 60,
            child: Transform.rotate(
              angle: -0.25,
              child: Container(
                width: 180,
                height: 90,
                decoration: BoxDecoration(
                  color: AppTheme.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],

        // Foreground
        Positioned.fill(child: child),
      ],
    );
  }
}

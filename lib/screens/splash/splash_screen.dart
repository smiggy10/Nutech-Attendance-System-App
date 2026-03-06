import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/nutech_background.dart';
import '../auth/login_screen.dart';

/// Splash screen matching admin_weekly_summary design and GIF-style motion:
/// NutechBackground, centered nutechlogo2 (40–50% width), optimized zoom effect.
/// Fade + scale 0.65→1.05 over 1.2s easeInOut, then one gentle glow pulse (0.4s),
/// hold ~1s, fade to login. Total ~2.5–3s. Logo is readable on all devices.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static const route = '/';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Optimized animation: Step 1: empty background. Step 2: logo fade 0→100% + scale 0.65→1.05 (1.2s easeInOut).
  // Step 3: subtle glow pulses once gently (0.4s). Step 4: hold ~1s. Total ~2.5–3s.
  static const _logoDuration = Duration(milliseconds: 1200);
  static const _glowDuration = Duration(milliseconds: 400);
  static const _totalDuration = Duration(milliseconds: 2600);

  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _particleController;

  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _glowPulse;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: _logoDuration,
    );
    _glowController = AnimationController(
      vsync: this,
      duration: _glowDuration,
    );
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    const curve = Curves.easeInOut;
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: curve),
    );
    // Optimized zoom: starts at 0.65x (small), animates to 1.05x (emphasis)
    _logoScale = Tween<double>(begin: 0.65, end: 1.05).animate(
      CurvedAnimation(parent: _logoController, curve: curve),
    );
    // Gentle single pulse: intensity peaks then settles (0 → 1 → 0.65)
    _glowPulse = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 1),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1, end: 0.65),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _logoController.forward();
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _glowController.forward();
      }
    });

    Future.delayed(_totalDuration, _goToLogin);
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NutechBackground(
      bottomAsset: 'assets/images/ui/bottombackground2.png',
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildSubtleParticles(),
          _buildContent(context),
        ],
      ),
    );
  }

  /// Very subtle background motion: soft floating shapes/particles.
  Widget _buildSubtleParticles() {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, _) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _SplashParticlePainter(
              progress: _particleController.value,
              teal: AppTheme.teal,
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    // Logo expanded to 65% of screen width for maximum visual impact
    final logoSize = (screenWidth * 0.65).clamp(180.0, 300.0);
    final padding = EdgeInsets.symmetric(
      horizontal: screenWidth * 0.04,
      vertical: 24,
    );

    return SafeArea(
      child: Center(
        child: Padding(
          padding: padding,
          child: AnimatedBuilder(
            animation: Listenable.merge([_logoController, _glowController]),
            builder: (context, _) {
              return FadeTransition(
                opacity: _logoOpacity,
                child: ScaleTransition(
                  scale: _logoScale,
                  alignment: Alignment.center,
                  child: _buildLogoWithGlow(context, logoSize),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Logo (nutechlogo2.png) with soft teal glow; logo 40–50% screen width.
  Widget _buildLogoWithGlow(BuildContext context, double logoSize) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Soft professional glow: pulses once gently (peak then settle)
        AnimatedBuilder(
          animation: _glowController,
          builder: (context, _) {
            final intensity = _glowPulse.value;
            return IgnorePointer(
              child: Container(
                width: logoSize + 56,
                height: logoSize + 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.teal.withOpacity(0.12 * intensity),
                      blurRadius: 20 + 8 * intensity,
                      spreadRadius: 3 + 5 * intensity,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        Image.asset(
          'assets/images/branding/nutechlogo2.png',
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ],
    );
  }
}

/// Minimal floating particles so background is not static; does not distract.
class _SplashParticlePainter extends CustomPainter {
  _SplashParticlePainter({required this.progress, required this.teal});

  final double progress;
  final Color teal;

  static const _count = 6;
  static final _random = math.Random(12);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _count; i++) {
      final seed = i * 0.9;
      final x = size.width * (0.2 + _random.nextDouble() * 0.6) +
          size.width * 0.02 * math.sin(progress * math.pi * 2 + seed);
      final y = size.height * (_random.nextDouble() * 0.7) +
          size.height * 0.015 * math.cos(progress * math.pi * 2 + seed * 0.8);
      final r = 1.5 + _random.nextDouble() * 2;
      final opacity = (0.02 + 0.04 * (0.5 + 0.5 * math.sin(progress * math.pi * 2 + seed * 2)))
          .clamp(0.0, 1.0);
      final paint = Paint()
        ..color = teal.withOpacity(opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SplashParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

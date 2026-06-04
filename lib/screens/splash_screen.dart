import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/app_colors.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Main sequence controller ─────────────────────────────────
  late final AnimationController _mainCtrl;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<double> _ringScale;
  late final Animation<double> _ringFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _dotsFade;

  // ── Dots bounce controller (repeating) ──────────────────────
  late final AnimationController _dotsCtrl;

  // ── Bubble float controllers ─────────────────────────────────
  late final AnimationController _bubbleCtrl;
  late final Animation<double> _bubbleFloat;

  @override
  void initState() {
    super.initState();

    // ── Main sequence (2000ms) ───────────────────────────────
    _mainCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.28, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.elasticOut),
      ),
    );

    // Decorative ring that pulses outward from logo
    _ringScale = Tween<double>(begin: 0.6, end: 1.5).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOut),
      ),
    );
    _ringFade = Tween<double>(begin: 0.45, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.05, 0.45, curve: Curves.easeOut),
      ),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.6),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.38, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    _titleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.38, 0.62, curve: Curves.easeOut),
      ),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.58, 0.80, curve: Curves.easeOut),
      ),
    );

    _dotsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainCtrl,
        curve: const Interval(0.72, 0.90, curve: Curves.easeOut),
      ),
    );

    // ── Bouncing dots (repeating) ────────────────────────────
    _dotsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();

    // ── Bubble float (slow, repeating) ──────────────────────
    _bubbleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    _bubbleFloat = Tween<double>(begin: 0.0, end: 12.0).animate(
      CurvedAnimation(parent: _bubbleCtrl, curve: Curves.easeInOut),
    );

    // ── Start & navigate ─────────────────────────────────────
    _mainCtrl.forward();
    Future.delayed(const Duration(milliseconds: 3000), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mainCtrl.dispose();
    _dotsCtrl.dispose();
    _bubbleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFBDD9F5),
      body: Stack(
        children: [
          // ── Gradient background ────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xFFAAD2F0),
                    Color(0xFFCBE7FA),
                    Color(0xFFE8F5FF),
                  ],
                ),
              ),
            ),
          ),

          // ── Floating bubbles ───────────────────────────────
          AnimatedBuilder(
            animation: _bubbleFloat,
            builder: (_, _) => Stack(
              children: [
                Positioned(
                  top: -50 + _bubbleFloat.value,
                  right: -40,
                  child: const _Bubble(size: 200, opacity: 0.13),
                ),
                Positioned(
                  top: 80 - _bubbleFloat.value * 0.6,
                  left: -30,
                  child: const _Bubble(size: 130, opacity: 0.10),
                ),
                Positioned(
                  bottom: 120 + _bubbleFloat.value * 0.8,
                  right: -20,
                  child: const _Bubble(size: 90, opacity: 0.12),
                ),
                Positioned(
                  bottom: 60 - _bubbleFloat.value * 0.5,
                  left: 20,
                  child: const _Bubble(size: 56, opacity: 0.14),
                ),
                Positioned(
                  top: 200 + _bubbleFloat.value * 0.4,
                  right: 40,
                  child: const _Bubble(size: 32, opacity: 0.20),
                ),
              ],
            ),
          ),

          // ── Decorative icons (scattered) ───────────────────
          AnimatedBuilder(
            animation: _mainCtrl,
            builder: (_, _) => Opacity(
              opacity: _taglineFade.value,
              child: Stack(
                children: [
                  Positioned(
                    top: 90,
                    right: 50,
                    child: _DecorIcon(
                      icon: Icons.star_rounded,
                      size: 22,
                      color: AppColors.blueAccent.withValues(alpha: .30),
                    ),
                  ),
                  Positioned(
                    top: 155,
                    left: 38,
                    child: _DecorIcon(
                      icon: Icons.favorite_rounded,
                      size: 16,
                      color: AppColors.blueMid.withValues(alpha: .25),
                    ),
                  ),
                  Positioned(
                    bottom: 200,
                    right: 36,
                    child: _DecorIcon(
                      icon: Icons.eco_rounded,
                      size: 18,
                      color: AppColors.blueSoft.withValues(alpha: .40),
                    ),
                  ),
                  Positioned(
                    bottom: 260,
                    left: 48,
                    child: _DecorIcon(
                      icon: Icons.spa_rounded,
                      size: 14,
                      color: AppColors.blueAccent.withValues(alpha: .22),
                    ),
                  ),
                  Positioned(
                    top: 110,
                    left: 60,
                    child: _DecorIcon(
                      icon: Icons.child_care_rounded,
                      size: 18,
                      color: AppColors.blueMid.withValues(alpha: .22),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Centre content ─────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 28),
                _buildTitle(),
                const SizedBox(height: 10),
                _buildTagline(),
                const SizedBox(height: 52),
                _buildDots(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGO — ring pulse + scale in
  // ============================================================
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (_, _) => SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulse ring
            Transform.scale(
              scale: _ringScale.value,
              child: Opacity(
                opacity: _ringFade.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: .70),
                      width: 2.5,
                    ),
                  ),
                ),
              ),
            ),
            // Logo circle
            Transform.scale(
              scale: _logoScale.value,
              child: Opacity(
                opacity: _logoFade.value,
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blueMid.withValues(alpha: .22),
                        blurRadius: 32,
                        offset: const Offset(0, 12),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: .80),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Image.asset('assets/icon/logo.png', fit: BoxFit.contain),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================
  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _mainCtrl,
      builder: (_, _) => FadeTransition(
        opacity: _titleFade,
        child: SlideTransition(
          position: _titleSlide,
          child: Text(
            'BabyBite',
            style: GoogleFonts.fredoka(
              fontSize: 46,
              fontWeight: FontWeight.w700,
              color: AppColors.blueDeep,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TAGLINE
  // ============================================================
  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _taglineFade,
      builder: (_, _) => Opacity(
        opacity: _taglineFade.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_rounded,
                size: 13, color: AppColors.blueMid.withValues(alpha: .70)),
            const SizedBox(width: 6),
            Text(
              'Nutritious meals made with love',
              style: GoogleFonts.quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.blueMid,
                letterSpacing: 0.1,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.favorite_rounded,
                size: 13, color: AppColors.blueMid.withValues(alpha: .70)),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING DOTS — staggered bounce
  // ============================================================
  Widget _buildDots() {
    return AnimatedBuilder(
      animation: _dotsFade,
      builder: (_, _) => Opacity(
        opacity: _dotsFade.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) => _BounceDot(
            controller: _dotsCtrl,
            delay: i * 0.22,
          )),
        ),
      ),
    );
  }
}

// ============================================================
// BOUNCE DOT
// ============================================================
class _BounceDot extends StatelessWidget {
  final AnimationController controller;
  final double delay;

  const _BounceDot({required this.controller, required this.delay});

  @override
  Widget build(BuildContext context) {
    final offsetAnim = Tween<double>(begin: 0.0, end: -10.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.clamp(0.0, 0.85),
          (delay + 0.35).clamp(0.0, 1.0),
          curve: Curves.easeInOut,
        ),
      ),
    );
    final sizeAnim = Tween<double>(begin: 9.0, end: 11.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(
          delay.clamp(0.0, 0.85),
          (delay + 0.35).clamp(0.0, 1.0),
          curve: Curves.easeInOut,
        ),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Transform.translate(
          offset: Offset(0, offsetAnim.value),
          child: Container(
            width: sizeAnim.value,
            height: sizeAnim.value,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .80),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.blueMid.withValues(alpha: .20),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SHARED DECORATIVE HELPERS
// ============================================================
class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _DecorIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  const _DecorIcon({required this.icon, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}

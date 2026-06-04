import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/app_colors.dart';
import 'auth_widgets.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFBDD9F5),
      body: Stack(
        children: [
          // ── Gradient background ──────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [
                    Color(0xFFBDD9F5),
                    Color(0xFFD8EDFC),
                    Color(0xFFF0F8FF),
                  ],
                ),
              ),
            ),
          ),

          // ── Decorative bubbles ───────────────────────────
          const Positioned(top: -40, right: -35, child: _Bubble(size: 160, opacity: 0.18)),
          const Positioned(top: 50,  left: -25, child: _Bubble(size: 100, opacity: 0.14)),
          const Positioned(top: 160, right: 30,  child: _Bubble(size: 48,  opacity: 0.22)),
          const Positioned(top: 110, left: 60,   child: _Bubble(size: 28,  opacity: 0.30)),

          // ── Decorative icons ─────────────────────────────
          Positioned(
            top: 54, right: 60,
            child: _DecorIcon(icon: Icons.star_rounded, size: 20, color: AppColors.blueAccent.withValues(alpha: .35)),
          ),
          Positioned(
            top: 140, left: 32,
            child: _DecorIcon(icon: Icons.favorite_rounded, size: 16, color: AppColors.blueMid.withValues(alpha: .30)),
          ),
          Positioned(
            top: 90, right: 24,
            child: _DecorIcon(icon: Icons.child_care_rounded, size: 18, color: AppColors.blueSoft.withValues(alpha: .50)),
          ),
          Positioned(
            top: 180, left: 90,
            child: _DecorIcon(icon: Icons.spa_rounded, size: 14, color: AppColors.blueAccent.withValues(alpha: .28)),
          ),

          // ── Main content ─────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.04),
                _buildHero(),
                Expanded(child: _buildFormSheet()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HERO SECTION
  // ============================================================
  Widget _buildHero() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.blueSoft.withValues(alpha: .4),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Image.asset('assets/icon/logo.png', fit: BoxFit.contain),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'BabyBite',
          style: GoogleFonts.fredoka(
            fontSize: 38,
            fontWeight: FontWeight.w700,
            color: AppColors.blueDeep,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, size: 14, color: AppColors.blueMid),
            const SizedBox(width: 5),
            Text(
              'Nutritious meals made with love',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.blueMid,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
      ],
    );
  }

  // ============================================================
  // FORM SHEET
  // ============================================================
  Widget _buildFormSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(36),
          topRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A5AA3E8),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sheet handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 22),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            Text(
              'Sign In',
              style: GoogleFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.blueDeep,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Welcome back! Your little one is waiting',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.placeholder,
              ),
            ),
            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  AuthTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'example@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Please enter your email';
                      if (!v.contains('@')) return 'Invalid email address';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  AuthTextField(
                    controller: _passwordCtrl,
                    label: 'Password',
                    hint: '••••••••',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.placeholder,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter your password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: Text(
                  'Forgot password?',
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.blueAccent,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            _AuthPrimaryButton(
              label: 'Sign In',
              isLoading: _isLoading,
              onTap: _onLogin,
            ),

            const SizedBox(height: 26),
            _buildDivider(),
            const SizedBox(height: 20),

            AuthSocialButton(
              label: 'Continue with Google',
              icon: Icons.g_mobiledata_rounded,
              onTap: () {},
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.placeholder,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  ),
                  child: Text(
                    'Sign Up',
                    style: GoogleFonts.quicksand(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.blueAccent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1.5)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or continue with',
            style: GoogleFonts.quicksand(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.placeholder,
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.cardBorder, thickness: 1.5)),
      ],
    );
  }
}

// ============================================================
// LOCAL DECORATIVE WIDGETS
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

class _AuthPrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _AuthPrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 58,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [AppColors.blueSoft, AppColors.blueSoft]
                : [const Color(0xFF9BC8EE), const Color(0xFF5AA3E8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.blueAccent.withValues(alpha: .4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}

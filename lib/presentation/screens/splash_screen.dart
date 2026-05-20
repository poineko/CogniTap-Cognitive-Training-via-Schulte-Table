import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Animated splash screen dengan Schulte Table preview mini.
/// Muncul saat app pertama dibuka, lalu auto-navigate ke HomeScreen.
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late AnimationController _gridController;
  late AnimationController _fadeOutController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _gridFade;
  late Animation<double> _taglineFade;

  // State grid mini untuk animasi "number tapping"
  final List<int> _gridNumbers = [5, 3, 8, 1, 6, 4, 9, 2, 7];
  int _highlightedIndex = -1;
  int _tappedUpTo = 0;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _gridController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeOutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _gridFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gridController, curve: Curves.easeIn),
    );
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _gridController,
          curve: const Interval(0.4, 1.0, curve: Curves.easeIn)),
    );

    _runSequence();
  }

  Future<void> _runSequence() async {
    // 1. Logo masuk
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    // 2. Grid muncul
    await Future.delayed(const Duration(milliseconds: 800));
    _gridController.forward();

    // 3. Animasi tap angka 1-9 satu per satu
    await Future.delayed(const Duration(milliseconds: 500));
    await _animateGridTaps();

    // 4. Fade out & navigate
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeOutController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) widget.onComplete();
  }

  Future<void> _animateGridTaps() async {
    for (int num = 1; num <= 9; num++) {
      final idx = _gridNumbers.indexOf(num);
      if (!mounted) return;
      setState(() {
        _highlightedIndex = idx;
        _tappedUpTo = num;
      });
      await Future.delayed(const Duration(milliseconds: 220));
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _gridController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _fadeOutController,
      builder: (context, child) => Opacity(
        opacity: 1.0 - _fadeOutController.value,
        child: child,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        body: Stack(
          children: [
            // ── Dot grid background
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: const Color(0xFF00D4FF).withValues(alpha: 0.05),
                ),
              ),
            ),

            // ── Radial glow di tengah
            Center(
              child: Container(
                width: size.width * 0.8,
                height: size.width * 0.8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF00D4FF).withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _logoController,
                    builder: (context, _) => Opacity(
                      opacity: _logoFade.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: _LogoWidget(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Mini Schulte Grid (3x3)
                  AnimatedBuilder(
                    animation: _gridController,
                    builder: (context, _) => Opacity(
                      opacity: _gridFade.value,
                      child: _MiniSchulteGrid(
                        numbers: _gridNumbers,
                        tappedUpTo: _tappedUpTo,
                        highlightedIndex: _highlightedIndex,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Tagline
                  AnimatedBuilder(
                    animation: _gridController,
                    builder: (context, _) => Opacity(
                      opacity: _taglineFade.value,
                      child: Column(
                        children: [
                          Text(
                            'Train your focus.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              color: Colors.white54,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'Measure your mind.',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 16,
                              color: Colors.white54,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Version + branding bawah
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _gridController,
                builder: (context, _) => Opacity(
                  opacity: _taglineFade.value,
                  child: Column(
                    children: [
                      Text(
                        'Powered by Schulte Table Method',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          color: Colors.white24,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'v1.0.0',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.18),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Logo Widget ───────────────────────────────────────────────────────────────

class _LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon otak stilasi dari grid + brain
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00D4FF).withValues(alpha: 0.12),
            border: Border.all(
              color: const Color(0xFF00D4FF).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Center(
            child: _CogniTapLogoIcon(),
          ),
        ),

        const SizedBox(height: 20),

        // COGNITAP title
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'COGNI',
                style: GoogleFonts.orbitron(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00D4FF),
                  letterSpacing: 4,
                ),
              ),
              TextSpan(
                text: 'TAP',
                style: GoogleFonts.orbitron(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Icon custom — 2x2 grid dengan satu kotak highlighted (melambangkan focus)
class _CogniTapLogoIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: 9,
        itemBuilder: (_, i) {
          // Kotak tengah = highlighted (fokus)
          final isCenter = i == 4;
          return Container(
            decoration: BoxDecoration(
              color: isCenter
                  ? const Color(0xFF00D4FF)
                  : const Color(0xFF00D4FF).withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        },
      ),
    );
  }
}

// ── Mini Schulte Grid ─────────────────────────────────────────────────────────

class _MiniSchulteGrid extends StatelessWidget {
  final List<int> numbers;
  final int tappedUpTo;
  final int highlightedIndex;

  const _MiniSchulteGrid({
    required this.numbers,
    required this.tappedUpTo,
    required this.highlightedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      height: 180,
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
        ),
        itemCount: 9,
        itemBuilder: (context, index) {
          final num = numbers[index];
          final isTapped = num < tappedUpTo;
          final isCurrent = index == highlightedIndex;

          Color bgColor;
          Color textColor;

          if (isCurrent) {
            bgColor = const Color(0xFF06D6A0); // green = just tapped
            textColor = Colors.white;
          } else if (isTapped) {
            bgColor = const Color(0xFF1F3047).withValues(alpha: 0.5);
            textColor = Colors.white24;
          } else {
            bgColor = const Color(0xFF1F3047);
            textColor = const Color(0xFF00D4FF);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCurrent
                    ? const Color(0xFF06D6A0)
                    : Colors.white.withValues(alpha: 0.06),
              ),
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: const Color(0xFF06D6A0).withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: Text(
                '$num',
                style: GoogleFonts.orbitron(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Painters ──────────────────────────────────────────────────────────────────

class _DotGridPainter extends CustomPainter {
  final Color color;
  _DotGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double x = 0; x < size.width; x += 36) {
      for (double y = 0; y < size.height; y += 36) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
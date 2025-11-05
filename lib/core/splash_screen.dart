import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:tasks_app/core/app.dart';

class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;

  late Animation<Color?> _bgColor1;
  late Animation<Color?> _bgColor2;

  final Random _random = Random();
  final int _particleCount = 30;
  late List<Offset> _particlePositions;
  late List<double> _particleSizes;

  @override
  void initState() {
    super.initState();

    _particlePositions = List.generate(
      _particleCount,
          (_) => Offset(_random.nextDouble(), _random.nextDouble()),
    );
    _particleSizes = List.generate(_particleCount, (_) => 2 + _random.nextDouble() * 4);

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _logoFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _textFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _bgColor1 = ColorTween(
      begin: const Color(0xFF3A7BD5), // Lighter blue top
      end: const Color(0xFF00D2FF), // Bright cyan
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _bgColor2 = ColorTween(
      begin: const Color(0xFF2A5298), // Deep blue bottom
      end: const Color(0xFF1E3C72),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TasksApp()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildParticles(Size size) {
    return CustomPaint(
      painter:
      _ParticlePainter(_particlePositions, _particleSizes, size, _controller.value),
      size: size,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        return Scaffold(
          body: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00B5AD), // Teal from your logo
                  const Color(0xFF2E2E2E),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                _buildParticles(size),

                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _logoFadeAnimation,
                        child: ScaleTransition(
                          scale: _logoScaleAnimation,
                          child: Container(
                            // Solid background only behind the logo
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white, // makes logo visible regardless of dark/blue background
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 12,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/logo.png',
                              height: 80,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),


                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _textFadeAnimation,
                        child: const Text(
                          'Tasks App',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      const CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final List<Offset> positions;
  final List<double> sizes;
  final Size screenSize;
  final double progress;

  _ParticlePainter(this.positions, this.sizes, this.screenSize, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.6); // brighter particles
    for (int i = 0; i < positions.length; i++) {
      final dx =
          (positions[i].dx * size.width + sin(progress * 2 * pi + i) * 25) % size.width;
      final dy =
          (positions[i].dy * size.height + cos(progress * 2 * pi + i) * 25) % size.height;
      canvas.drawCircle(Offset(dx, dy), sizes[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

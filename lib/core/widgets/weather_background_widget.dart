import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';

class WeatherBackgroundWidget extends StatefulWidget {
  final WeatherThemeType themeType;
  final Widget child;

  const WeatherBackgroundWidget({
    super.key,
    required this.themeType,
    required this.child,
  });

  @override
  State<WeatherBackgroundWidget> createState() => _WeatherBackgroundWidgetState();
}

class _WeatherBackgroundWidgetState extends State<WeatherBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_WeatherParticle> _particles = [];
  final Random _rand = Random();
  double _lightningAlpha = 0.0;
  int _nextLightningTime = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initializeParticles();
  }

  @override
  void didUpdateWidget(covariant WeatherBackgroundWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.themeType != widget.themeType) {
      _initializeParticles();
    }
  }

  void _initializeParticles() {
    _particles.clear();
    int count = 0;
    
    switch (widget.themeType) {
      case WeatherThemeType.night:
        count = 60; // stars
        break;
      case WeatherThemeType.rain:
        count = 80; // raindrops
        break;
      case WeatherThemeType.storm:
        count = 100; // storm rain
        _nextLightningTime = DateTime.now().millisecondsSinceEpoch + 2000;
        break;
      case WeatherThemeType.snow:
        count = 50; // snowflakes
        break;
      case WeatherThemeType.fog:
        count = 8; // fog clouds
        break;
      default:
        count = 12; // generic ambient floating dust/rays
        break;
    }

    for (int i = 0; i < count; i++) {
      _particles.add(_WeatherParticle(
        x: _rand.nextDouble(),
        y: _rand.nextDouble(),
        speed: 0.2 + _rand.nextDouble() * 0.8,
        size: 1.0 + _rand.nextDouble() * 4.0,
        opacity: 0.1 + _rand.nextDouble() * 0.7,
        angle: _rand.nextDouble() * pi * 2,
        drift: (_rand.nextDouble() - 0.5) * 0.5,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateParticles(Size size) {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Storm lightning effect trigger
    if (widget.themeType == WeatherThemeType.storm) {
      if (now > _nextLightningTime) {
        // Trigger a flash!
        _lightningAlpha = 0.8;
        _nextLightningTime = now + 4000 + _rand.nextInt(6000); // next flash in 4-10s
      } else if (_lightningAlpha > 0.0) {
        _lightningAlpha -= 0.05; // Fade out lightning
        if (_lightningAlpha < 0) _lightningAlpha = 0;
      }
    } else {
      _lightningAlpha = 0.0;
    }

    for (var p in _particles) {
      switch (widget.themeType) {
        case WeatherThemeType.rain:
        case WeatherThemeType.storm:
          // Rain falls downwards-sideways
          p.y += 0.015 * p.speed;
          p.x -= 0.002 * p.speed;
          if (p.y > 1.0) {
            p.y = 0.0;
            p.x = _rand.nextDouble();
          }
          break;
        case WeatherThemeType.snow:
          // Snow drifts down gently with sinusoidal wave side-to-side
          p.y += 0.003 * p.speed;
          p.angle += 0.02;
          p.x += sin(p.angle) * 0.001;
          if (p.y > 1.0) {
            p.y = 0.0;
            p.x = _rand.nextDouble();
          }
          break;
        case WeatherThemeType.night:
          // Stars twinkle (vary opacity)
          p.opacity = 0.1 + sin(_controller.value * pi * 8 * p.speed).abs() * 0.8;
          break;
        case WeatherThemeType.fog:
          // Fog clouds float slowly horizontally
          p.x += 0.0005 * p.speed;
          if (p.x > 1.0) {
            p.x = -0.2;
            p.y = _rand.nextDouble();
          }
          break;
        default:
          // Ambient solar rays / floating particles
          p.y -= 0.0005 * p.speed;
          p.x += 0.0002 * p.speed;
          if (p.y < 0) {
            p.y = 1.0;
            p.x = _rand.nextDouble();
          }
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _WeatherBackgroundPainter(
            themeType: widget.themeType,
            particles: _particles,
            lightningAlpha: _lightningAlpha,
            onUpdate: (size) => _updateParticles(size),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _WeatherParticle {
  double x;
  double y;
  double speed;
  double size;
  double opacity;
  double angle;
  double drift;

  _WeatherParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.angle,
    required this.drift,
  });
}

class _WeatherBackgroundPainter extends CustomPainter {
  final WeatherThemeType themeType;
  final List<_WeatherParticle> particles;
  final double lightningAlpha;
  final Function(Size) onUpdate;

  _WeatherBackgroundPainter({
    required this.themeType,
    required this.particles,
    required this.lightningAlpha,
    required this.onUpdate,
  });

  @override
  void paint(Canvas canvas, Size size) {
    onUpdate(size);

    // 1. Paint Background Gradient
    final rect = Offset.zero & size;
    final gradient = _getBackgroundGradient();
    final paintBg = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paintBg);

    // 2. Paint Weather Particles
    final paintParticle = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final px = p.x * size.width;
      final py = p.y * size.height;

      switch (themeType) {
        case WeatherThemeType.rain:
        case WeatherThemeType.storm:
          // Paint raindrop streaks
          paintParticle.color = Colors.white.withOpacity(p.opacity * 0.4);
          paintParticle.strokeWidth = p.size * 0.3;
          canvas.drawLine(
            Offset(px, py),
            Offset(px - 3, py + 15),
            paintParticle,
          );
          break;
        case WeatherThemeType.snow:
          // Paint fuzzy snowflakes
          paintParticle.color = Colors.white.withOpacity(p.opacity);
          canvas.drawCircle(Offset(px, py), p.size, paintParticle);
          break;
        case WeatherThemeType.night:
          // Twinkling stars
          paintParticle.color = Colors.white.withOpacity(p.opacity);
          canvas.drawCircle(Offset(px, py), p.size * 0.6, paintParticle);
          
          // Occasional tiny cross glow on bright stars
          if (p.size > 3.5 && p.opacity > 0.6) {
            final glowPaint = Paint()
              ..color = Colors.white.withOpacity(p.opacity * 0.3)
              ..strokeWidth = 0.5;
            canvas.drawLine(Offset(px - 4, py), Offset(px + 4, py), glowPaint);
            canvas.drawLine(Offset(px, py - 4), Offset(px, py + 4), glowPaint);
          }
          break;
        case WeatherThemeType.fog:
          // Soft wide horizontal mist patches
          final fogPaint = Paint()
            ..color = Colors.white.withOpacity(p.opacity * 0.08)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
          canvas.drawOval(
            Rect.fromCenter(center: Offset(px, py), width: size.width * 0.4, height: size.height * 0.04),
            fogPaint,
          );
          break;
        default:
          // Subtle drifting sunlight rays
          paintParticle.color = Colors.white.withOpacity(p.opacity * 0.1);
          canvas.drawCircle(Offset(px, py), p.size * 1.5, paintParticle);
          break;
      }
    }

    // 3. Paint Lightning Storm Overlay
    if (lightningAlpha > 0.0) {
      final paintLightning = Paint()
        ..color = Colors.white.withOpacity(lightningAlpha)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, paintLightning);
    }
  }

  LinearGradient _getBackgroundGradient() {
    switch (themeType) {
      case WeatherThemeType.morning:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE29587), Color(0xFFD66D75)],
        );
      case WeatherThemeType.afternoon:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2E86C1), Color(0xFF5DADE2)],
        );
      case WeatherThemeType.sunset:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C3E50), Color(0xFFE74C3C), Color(0xFFF39C12)],
        );
      case WeatherThemeType.night:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
        );
      case WeatherThemeType.rain:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2B3A42), Color(0xFF3F5866), Color(0xFF566F7F)],
        );
      case WeatherThemeType.storm:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF181B26), Color(0xFF232B3E), Color(0xFF1E2333)],
        );
      case WeatherThemeType.snow:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF637C96), Color(0xFF88A2B9), Color(0xFFB1C4D4)],
        );
      case WeatherThemeType.fog:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF5D6D7E), Color(0xFF85929E), Color(0xFFAEB6BF)],
        );
    }
  }

  @override
  bool shouldRepaint(covariant _WeatherBackgroundPainter oldDelegate) => true;
}

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../weather/domain/entities/astronomy_entity.dart';

class AstronomyWidget extends StatelessWidget {
  final AstronomyEntity astronomy;

  const AstronomyWidget({
    super.key,
    required this.astronomy,
  });

  @override
  Widget build(BuildContext context) {
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(astronomy.sunrise * 1000);
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(astronomy.sunset * 1000);
    final moonriseTime = DateTime.fromMillisecondsSinceEpoch(astronomy.moonrise * 1000);
    final moonsetTime = DateTime.fromMillisecondsSinceEpoch(astronomy.moonset * 1000);

    return GlassContainer(
      borderRadius: 24.0,
      bgOpacity: 0.05,
      borderOpacity: 0.08,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wb_twilight_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Solar & Lunar Astronomy',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Custom Sun Path Arc visualization
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: _SunPathPainter(
                sunrise: astronomy.sunrise,
                sunset: astronomy.sunset,
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sunrise', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(
                    DateFormat('h:mm a').format(sunriseTime),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Sunset', style: TextStyle(color: Colors.white54, fontSize: 12)),
                  Text(
                    DateFormat('h:mm a').format(sunsetTime),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.08), height: 1),
          const SizedBox(height: 16),

          // Moon details and Photographic Hours
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lunar Schedule', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildRowText('Moonrise:', DateFormat('h:mm a').format(moonriseTime)),
                    _buildRowText('Moonset:', DateFormat('h:mm a').format(moonsetTime)),
                    _buildRowText('Phase:', astronomy.moonPhaseDescription),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Photographic Hours', style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildRowText('Golden Hour:', astronomy.goldenHourEvening),
                    _buildRowText('Blue Hour:', astronomy.blueHourEvening),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRowText(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 12, height: 1.3),
          children: [
            TextSpan(text: '$label ', style: const TextStyle(color: Colors.white54)),
            TextSpan(text: value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SunPathPainter extends CustomPainter {
  final int sunrise;
  final int sunset;

  _SunPathPainter({
    required this.sunrise,
    required this.sunset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Draw horizontal ground line
    final groundPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(0, height - 10), Offset(width, height - 10), groundPaint);

    // Draw sun path dotted arc
    final arcRect = Rect.fromLTRB(16, 10, width - 16, (height - 10) * 2 - 20);
    final arcPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // We can draw a dotted arc by painting small segments
    for (double i = 0; i < pi; i += 0.05) {
      canvas.drawArc(arcRect, pi + i, 0.02, false, arcPaint);
    }

    // Compute sun position relative to current time
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    if (nowSec >= sunrise && nowSec <= sunset) {
      final totalDaylight = sunset - sunrise;
      final elapsed = nowSec - sunrise;
      final double ratio = elapsed / totalDaylight; // 0.0 at sunrise, 1.0 at sunset

      // Angle from pi (left) to 2*pi (right)
      final angle = pi + (pi * ratio);
      
      final rx = width / 2 - 16;
      final ry = height - 20;
      final cx = width / 2 + rx * cos(angle);
      final cy = height - 10 + ry * sin(angle);

      // Draw sun ray glow
      final glowPaint = Paint()
        ..color = const Color(0xFFF1C40F).withOpacity(0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(cx, cy), 18, glowPaint);

      // Draw solid sun center
      final sunPaint = Paint()
        ..color = const Color(0xFFF1C40F)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy), 8, sunPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

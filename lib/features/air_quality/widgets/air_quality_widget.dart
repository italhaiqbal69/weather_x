import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../weather/domain/entities/air_quality_entity.dart';

class AirQualityWidget extends StatelessWidget {
  final AirQualityEntity airQuality;

  const AirQualityWidget({
    super.key,
    required this.airQuality,
  });

  Color _getAqiColor(int aqi) {
    switch (aqi) {
      case 1: return const Color(0xFF2ECC71); // Green
      case 2: return const Color(0xFFF1C40F); // Yellow
      case 3: return const Color(0xFFE67E22); // Orange
      case 4: return const Color(0xFFE74C3C); // Red
      case 5: return const Color(0xFF9B59B6); // Purple
      default: return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aqiColor = _getAqiColor(airQuality.aqi);

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
              Icon(Icons.air_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Air Quality Index',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Circular AQI Gauge CustomPaint
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _AqiGaugePainter(
                    aqi: airQuality.aqi,
                    color: aqiColor,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${airQuality.aqi}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          airQuality.statusName,
                          style: TextStyle(
                            color: aqiColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 20),
              
              // Status name and health recommendations
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AQI - ${airQuality.statusName}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      airQuality.healthRecommendation,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Pollutants breakdown details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPollutantDetail('PM2.5', '${airQuality.pm2_5.toStringAsFixed(1)}', 'µg/m³'),
              _buildPollutantDetail('PM10', '${airQuality.pm10.toStringAsFixed(1)}', 'µg/m³'),
              _buildPollutantDetail('NO₂', '${airQuality.no2.toStringAsFixed(1)}', 'µg/m³'),
              _buildPollutantDetail('O₃', '${airQuality.o3.toStringAsFixed(1)}', 'µg/m³'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPollutantDetail(String name, String value, String unit) {
    return Column(
      children: [
        Text(
          name,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: Colors.white30,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _AqiGaugePainter extends CustomPainter {
  final int aqi;
  final Color color;

  _AqiGaugePainter({
    required this.aqi,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - 6;

    // Grey base circle arc
    final paintBase = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      paintBase,
    );

    // Color filled progress arc
    final progress = aqi / 5.0;
    final paintProgress = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    // Glowing shadow for progress arc
    final paintGlow = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5 * progress,
      false,
      paintGlow,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5 * progress,
      false,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

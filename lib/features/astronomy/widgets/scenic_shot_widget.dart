import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../weather/domain/entities/weather_entity.dart';
import '../../weather/domain/entities/astronomy_entity.dart';

class ScenicShotWidget extends StatelessWidget {
  final WeatherEntity weather;
  final AstronomyEntity astronomy;

  const ScenicShotWidget({
    super.key,
    required this.weather,
    required this.astronomy,
  });

  Map<String, dynamic> _calculateScenicPotential() {
    double score = 100.0;
    final List<String> factors = [];

    // 1. Cloud Cover check (ideal is 30% - 60%)
    final clouds = weather.cloudCover;
    if (clouds < 15) {
      score -= (15 - clouds) * 2;
      factors.add("Sky is too clear: lack of clouds to reflect colors.");
    } else if (clouds > 70) {
      score -= (clouds - 70) * 1.8;
      factors.add("Overcast skies: colors will likely be blocked by low thick clouds.");
    } else {
      score += 10; // Bonus for scattered clouds
      factors.add("Perfect scattered cloud density (Altocumulus/High Cirrus) to capture sunset spectrums.");
    }

    // 2. Visibility check (higher is better)
    final vis = weather.visibility / 1000.0; // In km
    if (vis < 8.0) {
      score -= (8.0 - vis) * 5;
      factors.add("Haze or low visibility may dull the intensity of the light.");
    } else {
      factors.add("Excellent visibility: sunbeams will traverse cleaner air paths.");
    }

    // 3. Humidity check (mid-range is good)
    final hum = weather.humidity;
    if (hum > 80) {
      score -= (hum - 80) * 0.5;
    }

    // 4. Rain check (breaking factor)
    if (weather.condition.toLowerCase().contains('rain') ||
        weather.condition.toLowerCase().contains('drizzle') ||
        weather.condition.toLowerCase().contains('thunderstorm')) {
      score = 15.0;
      factors.clear();
      factors.add("Active precipitation and storm clouds will completely obscure the horizon.");
    }

    // Bound scores
    score = score.clamp(0.0, 100.0);

    String rating = "Poor";
    Color ratingColor = Colors.redAccent;
    if (score >= 80) {
      rating = "Exceptional";
      ratingColor = Colors.orangeAccent;
    } else if (score >= 60) {
      rating = "Good";
      ratingColor = Colors.amberAccent;
    } else if (score >= 40) {
      rating = "Fair";
      ratingColor = Colors.lightBlueAccent;
    }

    return {
      'score': score,
      'rating': rating,
      'color': ratingColor,
      'reasons': factors,
    };
  }

  @override
  Widget build(BuildContext context) {
    final potential = _calculateScenicPotential();
    final double scoreValue = potential['score'];
    final String rating = potential['rating'];
    final Color ratingColor = potential['color'];
    final List<String> reasons = potential['reasons'];

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
              Icon(Icons.camera_rounded, color: Colors.orangeAccent, size: 24),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Photographer's Scenic Advisor",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Radial Gauge
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: _RadialGaugePainter(score: scoreValue, color: ratingColor),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${scoreValue.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          rating,
                          style: TextStyle(
                            color: ratingColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Hour details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHourRow('Golden Hour (Evening):', astronomy.goldenHourEvening),
                    const SizedBox(height: 6),
                    _buildHourRow('Blue Hour (Evening):', astronomy.blueHourEvening),
                    const SizedBox(height: 6),
                    _buildHourRow('Moon Phase:', astronomy.moonPhaseDescription),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          const Text(
            'Atmosphere Forecast Analysis:',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...reasons.map((reason) => Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4.0),
                      child: Icon(Icons.circle, size: 6, color: Colors.orangeAccent),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        reason,
                        style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.35),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildHourRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _RadialGaugePainter extends CustomPainter {
  final double score;
  final Color color;

  _RadialGaugePainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 8.0;

    final paintBg = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius - strokeWidth / 2, paintBg);

    final paintArc = Paint()
      ..shader = const SweepGradient(
        colors: [Colors.purpleAccent, Colors.orangeAccent, Colors.amberAccent],
        startAngle: -math.pi / 2,
        endAngle: 3 * math.pi / 2,
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final sweepAngle = (score / 100.0) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      sweepAngle,
      false,
      paintArc,
    );
  }

  @override
  bool shouldRepaint(covariant _RadialGaugePainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}

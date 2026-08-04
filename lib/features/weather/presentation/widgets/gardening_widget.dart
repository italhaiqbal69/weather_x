import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/weather_entity.dart';

class GardeningWidget extends StatelessWidget {
  final WeatherEntity weather;

  const GardeningWidget({
    super.key,
    required this.weather,
  });

  Map<String, dynamic> _calculateGardeningAdvice() {
    final temp = weather.temp;
    final hum = weather.humidity;
    final wind = weather.windSpeed;
    final rainProb = weather.rainProbability;

    // Calculate soil moisture depletion index (0 to 10)
    // Depletion increases with higher temperature and wind, and decreases with humidity
    double depletionIndex = (temp * 0.15) + (wind * 0.1) - (hum * 0.05) + 3.0;
    depletionIndex = depletionIndex.clamp(1.0, 10.0);

    String evaporationRate = "Moderate";
    Color rateColor = Colors.amberAccent;
    if (depletionIndex > 6.5) {
      evaporationRate = "High";
      rateColor = Colors.orangeAccent;
    } else if (depletionIndex < 3.5) {
      evaporationRate = "Low";
      rateColor = Colors.lightBlueAccent;
    }

    String plantAdvice;
    IconData plantIcon;
    Color plantIconColor;

    if (rainProb > 0.5) {
      plantAdvice = "Rain is expected! Hold off on watering today to prevent root over-saturation.";
      plantIcon = Icons.umbrella_rounded;
      plantIconColor = Colors.lightBlueAccent;
    } else if (depletionIndex > 6.5) {
      plantAdvice = "Soil drying rapidly. Thoroughly water outdoor plants early in the morning or after sunset.";
      plantIcon = Icons.water_drop_rounded;
      plantIconColor = Colors.blueAccent;
    } else if (temp < 8) {
      plantAdvice = "Low temperatures. Reduce watering to prevent frost shock. Move sensitive plants indoors.";
      plantIcon = Icons.ac_unit_rounded;
      plantIconColor = Colors.cyanAccent;
    } else {
      plantAdvice = "Standard watering cycles recommended. Maintain soil dampness.";
      plantIcon = Icons.local_florist_rounded;
      plantIconColor = Colors.greenAccent;
    }

    // Home Comfort Advisor
    String homeAdvice;
    IconData homeIcon;
    Color homeIconColor;

    if (temp >= 18 && temp <= 25 && hum < 70) {
      homeAdvice = "Ideal weather outside! Open your windows for natural cross-ventilation and clean indoor air.";
      homeIcon = Icons.wb_sunny_rounded;
      homeIconColor = Colors.orangeAccent;
    } else if (temp > 30) {
      homeAdvice = "Intense outdoor heat. Keep windows shut and run AC or fans to maintain comfortable temperatures.";
      homeIcon = Icons.ac_unit_rounded;
      homeIconColor = Colors.cyanAccent;
    } else if (temp < 12) {
      homeAdvice = "Chilly outside. Keep windows closed to retain thermal heating and indoor energy efficiency.";
      homeIcon = Icons.home_rounded;
      homeIconColor = Colors.white70;
    } else {
      homeAdvice = "Comfortable parameters. Open ventilation for short periods to freshen the air.";
      homeIcon = Icons.air_rounded;
      homeIconColor = Colors.tealAccent;
    }

    return {
      'depletion': depletionIndex,
      'evapRate': evaporationRate,
      'evapColor': rateColor,
      'plantAdvice': plantAdvice,
      'plantIcon': plantIcon,
      'plantIconColor': plantIconColor,
      'homeAdvice': homeAdvice,
      'homeIcon': homeIcon,
      'homeIconColor': homeIconColor,
    };
  }

  @override
  Widget build(BuildContext context) {
    final data = _calculateGardeningAdvice();
    final double depletion = data['depletion'];
    final String evapRate = data['evapRate'];
    final Color evapColor = data['evapColor'];
    final String plantAdvice = data['plantAdvice'];
    final IconData plantIcon = data['plantIcon'];
    final Color plantIconColor = data['plantIconColor'];
    final String homeAdvice = data['homeAdvice'];
    final IconData homeIcon = data['homeIcon'];
    final Color homeIconColor = data['homeIconColor'];

    return GlassContainer(
      borderRadius: 24.0,
      bgOpacity: 0.05,
      borderOpacity: 0.08,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.yard_rounded, color: Colors.greenAccent, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Gardening & Home Companion',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: evapColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: evapColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Soil Evaporation: $evapRate',
                      style: TextStyle(color: evapColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Watering section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: plantIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(plantIcon, color: plantIconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Botanical & Watering Advice',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plantAdvice,
                      style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          
          // Home advisor section
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: homeIconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(homeIcon, color: homeIconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Home comfort & Ventilation',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      homeAdvice,
                      style: const TextStyle(color: Colors.white60, fontSize: 12, height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

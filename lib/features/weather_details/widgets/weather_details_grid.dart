import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../features/settings/presentation/viewmodels/settings_viewmodel.dart';
import '../../weather/domain/entities/weather_entity.dart';

class WeatherDetailsGrid extends StatelessWidget {
  final WeatherEntity weather;
  final SettingsViewModel settingsVM;

  const WeatherDetailsGrid({
    super.key,
    required this.weather,
    required this.settingsVM,
  });

  @override
  Widget build(BuildContext context) {
    // Grid items data
    final items = [
      _DetailItem(
        icon: Icons.thermostat_rounded,
        iconColor: const Color(0xFFE74C3C),
        title: 'Feels Like',
        value: settingsVM.formatTemperature(weather.feelsLike),
        subtitle: weather.feelsLike > weather.temp ? 'Warmer than actual' : 'Cooler than actual',
      ),
      _DetailItem(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF3498DB),
        title: 'Wind Speed',
        value: settingsVM.formatWindSpeed(weather.windSpeed),
        subtitle: _getWindDirectionText(weather.windDirection),
      ),
      _DetailItem(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF5DADE2),
        title: 'Humidity',
        value: '${weather.humidity}%',
        subtitle: 'Dew point is ${settingsVM.formatTemperature(weather.dewPoint)}',
      ),
      _DetailItem(
        icon: Icons.speed_rounded,
        iconColor: const Color(0xFF2ECC71),
        title: 'Air Pressure',
        value: settingsVM.formatPressure(weather.pressure),
        subtitle: _getPressureDescription(weather.pressure),
      ),
      _DetailItem(
        icon: Icons.wb_sunny_rounded,
        iconColor: const Color(0xFFF1C40F),
        title: 'UV Index',
        value: weather.uvIndex.toStringAsFixed(1),
        subtitle: _getUvCategory(weather.uvIndex),
      ),
      _DetailItem(
        icon: Icons.visibility_rounded,
        iconColor: const Color(0xFF95A5A6),
        title: 'Visibility',
        value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
        subtitle: weather.visibility >= 10000 ? 'Perfectly clear' : 'Slight mist in air',
      ),
      _DetailItem(
        icon: Icons.cloud_rounded,
        iconColor: const Color(0xFFBDC3C7),
        title: 'Cloud Cover',
        value: '${weather.cloudCover}%',
        subtitle: weather.cloudCover > 50 ? 'Mostly cloudy' : 'Mostly clear',
      ),
      _DetailItem(
        icon: Icons.umbrella_rounded,
        iconColor: const Color(0xFF9B59B6),
        title: 'Rain Chance',
        value: '${(weather.rainProbability * 100).toStringAsFixed(0)}%',
        subtitle: weather.rainProbability > 0.5 ? 'Carry an umbrella' : 'No rain expected',
      ),
    ];

    final double screenWidth = MediaQuery.of(context).size.width;
    final double childAspectRatio = screenWidth < 360 ? 1.22 : 1.45;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return GlassContainer(
          borderRadius: 20.0,
          bgOpacity: 0.05,
          borderOpacity: 0.08,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(item.icon, color: item.iconColor, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getWindDirectionText(int deg) {
    if (deg >= 337.5 || deg < 22.5) return 'N Direction';
    if (deg >= 22.5 && deg < 67.5) return 'NE Direction';
    if (deg >= 67.5 && deg < 112.5) return 'E Direction';
    if (deg >= 112.5 && deg < 157.5) return 'SE Direction';
    if (deg >= 157.5 && deg < 202.5) return 'S Direction';
    if (deg >= 202.5 && deg < 247.5) return 'SW Direction';
    if (deg >= 247.5 && deg < 292.5) return 'W Direction';
    return 'NW Direction';
  }

  String _getPressureDescription(int pressure) {
    if (pressure > 1020) return 'High pressure (Stable)';
    if (pressure < 1009) return 'Low pressure (Stormy)';
    return 'Normal pressure';
  }

  String _getUvCategory(double uv) {
    if (uv <= 2) return 'Low (Safe)';
    if (uv <= 5) return 'Moderate (Wear hats)';
    if (uv <= 7) return 'High (Use sunscreen)';
    if (uv <= 10) return 'Very High (Stay shaded)';
    return 'Extreme (Avoid sun)';
  }
}

class _DetailItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  _DetailItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });
}

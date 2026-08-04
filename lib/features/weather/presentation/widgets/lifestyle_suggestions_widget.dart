import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/weather_entity.dart';

class LifestyleSuggestionsWidget extends StatelessWidget {
  final WeatherEntity weather;

  const LifestyleSuggestionsWidget({
    super.key,
    required this.weather,
  });

  List<_SuggestionItem> _generateSuggestions() {
    final List<_SuggestionItem> list = [];

    // 1. Temperature checks
    if (weather.temp < 10) {
      list.add(_SuggestionItem(
        icon: Icons.ac_unit_rounded,
        iconColor: Colors.lightBlueAccent,
        title: 'Thermal Jacket',
        body: 'Temperatures are low (${weather.temp}°C). Bundle up in thick layers before heading out.',
      ));
    } else if (weather.temp > 28) {
      list.add(_SuggestionItem(
        icon: Icons.local_drink_rounded,
        iconColor: Colors.amber,
        title: 'Hydration Alert',
        body: 'High heat recorded. Drink plenty of water and stay in shaded areas to avoid dehydration.',
      ));
    }

    // 2. Rain / Wet checks
    final cond = weather.condition.toLowerCase();
    if (cond.contains('rain') || cond.contains('drizzle') || cond.contains('storm') || weather.rainProbability > 0.4) {
      list.add(_SuggestionItem(
        icon: Icons.umbrella_rounded,
        iconColor: Colors.purpleAccent,
        title: 'Bring Umbrella',
        body: 'Rain showers are highly likely. Keep an umbrella close and wear waterproof shoes.',
      ));
    }

    // 3. UV / Sun protection checks
    if (weather.uvIndex > 5.0) {
      list.add(_SuggestionItem(
        icon: Icons.shield_rounded,
        iconColor: Colors.orange,
        title: 'Apply SPF 30+',
        body: 'High UV exposure (${weather.uvIndex}). Protect your skin with sunscreen and sunglasses.',
      ));
    }

    // 4. Outdoor workouts
    if (weather.temp >= 15 && weather.temp <= 25 && weather.rainProbability < 0.2 && !cond.contains('storm') && !cond.contains('fog')) {
      list.add(_SuggestionItem(
        icon: Icons.directions_run_rounded,
        iconColor: Colors.greenAccent,
        title: 'Outdoor Workout',
        body: 'Perfect conditions for running or cycling. Enjoy the beautiful ambient weather!',
      ));
    } else {
      list.add(_SuggestionItem(
        icon: Icons.home_rounded,
        iconColor: Colors.blueGrey,
        title: 'Indoor Activities',
        body: 'Sub-optimal weather outside. Consider indoor exercise or cozy home activities today.',
      ));
    }

    // 5. Travel advice
    if (cond.contains('fog') || cond.contains('mist')) {
      list.add(_SuggestionItem(
        icon: Icons.drive_eta_rounded,
        iconColor: Colors.yellow,
        title: 'Drive Safely',
        body: 'Low visibility due to fog. Turn on fog lights and maintain extra distance on roads.',
      ));
    } else {
      list.add(_SuggestionItem(
        icon: Icons.explore_rounded,
        iconColor: Colors.tealAccent,
        title: 'Travel Friendly',
        body: 'Visibility is excellent. Clear roads ahead make it a great day for a weekend drive.',
      ));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = _generateSuggestions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            children: [
              Icon(Icons.lightbulb_rounded, color: Colors.white70, size: 20),
              SizedBox(width: 8),
              Text(
                'Lifestyle Insights',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final item = suggestions[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 12.0),
                child: GlassContainer(
                  borderRadius: 20.0,
                  bgOpacity: 0.05,
                  borderOpacity: 0.08,
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item.icon, color: item.iconColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.body,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                height: 1.4,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SuggestionItem {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;

  _SuggestionItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
  });
}

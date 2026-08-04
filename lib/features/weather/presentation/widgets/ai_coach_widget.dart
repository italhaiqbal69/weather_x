import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/weather_entity.dart';

class AiCoachWidget extends StatefulWidget {
  final WeatherEntity weather;
  final String geminiApiKey;

  const AiCoachWidget({
    super.key,
    required this.weather,
    required this.geminiApiKey,
  });

  @override
  State<AiCoachWidget> createState() => _AiCoachWidgetState();
}

class _AiCoachWidgetState extends State<AiCoachWidget> {
  String? _cachedAdvice;
  String? _cachedKey;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateOrFetchAdvice();
  }

  @override
  void didUpdateWidget(covariant AiCoachWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.weather.cityName != widget.weather.cityName ||
        oldWidget.weather.temp != widget.weather.temp ||
        oldWidget.geminiApiKey != widget.geminiApiKey) {
      _generateOrFetchAdvice();
    }
  }

  Future<void> _generateOrFetchAdvice() async {
    final cacheKey = '${widget.weather.cityName}_${widget.weather.temp.toStringAsFixed(1)}_${widget.geminiApiKey.isNotEmpty}';
    if (_cachedKey == cacheKey && _cachedAdvice != null) {
      return;
    }

    if (widget.geminiApiKey.isEmpty) {
      // Use premium rules-based engine
      setState(() {
        _cachedAdvice = _generateRulesAdvice();
        _cachedKey = cacheKey;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    // Call Gemini API directly via Dio
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dio = Dio();
      final prompt = "You are a premium AI Weather Coach in a high-end app called Weather X. "
          "Provide a concise (2-3 sentences), engaging, actionable daily briefing for the city of ${widget.weather.cityName} based on the following metrics: "
          "Temperature: ${widget.weather.temp}°C, Feels Like: ${widget.weather.feelsLike}°C, "
          "Condition: ${widget.weather.condition} (${widget.weather.description}), UV Index: ${widget.weather.uvIndex}, "
          "Humidity: ${widget.weather.humidity}%, Wind Speed: ${widget.weather.windSpeed} m/s. "
          "Keep it friendly, highly personalized, and focus on practical recommendations for travel, health, or outdoor activities. "
          "Do not use markdown other than simple bolding.";

      final response = await dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${widget.geminiApiKey}',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final candidates = data['candidates'] as List? ?? [];
        if (candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>? ?? {};
          final parts = content['parts'] as List? ?? [];
          if (parts.isNotEmpty) {
            final adviceText = parts[0]['text'] as String? ?? '';
            setState(() {
              _cachedAdvice = adviceText.trim();
              _cachedKey = cacheKey;
              _isLoading = false;
            });
            return;
          }
        }
      }
      throw Exception('Failed to generate content from response schema.');
    } catch (e) {
      // Fallback to rules engine if API call fails
      setState(() {
        _cachedAdvice = _generateRulesAdvice();
        _cachedKey = cacheKey;
        _isLoading = false;
        _errorMessage = 'AI Coach loaded in Local Mode. (Verify your API key)';
      });
    }
  }

  String _generateRulesAdvice() {
    final List<String> tips = [];
    final temp = widget.weather.temp;
    final rainProb = widget.weather.rainProbability;
    final uv = widget.weather.uvIndex;
    final wind = widget.weather.windSpeed;
    final hum = widget.weather.humidity;

    // 1. Temp intro
    if (temp < 10) {
      tips.add("It's quite chilly in ${widget.weather.cityName} today. We recommend bundling up in layers and focusing on warm drinks.");
    } else if (temp > 29) {
      tips.add("A high heat advisory is active in ${widget.weather.cityName}. Try to limit direct sun exposure and stay hydrated.");
    } else if (temp >= 18 && temp <= 25 && rainProb < 0.2 && wind < 5) {
      tips.add("We're seeing absolute perfection in the local climate today! Ideal for runs, outdoor workouts, or patio dining.");
    } else {
      tips.add("Mild weather patterns currently dominate the area.");
    }

    // 2. Secondary checks
    if (rainProb > 0.45) {
      tips.add("Showers are highly likely, so make sure to carry an umbrella and wear waterproof layers.");
    }
    if (uv > 6.0) {
      tips.add("UV rays are strong today; protect your eyes with sunglasses and apply SPF 30+.");
    }
    if (wind > 8.0) {
      tips.add("Strong wind gusts are reported. Secure outdoor items and avoid cycling under open skies.");
    }
    if (hum > 85) {
      tips.add("High humidity may make it feel stickier than the actual temperature.");
    } else if (hum < 30) {
      tips.add("Dry atmospheric conditions are in play; keep your skin moisturized.");
    }

    // Fallback if list is short
    if (tips.length == 1) {
      tips.add("Overall comfortable conditions. Dress casually and have a wonderful day!");
    }

    return tips.join(" ");
  }

  @override
  Widget build(BuildContext context) {
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
              const Icon(Icons.psychology_rounded, color: Colors.purpleAccent, size: 24),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'AI Weather Coach',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              if (widget.geminiApiKey.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
                  ),
                  child: const Text(
                    'LIVE AI',
                    style: TextStyle(color: Colors.purpleAccent, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(color: Colors.purpleAccent),
              ),
            )
          else ...[
            Text(
              _cachedAdvice ?? 'Analyzing atmosphere metrics...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.info_outline_rounded, color: Colors.white30, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white30, fontSize: 10),
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}

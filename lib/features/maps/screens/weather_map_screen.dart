import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/glass_container.dart';

class WeatherMapScreen extends StatefulWidget {
  final double initialLat;
  final double initialLon;
  final String cityName;

  const WeatherMapScreen({
    super.key,
    required this.initialLat,
    required this.initialLon,
    required this.cityName,
  });

  @override
  State<WeatherMapScreen> createState() => _WeatherMapScreenState();
}

class _WeatherMapScreenState extends State<WeatherMapScreen> with TickerProviderStateMixin {
  String _activeLayer = 'clouds_new'; // Default overlay layer
  late final MapController _mapController;
  late final AnimationController _flowAnimController;

  // Time-lapse slider state
  double _sliderValue = 0.0; // 0 to 8 corresponding to hours (0, +3, +6, +9, +12, +15, +18, +21, +24)
  bool _isPlaying = false;
  Timer? _playbackTimer;

  bool get _isApiKeyConfigured =>
      AppConstants.openWeatherApiKey.isNotEmpty &&
      AppConstants.openWeatherApiKey != 'ENTER_API_KEY_HERE';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _flowAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _flowAnimController.dispose();
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _setLayer(String layer) {
    if (_activeLayer != layer) {
      setState(() {
        _activeLayer = layer;
      });
    }
  }

  void _togglePlayback() {
    if (_isPlaying) {
      _playbackTimer?.cancel();
      setState(() {
        _isPlaying = false;
      });
    } else {
      setState(() {
        _isPlaying = true;
      });
      _playbackTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
        setState(() {
          _sliderValue += 1.0;
          if (_sliderValue > 8.0) {
            _sliderValue = 0.0;
          }
        });
      });
    }
  }

  String _getForecastTimeLabel() {
    final hrs = (_sliderValue * 3).toInt();
    if (hrs == 0) return "Current Status";
    return "+$hrs Hours Forecast";
  }

  String _getForecastDesc() {
    final hrs = (_sliderValue * 3).toInt();
    if (_activeLayer == 'clouds_new') {
      if (hrs == 0) return "Real-time cloud coverage structures.";
      return "Cloud clusters projected to shift Northeast in $hrs hours.";
    } else if (_activeLayer == 'precipitation_new') {
      if (hrs == 0) return "Current radar precipitation sweep.";
      return "Precipitation bands expected to decrease in density in $hrs hours.";
    } else if (_activeLayer == 'temp_new') {
      if (hrs == 0) return "Active thermal front gradients.";
      return "Temperatures expected to drop by ${(hrs * 0.2).toStringAsFixed(1)}°C in $hrs hours.";
    } else {
      if (hrs == 0) return "Live surface wind streamlines.";
      return "Wind gusts velocity intensifying by ${(hrs * 0.4).toStringAsFixed(1)} m/s.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> layers = {
      'clouds_new': 'Clouds',
      'precipitation_new': 'Rain',
      'temp_new': 'Temp',
      'wind_new': 'Wind',
    };

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: Text(
          'Radar Map - ${widget.cityName}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Stack(
        children: [
          // Free OSM map with OpenWeather overlay on top
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.initialLat, widget.initialLon),
              initialZoom: 6,
              maxZoom: 18,
              minZoom: 2,
            ),
            children: [
              // Premium Dark Matter free maps styling
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.weather_x',
              ),
              // OpenWeatherMap Layer Overlay (if API key is set)
              if (_isApiKeyConfigured)
                Opacity(
                  opacity: 0.45,
                  child: TileLayer(
                    urlTemplate: '${AppConstants.mapTileUrl}/$_activeLayer/{z}/{x}/{y}.png?appid=${AppConstants.openWeatherApiKey}',
                  ),
                ),
            ],
          ),

          // Custom Flow Particles Painter Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _flowAnimController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FlowParticlesPainter(
                      progress: _flowAnimController.value,
                      layerType: _activeLayer,
                      timeOffset: _sliderValue,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Warnings if API key is not present
          if (!_isApiKeyConfigured)
            Positioned(
              top: 100,
              left: 16,
              right: 16,
              child: GlassContainer(
                borderRadius: 12,
                bgOpacity: 0.25,
                borderOpacity: 0.3,
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'OpenWeather API key is required to load the weather radar overlay.',
                        style: TextStyle(color: Colors.red.shade100, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
          // Map Control HUD Overlay & Time-lapse
          Positioned(
            bottom: 32,
            left: 16,
            right: 16,
            child: GlassContainer(
              borderRadius: 24,
              bgOpacity: 0.15,
              borderOpacity: 0.2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Playback Timeline
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded),
                        color: Colors.amber,
                        iconSize: 36,
                        onPressed: _togglePlayback,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getForecastTimeLabel(),
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '${(_sliderValue * 3).toInt()}h',
                                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 3,
                                activeTrackColor: Colors.amber,
                                inactiveTrackColor: Colors.white24,
                                thumbColor: Colors.amber,
                                overlayColor: Colors.amber.withOpacity(0.15),
                              ),
                              child: Slider(
                                value: _sliderValue,
                                min: 0.0,
                                max: 8.0,
                                divisions: 8,
                                onChanged: (val) {
                                  _playbackTimer?.cancel();
                                  setState(() {
                                    _sliderValue = val;
                                    _isPlaying = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: Text(
                      _getForecastDesc(),
                      style: const TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 6),
                  const Text(
                    'Weather Layers',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: layers.entries.map((e) {
                      final isSelected = _activeLayer == e.key;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: InkWell(
                            onTap: () => _setLayer(e.key),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.white10,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowParticlesPainter extends CustomPainter {
  final double progress;
  final String layerType;
  final double timeOffset;

  _FlowParticlesPainter({
    required this.progress,
    required this.layerType,
    required this.timeOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Use stable seed for particle layout
    final random = math.Random(12345);
    final count = layerType == 'precipitation_new' ? 60 : 35;

    for (int i = 0; i < count; i++) {
      final xStart = random.nextDouble() * size.width;
      final yStart = random.nextDouble() * size.height;

      // Adjust movement vectors depending on layer type
      if (layerType == 'precipitation_new') {
        // Rain falls vertically down and slightly right
        paint.color = Colors.lightBlueAccent.withOpacity(0.25);
        paint.strokeWidth = 1.5;

        final length = random.nextDouble() * 12 + 8;
        final speed = random.nextDouble() * 200 + 300; // Falling speed
        final offset = (progress * speed) % size.height;

        final start = Offset((xStart + offset * 0.15) % size.width, (yStart + offset) % size.height);
        final end = Offset(start.dx + length * 0.15, start.dy + length);

        canvas.drawLine(start, end, paint);
      } else if (layerType == 'wind_new') {
        // Wind travels horizontally right with curls
        paint.color = Colors.tealAccent.withOpacity(0.2);
        paint.strokeWidth = 2.0;

        final length = random.nextDouble() * 40 + 20;
        final speed = (random.nextDouble() * 120 + 80) * (1.0 + timeOffset * 0.15); // Wind speed rises with timeoffset
        final offset = (progress * speed) % size.width;

        final startX = (xStart + offset) % size.width;
        final startY = yStart + math.sin((startX / 30) + (progress * 2 * math.pi)) * 6;

        canvas.drawArc(
          Rect.fromLTWH(startX, startY, length, 12),
          0,
          math.pi / 2,
          false,
          paint,
        );
      } else if (layerType == 'clouds_new') {
        // Clouds move slowly
        paint.color = Colors.white.withOpacity(0.08);
        paint.style = PaintingStyle.fill;

        final radius = random.nextDouble() * 30 + 20;
        final speed = random.nextDouble() * 25 + 10;
        final offset = (progress * speed) % size.width;

        final center = Offset((xStart + offset) % size.width, yStart);
        canvas.drawCircle(center, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlowParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.layerType != layerType ||
        oldDelegate.timeOffset != timeOffset;
  }
}

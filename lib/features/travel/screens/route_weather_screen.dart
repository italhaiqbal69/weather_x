import 'package:flutter/material.dart';
import '../../../../app/dependency_injection.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../weather/domain/repositories/weather_repository.dart';

class RouteWeatherScreen extends StatefulWidget {
  const RouteWeatherScreen({super.key});

  @override
  State<RouteWeatherScreen> createState() => _RouteWeatherScreenState();
}

class _RouteWeatherScreenState extends State<RouteWeatherScreen> {
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  List<String> _startSuggestions = [];
  List<String> _endSuggestions = [];

  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> _timelineWaypoints = [];
  double _totalDistanceKm = 0.0;
  double _totalDurationHrs = 0.0;

  Future<void> _fetchSuggestions(String query, bool isStart) async {
    if (query.trim().length < 3) {
      setState(() {
        if (isStart) _startSuggestions.clear();
        else _endSuggestions.clear();
      });
      return;
    }
    try {
      final suggestions = await sl<WeatherRepository>().searchCities(query);
      setState(() {
        if (isStart) _startSuggestions = suggestions;
        else _endSuggestions = suggestions;
      });
    } catch (_) {}
  }

  Future<void> _calculateRoute() async {
    final startCity = _startController.text.trim();
    final endCity = _endController.text.trim();

    if (startCity.isEmpty || endCity.isEmpty) {
      setState(() {
        _errorMessage = "Please specify both starting and destination cities.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _timelineWaypoints.clear();
    });

    try {
      // 1. Resolve coordinates for start and end cities
      final startResults = await sl<ApiClient>().searchCities(startCity.split(',')[0]);
      final endResults = await sl<ApiClient>().searchCities(endCity.split(',')[0]);

      if (startResults.isEmpty || endResults.isEmpty) {
        throw Exception("Could not find coordinates for one of the locations. Please check the spelling.");
      }

      final startLat = (startResults[0]['lat'] as num).toDouble();
      final startLon = (startResults[0]['lon'] as num).toDouble();
      final startName = startResults[0]['name'] as String;

      final endLat = (endResults[0]['lat'] as num).toDouble();
      final endLon = (endResults[0]['lon'] as num).toDouble();
      final endName = endResults[0]['name'] as String;

      // 2. Query OSRM routing engine
      final routeResponse = await sl<ApiClient>().fetchRoute(startLat, startLon, endLat, endLon);
      final routes = routeResponse['routes'] as List? ?? [];

      if (routes.isEmpty) {
        throw Exception("No drivable route found between these coordinates.");
      }

      final route = routes[0] as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>? ?? {};
      final coordinates = geometry['coordinates'] as List? ?? [];
      final durationSeconds = (route['duration'] as num).toDouble();
      final distanceMeters = (route['distance'] as num).toDouble();

      _totalDistanceKm = distanceMeters / 1000.0;
      _totalDurationHrs = durationSeconds / 3600.0;

      if (coordinates.isEmpty) {
        throw Exception("Failed to extract route trajectory path.");
      }

      // 3. Select 5 equidistant points along the route
      final pointsIndices = [
        0,
        coordinates.length ~/ 4,
        coordinates.length ~/ 2,
        (coordinates.length * 3) ~/ 4,
        coordinates.length - 1
      ];

      final List<Future<Map<String, dynamic>>> weatherFetchers = [];

      for (int index in pointsIndices) {
        final coord = coordinates[index.clamp(0, coordinates.length - 1)] as List;
        final double lon = (coord[0] as num).toDouble();
        final double lat = (coord[1] as num).toDouble();
        weatherFetchers.add(_fetchWeatherForPoint(lat, lon, index == 0 ? startName : (index == coordinates.length - 1 ? endName : null)));
      }

      final results = await Future.wait(weatherFetchers);

      // Assemble timeline details
      setState(() {
        _timelineWaypoints = List.generate(results.length, (i) {
          final res = results[i];
          final stepRatio = i / (results.length - 1);
          final minutesFromStart = (durationSeconds * stepRatio / 60.0).round();

          String locationLabel = res['name'];
          if (locationLabel.isEmpty || locationLabel == 'Unknown') {
            if (i == 1) locationLabel = "Quarterway";
            else if (i == 2) locationLabel = "Midway";
            else if (i == 3) locationLabel = "Three-Quarterway";
          } else {
            if (i == 1) locationLabel = "Quarterway ($locationLabel)";
            else if (i == 2) locationLabel = "Midway ($locationLabel)";
            else if (i == 3) locationLabel = "Three-Quarterway ($locationLabel)";
          }

          return {
            'label': locationLabel,
            'temp': res['temp'] as double,
            'condition': res['condition'] as String,
            'iconCode': res['iconCode'] as String,
            'eta': minutesFromStart == 0
                ? "Start (0 mins)"
                : minutesFromStart > 60
                    ? "+${(minutesFromStart ~/ 60)}h ${(minutesFromStart % 60)}m"
                    : "+$minutesFromStart mins",
          };
        });
        _isLoading = false;
      });

    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst("Exception: ", "");
        _isLoading = false;
      });
    }
  }

  Future<Map<String, dynamic>> _fetchWeatherForPoint(double lat, double lon, String? overrideName) async {
    try {
      String resolvedName = overrideName ?? '';
      if (resolvedName.isEmpty) {
        // Reverse geocode
        final geocode = await sl<ApiClient>().reverseGeocode(lat, lon);
        if (geocode.isNotEmpty) {
          resolvedName = geocode[0]['name'] as String? ?? 'Waypoint';
        }
      }

      final weatherData = await sl<ApiClient>().getCurrentWeather(lat, lon);
      final main = weatherData['main'] as Map<String, dynamic>? ?? {};
      final weatherList = weatherData['weather'] as List? ?? [];
      final weather = weatherList.isNotEmpty ? weatherList[0] as Map<String, dynamic> : {};

      return {
        'name': resolvedName,
        'temp': (main['temp'] as num?)?.toDouble() ?? 0.0,
        'condition': weather['main'] as String? ?? 'Clear',
        'iconCode': weather['icon'] as String? ?? '01d',
      };
    } catch (_) {
      return {
        'name': overrideName ?? 'Waypoint',
        'temp': 20.0,
        'condition': 'Clear',
        'iconCode': '01d',
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Route Weather Planner',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Plan your travel weather dynamically along your route trajectory:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                
                // Inputs Panel
                GlassContainer(
                  borderRadius: 20,
                  bgOpacity: 0.05,
                  borderOpacity: 0.08,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildCityInput(
                        controller: _startController,
                        label: 'Departure City',
                        icon: Icons.my_location_rounded,
                        color: Colors.tealAccent,
                        suggestions: _startSuggestions,
                        isStart: true,
                      ),
                      const SizedBox(height: 16),
                      _buildCityInput(
                        controller: _endController,
                        label: 'Destination City',
                        icon: Icons.location_on_rounded,
                        color: Colors.redAccent,
                        suggestions: _endSuggestions,
                        isStart: false,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.grey.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: _isLoading ? null : _calculateRoute,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                                )
                              : const Text('Calculate Route Weather', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                if (_timelineWaypoints.isNotEmpty) ...[
                  // Summary Header
                  GlassContainer(
                    borderRadius: 16,
                    bgOpacity: 0.08,
                    borderOpacity: 0.08,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSummaryColumn('DISTANCE', '${_totalDistanceKm.toStringAsFixed(0)} km'),
                        Container(height: 24, width: 1, color: Colors.white24),
                        _buildSummaryColumn('EST. DURATION', '${_totalDurationHrs.toStringAsFixed(1)} hrs'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Waypoint Timeline
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _timelineWaypoints.length,
                    itemBuilder: (context, index) {
                      final item = _timelineWaypoints[index];
                      final isLast = index == _timelineWaypoints.length - 1;
                      
                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Timeline track
                            Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: index == 0
                                        ? Colors.tealAccent
                                        : (isLast ? Colors.redAccent : Colors.amber),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      color: Colors.white24,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Details Card
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 24.0),
                                child: GlassContainer(
                                  borderRadius: 16,
                                  bgOpacity: 0.03,
                                  borderOpacity: 0.05,
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['label'],
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item['eta'],
                                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Image.network(
                                            'https://openweathermap.org/img/wn/${item['iconCode']}@2x.png',
                                            width: 32,
                                            height: 32,
                                            errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 20),
                                          ),
                                          Text(
                                            '${(item['temp'] as double).toStringAsFixed(0)}°C',
                                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 9, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCityInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required List<String> suggestions,
    required bool isStart,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: color, size: 20),
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54, fontSize: 12),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white10),
              borderRadius: BorderRadius.circular(14),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white30),
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onChanged: (val) => _fetchSuggestions(val, isStart),
        ),
        if (suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            constraints: const BoxConstraints(maxHeight: 120),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: suggestions.length,
              itemBuilder: (context, i) {
                return ListTile(
                  dense: true,
                  title: Text(suggestions[i], style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  onTap: () {
                    setState(() {
                      controller.text = suggestions[i];
                      if (isStart) _startSuggestions.clear();
                      else _endSuggestions.clear();
                    });
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}

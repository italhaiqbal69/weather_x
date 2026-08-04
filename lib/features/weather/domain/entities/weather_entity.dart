class WeatherEntity {
  final String cityName;
  final double latitude;
  final double longitude;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final String condition;
  final String description;
  final String iconCode;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDirection;
  final double visibility;
  final int cloudCover;
  final double dewPoint;
  final double rainProbability;
  final double uvIndex;
  final int sunrise;
  final int sunset;
  final int timestamp;

  const WeatherEntity({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.cloudCover,
    required this.dewPoint,
    required this.rainProbability,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.timestamp,
  });

  // Convert to dynamic Map for local Hive database storage
  Map<String, dynamic> toJson() {
    return {
      'cityName': cityName,
      'latitude': latitude,
      'longitude': longitude,
      'temp': temp,
      'feelsLike': feelsLike,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'condition': condition,
      'description': description,
      'iconCode': iconCode,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'visibility': visibility,
      'cloudCover': cloudCover,
      'dewPoint': dewPoint,
      'rainProbability': rainProbability,
      'uvIndex': uvIndex,
      'sunrise': sunrise,
      'sunset': sunset,
      'timestamp': timestamp,
    };
  }

  // Parse from local Hive storage Map
  factory WeatherEntity.fromJson(Map<String, dynamic> json) {
    return WeatherEntity(
      cityName: json['cityName'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (json['feelsLike'] as num?)?.toDouble() ?? 0.0,
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 0.0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? 'Clear',
      description: json['description'] as String? ?? 'clear sky',
      iconCode: json['iconCode'] as String? ?? '01d',
      humidity: json['humidity'] as int? ?? 0,
      pressure: json['pressure'] as int? ?? 1013,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      windDirection: json['windDirection'] as int? ?? 0,
      visibility: (json['visibility'] as num?)?.toDouble() ?? 10000.0,
      cloudCover: json['cloudCover'] as int? ?? 0,
      dewPoint: (json['dewPoint'] as num?)?.toDouble() ?? 0.0,
      rainProbability: (json['rainProbability'] as num?)?.toDouble() ?? 0.0,
      uvIndex: (json['uvIndex'] as num?)?.toDouble() ?? 0.0,
      sunrise: json['sunrise'] as int? ?? 0,
      sunset: json['sunset'] as int? ?? 0,
      timestamp: json['timestamp'] as int? ?? 0,
    );
  }
}

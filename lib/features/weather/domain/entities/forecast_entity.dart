class ForecastEntity {
  final List<HourlyForecastEntity> hourly;
  final List<DailyForecastEntity> daily;

  const ForecastEntity({
    required this.hourly,
    required this.daily,
  });

  Map<String, dynamic> toJson() {
    return {
      'hourly': hourly.map((h) => h.toJson()).toList(),
      'daily': daily.map((d) => d.toJson()).toList(),
    };
  }

  factory ForecastEntity.fromJson(Map<String, dynamic> json) {
    final hourlyList = (json['hourly'] as List? ?? [])
        .map((h) => HourlyForecastEntity.fromJson(h as Map<String, dynamic>))
        .toList();
    final dailyList = (json['daily'] as List? ?? [])
        .map((d) => DailyForecastEntity.fromJson(d as Map<String, dynamic>))
        .toList();
    return ForecastEntity(hourly: hourlyList, daily: dailyList);
  }
}

class HourlyForecastEntity {
  final int timestamp;
  final double temp;
  final String condition;
  final String iconCode;
  final double rainProbability;
  final double windSpeed;

  const HourlyForecastEntity({
    required this.timestamp,
    required this.temp,
    required this.condition,
    required this.iconCode,
    required this.rainProbability,
    required this.windSpeed,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'temp': temp,
      'condition': condition,
      'iconCode': iconCode,
      'rainProbability': rainProbability,
      'windSpeed': windSpeed,
    };
  }

  factory HourlyForecastEntity.fromJson(Map<String, dynamic> json) {
    return HourlyForecastEntity(
      timestamp: json['timestamp'] as int? ?? 0,
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? 'Clear',
      iconCode: json['iconCode'] as String? ?? '01d',
      rainProbability: (json['rainProbability'] as num?)?.toDouble() ?? 0.0,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DailyForecastEntity {
  final int timestamp;
  final double tempMin;
  final double tempMax;
  final double tempDay;
  final String condition;
  final String description;
  final String iconCode;
  final int humidity;
  final int pressure;
  final double windSpeed;
  final int windDirection;
  final double rainProbability;
  final int sunrise;
  final int sunset;

  const DailyForecastEntity({
    required this.timestamp,
    required this.tempMin,
    required this.tempMax,
    required this.tempDay,
    required this.condition,
    required this.description,
    required this.iconCode,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.rainProbability,
    required this.sunrise,
    required this.sunset,
  });

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp,
      'tempMin': tempMin,
      'tempMax': tempMax,
      'tempDay': tempDay,
      'condition': condition,
      'description': description,
      'iconCode': iconCode,
      'humidity': humidity,
      'pressure': pressure,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'rainProbability': rainProbability,
      'sunrise': sunrise,
      'sunset': sunset,
    };
  }

  factory DailyForecastEntity.fromJson(Map<String, dynamic> json) {
    return DailyForecastEntity(
      timestamp: json['timestamp'] as int? ?? 0,
      tempMin: (json['tempMin'] as num?)?.toDouble() ?? 0.0,
      tempMax: (json['tempMax'] as num?)?.toDouble() ?? 0.0,
      tempDay: (json['tempDay'] as num?)?.toDouble() ?? 0.0,
      condition: json['condition'] as String? ?? 'Clear',
      description: json['description'] as String? ?? 'clear sky',
      iconCode: json['iconCode'] as String? ?? '01d',
      humidity: json['humidity'] as int? ?? 0,
      pressure: json['pressure'] as int? ?? 1013,
      windSpeed: (json['windSpeed'] as num?)?.toDouble() ?? 0.0,
      windDirection: json['windDirection'] as int? ?? 0,
      rainProbability: (json['rainProbability'] as num?)?.toDouble() ?? 0.0,
      sunrise: json['sunrise'] as int? ?? 0,
      sunset: json['sunset'] as int? ?? 0,
    );
  }
}

class AirQualityEntity {
  final int aqi; // 1 to 5 index
  final double co;
  final double no2;
  final double o3;
  final double so2;
  final double pm2_5;
  final double pm10;
  final double nh3;
  final double no;

  const AirQualityEntity({
    required this.aqi,
    required this.co,
    required this.no2,
    required this.o3,
    required this.so2,
    required this.pm2_5,
    required this.pm10,
    required this.nh3,
    required this.no,
  });

  Map<String, dynamic> toJson() {
    return {
      'aqi': aqi,
      'co': co,
      'no2': no2,
      'o3': o3,
      'so2': so2,
      'pm2_5': pm2_5,
      'pm10': pm10,
      'nh3': nh3,
      'no': no,
    };
  }

  factory AirQualityEntity.fromJson(Map<String, dynamic> json) {
    return AirQualityEntity(
      aqi: json['aqi'] as int? ?? 1,
      co: (json['co'] as num?)?.toDouble() ?? 0.0,
      no2: (json['no2'] as num?)?.toDouble() ?? 0.0,
      o3: (json['o3'] as num?)?.toDouble() ?? 0.0,
      so2: (json['so2'] as num?)?.toDouble() ?? 0.0,
      pm2_5: (json['pm2_5'] as num?)?.toDouble() ?? 0.0,
      pm10: (json['pm10'] as num?)?.toDouble() ?? 0.0,
      nh3: (json['nh3'] as num?)?.toDouble() ?? 0.0,
      no: (json['no'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get healthRecommendation {
    switch (aqi) {
      case 1:
        return 'Air quality is excellent. Ideal for outdoor exercises and activities.';
      case 2:
        return 'Air quality is fair. Sensitive individuals should consider reducing heavy outdoor activities.';
      case 3:
        return 'Moderate pollution. Sensitive groups may experience health symptoms. Limit long outdoor activities.';
      case 4:
        return 'Poor air quality. Everyone may begin to experience health effects; limit prolonged outdoor exposure.';
      case 5:
        return 'Very poor quality! Avoid outdoor physical activities. Keep doors and windows closed.';
      default:
        return 'No recommendation available.';
    }
  }

  String get statusName {
    switch (aqi) {
      case 1:
        return 'Good';
      case 2:
        return 'Fair';
      case 3:
        return 'Moderate';
      case 4:
        return 'Poor';
      case 5:
        return 'Very Poor';
      default:
        return 'Unknown';
    }
  }
}
